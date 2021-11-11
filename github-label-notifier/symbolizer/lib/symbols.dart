// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utilities for downloading and locally caching symbol files.
library symbolizer.symbols;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'package:symbolizer/model.dart';
import 'package:symbolizer/ndk.dart';

final _log = Logger('symbols');

/// Local cache of symbol files downloaded from Cloud Storage bucket.
class SymbolsCache {
  final Ndk _ndk;

  /// Local path at which this cache is located.
  final String _path;

  /// Number of entries in the cache after which we will start trying to
  /// evict all entries which were not touched for longer than
  /// [evictionThreshold].
  final int _sizeThreshold;

  /// Threshold past which an unused entry in the cache is considered evictable.
  final Duration _evictionThreshold;

  /// Map describing when symbols for the given [EngineBuild] were used
  /// last time.
  final Map<String, int> _lastUsedTimestamp = {};

  /// Cache mapping Build-Id's values to corresponding engine builds.
  final Map<String, EngineBuild> _buildIdCache = {};

  /// Pending downloads by [EngineBuild].
  final Map<String, Future<String>> _downloads = {};

  /// Constructs cache at the given [path], which is assumed to be a directory.
  /// If destination does not exist it will be created.
  SymbolsCache({
    @required Ndk ndk,
    @required String path,
    int sizeThreshold = 20,
    Duration evictionThreshold = const Duration(minutes: 5),
  })  : _ndk = ndk,
        _path = path,
        _sizeThreshold = sizeThreshold,
        _evictionThreshold = evictionThreshold {
    if (!Directory(path).existsSync()) {
      Directory(path).createSync();
    }
    _loadState();
  }

  /// If necessary download symbols for the given [build] and return path to
  /// the folder containing them.
  Future<String> get(EngineBuild build) => _get(build, '', _downloadSymbols);

  /// If necessary download engine binary (libflutter.so or Flutter) for the
  /// given build and return path to the binary itself.
  Future<String> getEngineBinary(EngineBuild build) async {
    final dir = await _get(build, 'libflutter', _downloadEngine);
    return p.join(dir, p.basename(_libflutterPath(build)));
  }

  /// Download an artifact from Cloud Storage using the given [downloader] and
  /// cache result in the path using the given [suffix].
  Future<String> _get(
    EngineBuild build,
    String suffix,
    Future<void> Function(Directory, EngineBuild) downloader,
  ) {
    final cacheDir = _cacheDirectoryFor(build, suffix: suffix);
    if (!_downloads.containsKey(cacheDir)) {
      _downloads[cacheDir] = _getImpl(cacheDir, build, downloader);
      _downloads[cacheDir].then((_) => _downloads.remove(cacheDir));
    }
    return _downloads[cacheDir];
  }

  /// Given the [engineHash] and [EngineVariant] which specifies OS and
  /// architecture look at symbols for all possible build modes and
  /// find the one matching the given [buildId].
  ///
  /// Currently only used for Android symbols because on iOS LC_UUID
  /// is unreliable.
  Future<EngineBuild> findVariantByBuildId({
    @required String engineHash,
    @required EngineVariant variant,
    @required String buildId,
  }) async {
    _log.info('looking for ${buildId} among ${variant} engines');
    if (variant.os != 'android') {
      throw ArgumentError(
          'LC_UUID is unreliable on iOS and can not be used for mode matching');
    }

    // Check if we already have a match in the Build-Id cache.
    if (_buildIdCache.containsKey(buildId)) {
      final build = _buildIdCache[buildId];
      if (build.variant.os == variant.os &&
          build.variant.arch == variant.arch) {
        return build;
      }
    }

    for (var potentialVariant in EngineVariant.allModesFor(variant)) {
      final engineBuild =
          EngineBuild(engineHash: engineHash, variant: potentialVariant);
      final dir = await get(engineBuild);
      final thisBuildId = await _ndk.getBuildId(p.join(dir, 'libflutter.so'));
      _buildIdCache[thisBuildId] = engineBuild;
      if (thisBuildId == buildId) {
        return engineBuild;
      }
    }
    throw 'Failed to find build with matching buildId (${buildId})';
  }

  File get _cacheStateFile => File(p.join(_path, 'cache.json'));

  void _loadState() {
    if (!_cacheStateFile.existsSync()) return;

    final Map<String, dynamic> cacheState =
        jsonDecode(_cacheStateFile.readAsStringSync());
    final timestamps = cacheState['lastUsedTimestamp'] as List<dynamic>;
    _lastUsedTimestamp.clear();
    for (var i = 0; i < timestamps.length; i += 2) {
      _lastUsedTimestamp[timestamps[i]] = timestamps[i + 1];
    }
    _buildIdCache.addAll((cacheState['buildIdCache'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, EngineBuild.fromJson(value))));
  }

  void _saveState() {
    _cacheStateFile.writeAsStringSync(jsonEncode({
      'lastUsedTimestamp':
          _lastUsedTimestamp.entries.expand((e) => [e.key, e.value]).toList(),
      'buildIdCache': _buildIdCache
    }));
  }

  String _cacheDirectoryFor(EngineBuild build, {String suffix = ''}) =>
      'symbols-cache/${build.engineHash}-${build.variant.toArtifactPath()}'
      '${suffix.isNotEmpty ? '-' : ''}${suffix}';

  Future<String> _getImpl(String targetDir, EngineBuild build,
      Future<void> Function(Directory, EngineBuild) downloader) async {
    final dir = Directory(targetDir);
    if (dir.existsSync()) {
      _touch(dir.path);
      return dir.path;
    }

    // Make sure we have some space.
    _evictOldEntriesIfNecessary();
    _log.info('downloading ${targetDir} for ${build}');

    // Download symbols into a temporary directory, once we successfully
    // unpack them we will rename this directory.
    final tempDir = await Directory.systemTemp.createTemp();
    try {
      await downloader(tempDir, build);
      // Now move the directory into the cache.
      final renamed = await tempDir.rename(dir.path);
      if (build.variant.os == 'android') {
        // Fetch Build-Id from the library and add it to the cache.
        final buildId =
            await _ndk.getBuildId(p.join(renamed.path, 'libflutter.so'));
        _buildIdCache[buildId] = build;
      }
      _touch(renamed.path);
      return renamed.path;
    } finally {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    }
  }

  Future<String> _copyFromGS(String fromUri, String toDir) {
    _log.info('gsutil cp $fromUri $toDir');
    return _run('gsutil', ['cp', fromUri, toDir]);
  }

  Future<void> _downloadSymbols(Directory tempDir, EngineBuild build) async {
    final symbolsFile =
        build.variant.os == 'ios' ? 'Flutter.dSYM.zip' : 'symbols.zip';

    await _copyFromGS(
        'gs://flutter_infra_release/flutter/${build.engineHash}/${build.variant.toArtifactPath()}/${symbolsFile}',
        p.join(tempDir.path, symbolsFile));
    await _run('unzip', [symbolsFile], workingDirectory: tempDir.path);

    // Delete downloaded ZIP file.
    await File(p.join(tempDir.path, symbolsFile)).delete();
  }

  Future<void> _downloadEngine(Directory tempDir, EngineBuild build) async {
    final artifactsFile = 'artifacts.zip';
    await _copyFromGS(
        'gs://flutter_infra_release/flutter/${build.engineHash}/${build.variant.toArtifactPath()}/${artifactsFile}',
        p.join(tempDir.path, artifactsFile));

    final nestedZip =
        build.variant.os == 'ios' ? 'Flutter.framework.zip' : 'flutter.jar';

    final contentsList = await _run('unzip', ['-l', artifactsFile],
        workingDirectory: tempDir.path);

    var libraryPath;
    if (build.variant.os == 'ios' && !contentsList.contains(nestedZip)) {
      // Newer versions don't contains nested zip inside and instead contain
      // Flutter.xcframework folder.
      // Futhermore it seems that arch suffix has changed between releases due
      // to https://github.com/flutter/flutter/issues/60043.
      final archSuffix =
          contentsList.contains('armv7_arm64') ? 'armv7_arm64' : 'arm64_armv7';
      libraryPath =
          'Flutter.xcframework/ios-$archSuffix/Flutter.framework/Flutter';
      await _run('unzip', [artifactsFile, libraryPath],
          workingDirectory: tempDir.path);
    } else {
      libraryPath = _libflutterPath(build);
      await _run('unzip', [artifactsFile, nestedZip],
          workingDirectory: tempDir.path);

      await _run('unzip', [nestedZip, libraryPath],
          workingDirectory: tempDir.path);
    }

    if (p.dirname(libraryPath) != '.') {
      await File(p.join(tempDir.path, libraryPath))
          .rename(p.join(tempDir.path, p.basename(libraryPath)));
      await Directory(
              p.join(tempDir.path, p.split(p.normalize(libraryPath)).first))
          .delete(recursive: true);
    }

    // Delete downloaded ZIP file.
    await _deleteIfExists(p.join(tempDir.path, artifactsFile));
    await _deleteIfExists(p.join(tempDir.path, nestedZip));
  }

  static String _libflutterPath(EngineBuild build) {
    switch (build.variant.os) {
      case 'ios':
        return 'Flutter';
      case 'android':
        switch (build.variant.arch) {
          case 'arm64':
            return 'lib/arm64-v8a/libflutter.so';
          case 'arm':
            return 'lib/armeabi-v7a/libflutter.so';
        }
        break;
    }
    throw 'Unsupported combination of architecture and OS: ${build.variant}';
  }

  static Future<void> _deleteIfExists(String path) async {
    final f = File(path);
    if (f.existsSync()) {
      await f.delete();
    }
  }

  Future<String> _run(String executable, List<String> args,
      {String workingDirectory}) async {
    final result =
        await Process.run(executable, args, workingDirectory: workingDirectory);
    if (result.exitCode != 0) {
      throw 'Failed to run ${executable} ${args.join(' ')} '
          '(exit code ${result.exitCode}): ${result.stdout} ${result.stderr}';
    }
    return result.stdout;
  }

  void _touch(String path) {
    _lastUsedTimestamp[path] = DateTime.now().millisecondsSinceEpoch;
    _saveState();
  }

  /// If the cache is too big then evict all entries outside of the given
  /// interval.
  void _evictOldEntriesIfNecessary() {
    if (_lastUsedTimestamp.length < _sizeThreshold) {
      return;
    }

    final fiveMinutesAgo =
        DateTime.now().subtract(_evictionThreshold).millisecondsSinceEpoch;
    for (var path in _lastUsedTimestamp.entries
        .where((e) => e.value < fiveMinutesAgo)
        .map((e) => e.key)
        .toList()) {
      final dir = Directory(path);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
      _lastUsedTimestamp.remove(path);
    }
    _saveState();
  }
}

extension on EngineVariant {
  String toArtifactPath() {
    final modeSuffix = (mode == 'debug') ? '' : '-${mode}';
    if (os == 'ios') {
      return '${os}${modeSuffix}';
    } else {
      return '${os}-${arch}${modeSuffix}';
    }
  }
}

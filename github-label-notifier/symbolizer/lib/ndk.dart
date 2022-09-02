// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Wrapper around ndk tools used for symbolization.
library symbolizer.ndk;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class Ndk {
  /// Return information about .text section from the given [object] file.
  Future<SectionInfo> getTextSectionInfo(String object) async {
    final result = await _run(_readelfBinary, ['-lW', object]);
    for (var match in _loadCommandPattern.allMatches(result)) {
      if (match.namedGroup('flags')!.trim() == 'R E') {
        // Found .text section
        return SectionInfo(
          fileOffset: int.parse(match.namedGroup('offset')!),
          fileSize: int.parse(match.namedGroup('filesz')!),
          virtualAddress: int.parse(match.namedGroup('vma')!),
        );
      }
    }
    throw 'Failed to find LOAD command for text section in $object';
  }

  /// Return build-id of the given [object] file.
  Future<String> getBuildId(String object) async {
    final result = await _run(_readelfBinary, ['-nW', object]);
    final match = _buildIdPattern.firstMatch(result);
    if (match == null) {
      throw 'Failed to extract build-id from $object';
    }
    return match.namedGroup('id')!;
  }

  /// Symbolize given [addresses] using information available for the specified
  /// [arch] in the given [object] file.
  Future<List<String>> symbolize(
      {required String object,
      required List<String> addresses,
      String? arch}) async {
    final result = await _run(_llvmSymbolizerBinary, [
      if (arch != null) '--default-arch=$arch',
      '--obj',
      object,
      '--inlines',
      ...addresses
    ]);

    final symbolized = result.replaceAllMapped(_builderPathPattern, (m) {
      return p.relative(p.normalize(m[0]!),
          from: (m as RegExpMatch).namedGroup('root'));
    }).split('\n\n');
    if (symbolized.last == '') symbolized.length--;

    return symbolized;
  }

  /// Runs `llvm-objdump` on the given [object] and returns all lines produced
  /// by it.
  Stream<String> objdump({
    required String object,
    required String arch,
  }) async* {
    final process =
        await Process.start(_llvmObjdumpBinary, ['--arch=$arch', '-d', object]);

    await for (var line in process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      yield line;
    }
  }

  /// Run the given binary and return its stdout output if the run is
  /// successful. Otherwise throw an error.
  static Future<String> _run(String binary, List<String> args) async {
    final result = await Process.run(binary, args);
    if (result.exitCode != 0) {
      throw 'Failed to run ${p.basename(binary)} (${result.exitCode}):\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}';
    }
    return result.stdout;
  }
}

/// Information about a section extracted from ELF file.
class SectionInfo {
  final int fileOffset;
  final int fileSize;
  final int virtualAddress;

  SectionInfo({
    required this.fileOffset,
    required this.fileSize,
    required this.virtualAddress,
  });
}

final _platform = Platform.isLinux ? 'linux' : 'darwin';
final _ndkDir = 'tools/android-ndk';
final _llvmSymbolizerBinary =
    '$_ndkDir/toolchains/llvm/prebuilt/$_platform-x86_64/bin/llvm-symbolizer';
final _llvmObjdumpBinary =
    '$_ndkDir/toolchains/llvm/prebuilt/$_platform-x86_64/bin/llvm-objdump';
final _readelfBinary =
    '$_ndkDir/toolchains/llvm/prebuilt/$_platform-x86_64/bin/llvm-readelf';
final _buildIdPattern = RegExp(r'Build ID:\s+(?<id>[0-9a-f]+)');
final _loadCommandPattern = RegExp(
    r'^\s+LOAD\s+(?<offset>0x[0-9a-f]+)\s+(?<vma>0x[0-9a-f]+)\s+(?<phys>0x[0-9a-f]+)\s+(?<filesz>0x[0-9a-f]+)\s+(?<memsz>0x[0-9a-f]+)\s+(?<flags>[^0]+)\s+0x[0-9a-f]+\s*$',
    multiLine: true);
final _builderPathPattern =
    RegExp(r'^(?<root>/(b|opt)/s/w/[\w/]+/src)/out/\S+', multiLine: true);

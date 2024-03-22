// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Wrapper around ndk tools used for symbolization.
library symbolizer.ndk;

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

final _log = Logger('tools');

class Ndk {
  final LlvmTools llvmTools;

  Ndk({required this.llvmTools});

  /// Return information about .text section from the given [object] file.
  Future<SectionInfo> getTextSectionInfo(String object) async {
    final result =
        await _run(llvmTools.readobj, ['--elf-output-style=GNU', '-l', object]);
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
    final result =
        await _run(llvmTools.readobj, ['--elf-output-style=GNU', '-n', object]);
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
    final result = await _run(llvmTools.symbolizer, [
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
        await Process.start(llvmTools.objdump, ['--arch=$arch', '-d', object]);

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

class LlvmTools {
  final String symbolizer;
  final String objdump;
  final String readobj;

  LlvmTools._({
    required this.symbolizer,
    required this.readobj,
    required this.objdump,
  });

  @override
  String toString() => 'LlvmTools($symbolizer, $objdump, $readobj)';

  static LlvmTools? _at(String root) {
    _log.info(
        'checking for llvm-{symbolizer,readobj,objdump} in ${root.isEmpty ? '\$PATH' : root}');
    final tools = LlvmTools._(
        symbolizer: p.join(root, 'llvm-symbolizer'),
        readobj: p.join(root, 'llvm-readobj'),
        objdump: p.join(root, 'llvm-objdump'));
    return tools._checkOperational() ? tools : null;
  }

  bool _checkOperational() {
    bool checkBinary(String path) {
      try {
        final result = Process.runSync(path, ['--help']);
        return result.exitCode == 0 && result.stdout.startsWith('OVERVIEW: ');
      } catch (_) {
        return false;
      }
    }

    return checkBinary(symbolizer) &&
        checkBinary(objdump) &&
        checkBinary(readobj);
  }

  static LlvmTools? findTools() {
    final homeDir = Platform.environment['HOME'] ?? '';
    return LlvmTools._at('') ??
        _ndkTools('tools/android-ndk') ??
        _tryFindNdkAt(p.join(homeDir, 'Library/Android/sdk/ndk')) ??
        _tryFindNdkAt(p.join(homeDir, 'Android/Sdk/ndk'));
  }

  static LlvmTools? _tryFindNdkAt(String path) {
    try {
      final ndksDir = Directory(path);
      int majorVersion(String v) {
        return int.tryParse(v.split('.').first) ?? 0;
      }

      final ndkVersions = [
        for (var entry in ndksDir.listSync())
          if (entry is Directory) p.basename(entry.path),
      ]..sort((a, b) => majorVersion(b).compareTo(majorVersion(a)));

      return ndkVersions
          .map((name) => _ndkTools(p.join(path, name)))
          .whereType<LlvmTools>()
          .firstOrNull;
    } catch (_) {
      return null;
    }
  }

  static LlvmTools? _ndkTools(String path) {
    final platform = Platform.isLinux ? 'linux' : 'darwin';
    return LlvmTools._at(
        '$path/toolchains/llvm/prebuilt/$platform-x86_64/bin/');
  }
}

final _buildIdPattern = RegExp(r'Build ID:\s+(?<id>[0-9a-f]+)');
final _loadCommandPattern = RegExp(
    r'^\s+LOAD\s+(?<offset>0x[0-9a-f]+)\s+(?<vma>0x[0-9a-f]+)\s+(?<phys>0x[0-9a-f]+)\s+(?<filesz>0x[0-9a-f]+)\s+(?<memsz>0x[0-9a-f]+)\s+(?<flags>[^0]+)\s+0x[0-9a-f]+\s*$',
    multiLine: true);
final _builderPathPattern =
    RegExp(r'^(?<root>/(b|opt)/s/w/[\w/]+/src)/out/\S+', multiLine: true);

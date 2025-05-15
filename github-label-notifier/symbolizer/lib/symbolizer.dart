// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Symbolizer functionality
library symbolizer.symbolizer;

import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:github/github.dart';

import 'package:symbolizer/model.dart';
import 'package:symbolizer/ndk.dart';
import 'package:symbolizer/parser.dart';
import 'package:symbolizer/symbols.dart';

final _log = Logger('symbolizer');

class Symbolizer {
  final SymbolsCache symbols;
  final Ndk ndk;
  final GitHub github;
  final CrashExtractor crashExtractor;

  Symbolizer({
    required this.symbols,
    required this.ndk,
    required this.github,
    this.crashExtractor = const CrashExtractor(),
  });

  Future<SymbolizationResult> symbolize(String text,
      {SymbolizationOverrides? overrides}) async {
    try {
      return SymbolizationResult.ok(
          results: await _symbolizeImpl(text, overrides: overrides));
    } catch (e, st) {
      return SymbolizationResult.error(
          error: SymbolizationNote(
              kind: SymbolizationNoteKind.exceptionWhileParsing,
              message: '$e\n$st'));
    }
  }

  /// Process the given [text] to find all crashes and symbolize them.
  Future<List<CrashSymbolizationResult>> _symbolizeImpl(String text,
      {SymbolizationOverrides? overrides}) async {
    final crashes = crashExtractor.extractCrashes(text, overrides: overrides);
    if (crashes.isEmpty) {
      return [];
    }

    // First compute engine hash to use for symbolization.
    String? engineHash;
    try {
      engineHash = await _guessEngineHash(text, overrides);
    } catch (e, st) {
      return _failedToSymbolizeAll(
          crashes, SymbolizationNoteKind.exceptionWhileGettingEngineHash,
          error: '$e\n$st');
    }
    if (engineHash == null) {
      return _failedToSymbolizeAll(
          crashes, SymbolizationNoteKind.unknownEngineHash);
    }

    final result = <CrashSymbolizationResult>[];
    for (var crash in crashes) {
      try {
        result.add(await _symbolizeCrash(crash, engineHash, overrides));
      } catch (e, st) {
        result.add(_failedToSymbolize(
            crash, SymbolizationNoteKind.exceptionWhileSymbolizing,
            error: '$e\n$st'));
      }
    }
    return result;
  }

  Future<String?> _guessEngineHash(
      String text, SymbolizationOverrides? overrides) async {
    // Try to establish engine hash based on the content.
    var engineHash = overrides?.engineHash ??
        _reEngineHash.firstMatch(text)?.namedGroup('shortHash');
    if (engineHash == null && overrides?.flutterVersion != null) {
      engineHash =
          await _engineHashFromFlutterVersion(overrides!.flutterVersion);
    }
    if (engineHash != null) {
      // Try to expand short hash into full hash.
      var engineCommit;
      try {
        engineCommit = await github.repositories
            .getCommit(RepositorySlug('flutter', 'flutter'), engineHash);
      } catch (e) {
        print(
            'Got $e while looking for a commit in flutter/flutter, trying pre-monorepo flutter/engine');
        engineCommit = await github.repositories
            .getCommit(RepositorySlug('flutter', 'engine'), engineHash);
      }
      engineHash = engineCommit.sha;
    }
    if (engineHash == null) {
      // Try to establish engineHash based on Flutter version
      final m = _reFlutterVersion.firstMatch(text);
      if (m != null && m.namedGroup('channel') != 'master') {
        // Try to use version tag.
        final tag = m.namedGroup('version');
        engineHash = await _engineHashFromFlutterVersion(tag);
      }
    }
    return engineHash;
  }

  Future<String?> _engineHashFromFlutterVersion(String? version) async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/flutter/flutter/$version/bin/internal/engine.version'));
    if (response.statusCode == HttpStatus.ok) {
      return response.body.trim();
    }
    return null;
  }

  Future<CrashSymbolizationResult> _symbolizeCrashWith(
      Crash crash, EngineBuild engineBuild) async {
    try {
      final symbolsDir = await symbols.get(engineBuild);
      return await _symbolizeCrashWithGivenSymbols(
          crash, symbolsDir, engineBuild);
    } catch (e, st) {
      return _failedToSymbolize(
          crash, SymbolizationNoteKind.exceptionWhileSymbolizing,
          error: '{$engineBuild} $e\n$st');
    }
  }

  Future<CrashSymbolizationResult> _symbolizeCrash(
      Crash crash, String engineHash, SymbolizationOverrides? overrides) async {
    // Apply overrides
    if (crash.engineVariant.arch == null) {
      return _failedToSymbolize(crash, SymbolizationNoteKind.unknownAbi);
    }

    EngineBuild engineBuild;

    final buildId = _findBuildIdInFrames(crash.frames);
    // Even if buildId is available we don't use it for matching
    // if mode was found heuristically or was specified through overrides
    // already.
    if (crash.engineVariant.mode != null ||
        overrides?.mode != null ||
        buildId == null) {
      // Currently on iOS we only have symbols for release builds.
      if (crash.engineVariant.os == 'ios') {
        if (crash.engineVariant.mode != 'release') {
          return _failedToSymbolize(
              crash, SymbolizationNoteKind.noSymbolsAvailableOnIos);
        }
      }

      engineBuild = EngineBuild(
        engineHash: engineHash,
        variant: crash.engineVariant.copyWith(
            mode: crash.engineVariant.mode ?? overrides?.mode ?? 'release'),
      );

      // Note: on iOS build ids (LC_UUID) don't seem to match between
      // archived dSYMs and what users report, so we can't rely on them
      // for matching dSYMs to crash reports.
    } else {
      try {
        engineBuild = await symbols.findVariantByBuildId(
            variant: crash.engineVariant,
            engineHash: engineHash,
            buildId: buildId);
      } catch (e) {
        return _failedToSymbolize(
            crash, SymbolizationNoteKind.exceptionWhileLookingByBuildId,
            error: 'build-id: $buildId\n$e');
      }
    }

    var result = await _symbolizeCrashWith(crash, engineBuild);

    if (result.symbolized != null &&
        buildId == null &&
        overrides?.mode == null &&
        (crash.engineVariant.mode == null ||
            crash.engineVariant.mode != 'release')) {
      result = result
          .withNote(SymbolizationNoteKind.defaultedToReleaseBuildIdUnavailable);
    }

    // We might have used wrong symbols for symbolization (because we were
    // forced or because our heuristics failed for some reason).
    if (buildId != null) {
      final symbolsDir = await symbols.get(engineBuild);
      final engineBuildId =
          await ndk.getBuildId(p.join(symbolsDir, 'libflutter.so'));
      if (engineBuildId != buildId) {
        result = result.withNote(SymbolizationNoteKind.buildIdMismatch,
            'Backtrace refers to $buildId but we used engine with $engineBuildId');
      }
    }

    return result;
  }

  static String? _findBuildIdInFrames(List<CrashFrame> frames) => frames
      .whereType<AndroidCrashFrame>()
      .firstWhereOrNull((frame) =>
          frame.binary.endsWith('libflutter.so') && frame.buildId != null)
      ?.buildId;

  Future<CrashSymbolizationResult> _symbolizeCrashWithGivenSymbols(
      Crash crash, String symbolsDir, EngineBuild build) {
    final result = CrashSymbolizationResult(
        engineBuild: build, crash: crash, symbolized: null);
    if (crash.format == 'dartvm') {
      return _symbolizeDartvmFrames(
        result,
        crash.frames.cast<DartvmCrashFrame>(),
        crash.engineVariant.arch,
        symbolsDir,
      );
    } else if (crash.format == 'custom') {
      return _symbolizeCustomFrames(
        result,
        crash.frames.cast<CustomCrashFrame>(),
        crash.engineVariant.arch,
        build,
        symbolsDir,
      );
    } else if (crash.engineVariant.os == 'android') {
      return _symbolizeAndroidFrames(
        result,
        crash.frames.cast<AndroidCrashFrame>(),
        crash.engineVariant.arch,
        symbolsDir,
        crash.androidMajorVersion,
      );
    } else {
      return _symbolizeIosFrames(
        result,
        crash.frames.cast<IosCrashFrame>(),
        crash.engineVariant.arch,
        build,
        symbolsDir,
      );
    }
  }

  Future<CrashSymbolizationResult>
      _symbolizeGeneric<FrameType extends CrashFrame>({
    required CrashSymbolizationResult result,
    required List<FrameType> frames,
    required String? arch,
    required String object,
    required bool Function(FrameType) shouldSymbolize,
    required int Function(FrameType) getRelativePC,
    required FutureOr<int> Function(Iterable<FrameType>) computePCBias,
    required String Function(FrameType) frameSuffix,
    required bool shouldAdjustInnerPCs,
  }) async {
    _log.info('Symbolizing using $object');

    final worklist = <int>{};

    // First collect Flutter Engine frames.
    final binaryName = p.basename(object);
    for (var i = 0; i < frames.length; i++) {
      if (frames[i].binary.endsWith(binaryName) && shouldSymbolize(frames[i])) {
        worklist.add(i);
      }
    }

    final symbolized = <int, String>{};
    if (worklist.isNotEmpty) {
      final vmaBias = await computePCBias(worklist.map((i) => frames[i]));
      symbolized.addAll(Map.fromIterables(
          worklist,
          await ndk.symbolize(
              object: object,
              arch: arch,
              addresses: worklist
                  .map((i) {
                    return getRelativePC(frames[i]) +
                        vmaBias +
                        (shouldAdjustInnerPCs && i > 0 ? -1 : 0);
                  })
                  .map(_asHex)
                  .toList())));
    }

    // Assemble the result.
    final pcSize = _pointerSize(arch);
    final buf = StringBuffer();
    for (var i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final prefix =
          '#${i.toString().padLeft(2, '0')} ${_addrHex(frame.pc, pcSize)} ${_shortBinaryName(frame.binary)}';
      buf.write(prefix);
      buf.writeln(frameSuffix(frame));
      if (worklist.contains(i)) {
        final indent = ' ' * (prefix.length + 1);
        for (var line in symbolized[i]!.split('\n')) {
          buf.write(indent);
          buf.writeln(line);
        }
      }
    }

    return result.copyWith(symbolized: buf.toString());
  }

  Future<CrashSymbolizationResult> _symbolizeAndroidFrames(
    CrashSymbolizationResult result,
    List<AndroidCrashFrame> frames,
    String? arch,
    String symbolsDir,
    int? androidMajorVersion,
  ) async {
    final flutterSo = p.join(symbolsDir, 'libflutter.so');
    return _symbolizeGeneric<AndroidCrashFrame>(
      result: result,
      frames: frames,
      arch: arch,
      object: flutterSo,
      shouldSymbolize: (_) => true,
      getRelativePC: (frame) => frame.pc,
      shouldAdjustInnerPCs: false, // Android unwinder already adjusted it.
      computePCBias: (frames) async {
        if ((androidMajorVersion ?? 0) >= 11) {
          return 0;
        }
        // Prior to Android 11 backtraces printed by debuggerd contained PCs
        // which can't be directly used for symbolization. Very old versions
        // of Android printed offsets into RX mapping, while newer versions
        // printed ELF file offsets. We try to differentiate between these two
        // situations by checking if any PCs are outside of .text section range.
        // In both cases we can't directly use this PC for symbolization because
        // it does not necessarily match VMAs used in the ELF file (which is
        // what llvm-symbolizer would need for symbolization).
        final textSection = await ndk.getTextSectionInfo(flutterSo);
        final textStart = textSection.fileOffset;
        final textEnd = textSection.fileOffset + textSection.fileSize;
        final likelySectionOffset =
            !frames.every((f) => textStart <= f.pc && f.pc < textEnd);
        return likelySectionOffset
            ? (textSection.virtualAddress & ~0xfff)
            : (textSection.virtualAddress - textSection.fileOffset);
      },
      frameSuffix: (frame) => ' ${frame.rest.trimLeft()}',
    );
  }

  Future<CrashSymbolizationResult> _symbolizeDartvmFrames(
      CrashSymbolizationResult result,
      List<DartvmCrashFrame> frames,
      String? arch,
      String symbolsDir) async {
    final flutterSo = p.join(symbolsDir, 'libflutter.so');
    return _symbolizeGeneric<DartvmCrashFrame>(
      result: result,
      frames: frames,
      arch: arch,
      object: flutterSo,
      shouldSymbolize: (_) => true,
      getRelativePC: (frame) => frame.offset,
      shouldAdjustInnerPCs: true,
      computePCBias: (frames) async {
        // For now we assume that we only get Dart VM crash stacks from Android.
        //
        // There we get output like libflutter.so+offset where offset is
        // PC minus base of libflutter.so (as returned by dladdr), which
        // corresponds to the address of the first page mapped from ELF file.
        //
        // Important thing to note here is that RX mapping would use aligned
        // file offset (textSection.fileOffset & ~pageMask). This might increase
        // the distance between SO base and PC by 1 page if testSection.fileOffset
        // is not aligned:
        //
        //   RO             RX      PC
        //   [             ][       *      ]
        //   |              |
        //   B              B + fileOffset
        //   0
        //
        // If fileOffset is misaligned then subtracting B from PC does not yield
        // file offset corresponding to the PC, but rather file offset plus
        // pageSize, so we need to accomodate for that in VMA adjustment.
        const pageSize = 4096;
        const pageMask = pageSize - 1;

        final textSection = await ndk.getTextSectionInfo(flutterSo);
        final loadBias = textSection.virtualAddress - textSection.fileOffset;
        return loadBias -
            (((textSection.fileOffset & pageMask) + pageMask) & ~pageMask);
      },
      frameSuffix: (frame) => '+${_asHex(frame.offset)}',
    );
  }

  /// Pattern for extracting information from ARM64 objdump output.
  static final _objdumpPattern =
      RegExp(r'^\s*(?<addr>[a-f0-9]+):\s+([a-f0-9]{2}\s+){4}(?<op>\w+)');

  /// Extract information about calls (branch-link instruction) locations
  /// in the binary.
  Future<_CallLocations?> _determineCallLocations(EngineBuild build) async {
    if (build.variant.arch != 'arm64') {
      return null;
    }

    final flutterSo = await symbols.getEngineBinary(build);

    int? startAddr, endAddr;
    final isCallAt = <bool>[];
    await for (var line in ndk.objdump(object: flutterSo, arch: 'arm64')) {
      final m = _objdumpPattern.firstMatch(line);
      if (m == null) continue;

      final addr = int.parse(m.namedGroup('addr')!, radix: 16);
      startAddr ??= addr;
      endAddr = addr;
      final op = m.namedGroup('op')!;
      isCallAt.add(op.startsWith('bl'));
    }
    if (startAddr == null || endAddr == null) {
      return null;
    }
    final codeSize = endAddr - startAddr + 4;
    if (codeSize != isCallAt.length * 4) {
      // Something went wrong.
      return null;
    }

    return _CallLocations(startAddr, isCallAt);
  }

  /// Try to guess load base for flutter engine shared object using
  /// information about possible call locations in the binary and the
  /// list of return addresses in the backtrace.
  ///
  /// We are going to look through the binary trying to find call locations
  /// which have the same relative offsets to each other as the given pcs.
  /// Each such group gives us potential load base.
  Future<_LoadBase?> _tryFindLoadBase(
      EngineBuild build, List<int> retAddrs) async {
    _log.info('looking for load base of $build based on $retAddrs');
    if (retAddrs.length < 2) {
      return null; // Need at least two retAddrs.
    }

    // We don't expect any misaligned retAddrs, but some Crashlytics reports
    // contain such. Give up for now.
    if (retAddrs.any((e) => e & 3 != 0)) {
      return null;
    }

    final calls = await _determineCallLocations(build);
    if (calls == null) {
      return null;
    }

    var loadBase = _tryFindLoadBaseImpl(build, retAddrs, calls);
    if (loadBase != null) {
      return _LoadBase(loadBase: loadBase, pcAdjusted: false);
    }

    // Maybe unwinder already adjusted return addressed by -4.
    loadBase = _tryFindLoadBaseImpl(
        build, retAddrs.map((pc) => pc + 4).toList(), calls);
    if (loadBase != null) {
      return _LoadBase(loadBase: loadBase, pcAdjusted: true);
    }

    return null;
  }

  int? _tryFindLoadBaseImpl(
      EngineBuild build, List<int> retAddrs, _CallLocations calls) {
    const arm64InstrSize = 4;
    const arm64InstrShift = 2;
    const pageSize = 0x1000;
    const pageMask = pageSize - 1;

    final retAddr = retAddrs.first;
    final possibleBases = <int>[];

    // Look through the binary for all calls such that pc - callAddr (which can be
    // computed as `calls.startAddr + callIdx * arm64InstrSize`) is page aligned
    // (this difference yields us possible base).
    // We start by selecting base in such a way that the retAddr falls on the
    // first page of the .text section and then start moving base down in
    // pageSize increments.
    final callVma = retAddr - arm64InstrSize - calls.startAddr;
    for (var callIdx = (callVma & pageMask) >> arm64InstrShift,
            base = callVma & ~pageMask;
        callIdx < calls.size && base >= 0;
        callIdx += pageSize >> arm64InstrShift, base -= pageSize) {
      if (calls._isCallAt[callIdx]) {
        if (retAddrs
            .every((pc) => calls.isCallAt(pc - arm64InstrSize - base))) {
          // Possible base: pc - arm64InstrSize - base hits call in the
          // binary for all retAddrs.
          possibleBases.add(base);
        }
      }
    }

    // Single possible base found - return it.
    if (possibleBases.length == 1) {
      _log.info('found load base of $build based on $retAddrs: '
          '${possibleBases.first}');
      return possibleBases.first;
    }

    // Either no bases or more than a single possibility found.
    _log.info(
        'found ${possibleBases.isEmpty ? 'no' : 'multiple'} potential load '
        'bases of $build based on $retAddrs: $possibleBases');
    return null;
  }

  Future<CrashSymbolizationResult> _symbolizeIosFrames(
      CrashSymbolizationResult result,
      List<IosCrashFrame> frames,
      String? arch,
      EngineBuild build,
      String symbolsDir) async {
    final object =
        p.join(symbolsDir, 'Flutter.dSYM/Contents/Resources/DWARF/Flutter');

    // Returns [true] if the given frame is a frame for Flutter
    // engine binary which misses an offset.
    bool isFrameMissingOffset(IosCrashFrame frame) {
      return frame.offset == null &&
          frame.binary == 'Flutter' &&
          frame.symbol == CrashFrame.crashalyticsMissingSymbol;
    }

    var adjustInnerPCs = true;

    // If there are frames with missing offsets found try to guess
    // load base using a heuristic based on all return addresses from the
    // backtrace.
    final framesWithoutOffsets = frames.where(isFrameMissingOffset).toList();
    if (framesWithoutOffsets.isNotEmpty) {
      final loadBase = await _tryFindLoadBase(
          build,
          framesWithoutOffsets
              .where((frame) => int.parse(frame.no) > 0)
              .map((frame) => frame.pc)
              .toSet()
              .toList());
      if (loadBase != null) {
        // Success: managed to find a single possiblity. Compute relative pcs
        // using this loadBase and add a note to the symbolization result.
        adjustInnerPCs = !loadBase.pcAdjusted;
        result = result.withNote(SymbolizationNoteKind.loadBaseDetected,
            _addrHex(loadBase.loadBase, _pointerSize(build.variant.arch)));
        frames = frames.map((frame) {
          if (isFrameMissingOffset(frame)) {
            return frame.copyWith(
              offset: frame.pc - loadBase.loadBase,
              symbol: 'Flutter',
            );
          }
          return frame;
        }).toList();
      }
    }

    return _symbolizeGeneric<IosCrashFrame>(
      result: result,
      frames: frames,
      arch: arch,
      object: object,
      shouldSymbolize: (frame) =>
          frame.symbol == 'Flutter' || frame.symbol.startsWith('0x'),
      shouldAdjustInnerPCs: adjustInnerPCs,
      getRelativePC: (frame) => frame.offset!,
      computePCBias: (frames) => 0,
      frameSuffix: (frame) => [
        '',
        frame.symbol,
        if (frame.offset != null) '+',
        if (frame.offset != null) frame.offset,
        if (frame.location.isNotEmpty) '(${frame.location.trimLeft()})',
      ].join(' '),
    );
  }

  Future<CrashSymbolizationResult> _symbolizeCustomFrames(
      CrashSymbolizationResult result,
      List<CustomCrashFrame> frames,
      String? arch,
      EngineBuild build,
      String symbolsDir) async {
    // For now we assuem
    final object = p.join(
        symbolsDir,
        build.variant.os == 'ios'
            ? 'Flutter.dSYM/Contents/Resources/DWARF/Flutter'
            : 'libflutter.so');

    // Returns [true] if the given frame is a frame for Flutter
    // engine binary which misses an offset.
    bool isFrameMissingOffset(CustomCrashFrame frame) {
      return /*frame.offset == null &&*/ frame.binary == 'Flutter';
    }

    var adjustInnerPCs = true;

    // If there are frames with missing offsets found try to guess
    // load base using a heuristic based on all return addresses from the
    // backtrace.
    final framesWithoutOffsets = frames.where(isFrameMissingOffset).toList();
    if (framesWithoutOffsets.isNotEmpty) {
      final loadBase = await _tryFindLoadBase(
          build,
          framesWithoutOffsets
              .where((frame) => int.parse(frame.no) > 0)
              .map((frame) => frame.pc)
              .toSet()
              .toList());
      if (loadBase != null) {
        // Success: managed to find a single possiblity. Compute relative pcs
        // using this loadBase and add a note to the symbolization result.
        adjustInnerPCs = !loadBase.pcAdjusted;
        result = result.withNote(SymbolizationNoteKind.loadBaseDetected,
            _addrHex(loadBase.loadBase, _pointerSize(build.variant.arch)));
        frames = frames.map((frame) {
          if (isFrameMissingOffset(frame)) {
            return frame.copyWith(
              offset: frame.pc - loadBase.loadBase,
              symbol: 'Flutter',
            );
          }
          return frame;
        }).toList();
      }
    }

    return _symbolizeGeneric<CustomCrashFrame>(
      result: result,
      frames: frames,
      arch: arch,
      object: object,
      shouldSymbolize: (frame) => true,
      shouldAdjustInnerPCs: adjustInnerPCs,
      getRelativePC: (frame) => frame.offset!,
      computePCBias: (frames) => 0,
      frameSuffix: (frame) => [
        '',
        if (frame.symbol != null && frame.symbol!.isNotEmpty)
          frame.symbol
        else
          frame.binary,
        if (frame.offset != null) '+',
        if (frame.offset != null) frame.offset,
        if (frame.location != null) frame.location!.trimLeft(),
      ].join(' '),
    );
  }
}

final _appBinaryPattern = RegExp(r'^/data/app/(~~[^/]+/)?[^/]+/(?<name>.*)$');
String _shortBinaryName(String binary) {
  final m = _appBinaryPattern.firstMatch(binary);
  if (m != null) {
    return '<...>/${m.namedGroup('name')}';
  }
  return binary;
}

int _pointerSize(String? arch) {
  switch (arch) {
    case 'arm64':
    case 'x64':
      return 8 * 2;
    default:
      return 4 * 2;
  }
}

String _addrHex(int v, int pointerSize) =>
    v.toRadixString(16).padLeft(pointerSize, '0');

String _asHex(int v) => '0x${v.toRadixString(16)}';

List<CrashSymbolizationResult> _failedToSymbolizeAll(
        List<Crash> crashes, SymbolizationNoteKind note, {Object? error}) =>
    crashes
        .map((crash) => _failedToSymbolize(crash, note, error: error))
        .toList();

CrashSymbolizationResult _failedToSymbolize(
        Crash crash, SymbolizationNoteKind note,
        {Object? error}) =>
    CrashSymbolizationResult(
      crash: crash,
      engineBuild: null,
      symbolized: null,
      notes: [SymbolizationNote(kind: note, message: error?.toString())],
    );

final _reEngineHash =
    RegExp(r'(• Engine|Engine •) revision (?<shortHash>[a-f0-9]+)');
final _reFlutterVersion = RegExp(
    r'Flutter \(Channel (?<channel>master|dev|beta|stable), (?<version>[^,]+),');

/// Information about call locations within the flutter engine binary.
/// Used to heuristically guess load base for flutter engine when it is
/// not available in the output.
///
/// Currently heuristics only work on ARM64, which allows us to assume
/// fixed instruction size (4 bytes).
class _CallLocations {
  /// Base VMA for the .text section.
  final int startAddr;

  /// Contains [true] if instruction with the given index is a branch-link (bl).
  final List<bool> _isCallAt;

  _CallLocations(this.startAddr, this._isCallAt);

  int get size => _isCallAt.length;

  bool isCallAt(int addr) {
    if (addr < startAddr) return false;
    final i = (addr - startAddr) >> 2;
    return i < size && _isCallAt[i];
  }
}

class _LoadBase {
  final int loadBase;
  final bool pcAdjusted;
  _LoadBase({required this.loadBase, required this.pcAdjusted});
}

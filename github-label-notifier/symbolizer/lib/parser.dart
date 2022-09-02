// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Logic for extracting crashes from text.
library symbolizer.parser;

import 'package:symbolizer/model.dart';

/// Returns [true] if the given text is likely to contain a crash.
bool containsCrash(String text) {
  return text.contains(_CrashExtractor._androidCrashMarker) ||
      text.contains(_CrashExtractor._iosCrashMarker);
}

class CrashExtractor {
  const CrashExtractor();

  /// Extract all crashes from the given [text] using [overrides].
  List<Crash> extractCrashes(String text,
          {SymbolizationOverrides? overrides}) =>
      _CrashExtractor(text: text, overrides: overrides).crashes;
}

class _CrashExtractor {
  final List<String> lines;
  final SymbolizationOverrides? overrides;

  final List<Crash> crashes = <Crash>[];

  int lineNo = 0;

  String? os;
  String? arch;
  String? mode;
  String? format;
  List<CrashFrame> frames = [];

  RegExp? logLinePattern;
  bool collectingFrames = false;
  int? androidMajorVersion;

  _CrashExtractor({required String text, this.overrides})
      : lines = text.split(_lineEnding) {
    final overrides = this.overrides;
    if (overrides != null) {
      final os = overrides.os;
      if (overrides.format == 'internal' && os != null) {
        parseAsCustomBacktrace(_internalFramePattern, os);
        return;
      } else if (overrides.force && os == 'ios') {
        parseAsIosBacktrace();
        return;
      }
    }

    // Default processing.
    processLines();
  }

  /// Extract only stack traces from the text which match the given regexp.
  /// Used when 'internal' override is in effect.
  void parseAsCustomBacktrace(RegExp pattern, String os) {
    for (; lineNo < lines.length; lineNo++) {
      final line = lines[lineNo];
      final frameMatch = pattern.firstMatch(line);

      if (frameMatch == null) {
        if (collectingFrames) {
          endCrash();
        }
        continue;
      }

      if (!collectingFrames) {
        startCrash(os);
        mode = 'release';
        format = 'custom';
        collectingFrames = true;
      }

      frames.add(CrashFrame.custom(
        no: frames.length.toString().padLeft(2, '0'),
        binary: frameMatch.namedGroup('binary')!,
        pc: int.parse(frameMatch.namedGroup('pc')!),
        symbol: frameMatch.namedGroup('symbol'),
        offset: frameMatch.namedGroup('offset') != null
            ? int.parse(frameMatch.namedGroup('offset')!)
            : null,
        location: frameMatch.namedGroup('location'),
      ));
    }
    endCrash();
  }

  /// Extract only iOS like stack traces from the text. Used when
  /// 'force ios' override is in effect.
  void parseAsIosBacktrace() {
    for (; lineNo < lines.length; lineNo++) {
      final line = lines[lineNo];

      var frame = parseIosFrame(line);

      if (frame == null) {
        if (collectingFrames) {
          endCrash();
        }
        continue;
      }

      // Force resymbolization of frames that correspond to the Flutter
      // framework by discarding symbol information already contained in
      // the stack trace.
      if (frame.binary == 'Flutter' && frame.symbol != 'Flutter') {
        frame = frame.copyWith(
            offset: null, symbol: CrashFrame.crashalyticsMissingSymbol);
      }

      // Allow frames that miss offset and instead contain `(Missing)`
      // instead of symbol name. This can happen in crashalytics output.
      if (frame.offset == null &&
          frame.symbol != CrashFrame.crashalyticsMissingSymbol) {
        continue;
      }

      if (!collectingFrames) {
        startCrash('ios');
        mode = 'release';
        collectingFrames = true;
      }

      frames.add(frame);
    }
    endCrash();
  }

  IosCrashFrame? parseIosFrame(String line) {
    final frameMatch = _iosFramePattern.firstMatch(line);
    if (frameMatch == null) {
      return null;
    }
    var rest = frameMatch.namedGroup('rest')!.trim();
    var location = '';
    if (rest.endsWith(')')) {
      final open = rest.lastIndexOf('(');
      if (open > 0) {
        location = rest.substring(open + 1, rest.length - 2);
        rest = rest.substring(0, open).trim();
      }
    }
    final offsetMatch = _offsetSuffixPattern.firstMatch(rest);
    String symbol;
    int? offset;
    if (offsetMatch != null) {
      // In some rare cases offset would be computed against load base of 0
      // in which case int.parse would refuse to parse it (because it is
      // a decimal integer outside of range for signed 64-bit integer).
      // Ignore such cases.
      offset = int.tryParse(offsetMatch.namedGroup('offset')!);
      symbol = offsetMatch.namedGroup('symbol')!.trim();
    } else {
      symbol = rest.trim();
    }

    return IosCrashFrame(
      no: frameMatch.namedGroup('no')!,
      binary: frameMatch.namedGroup('binary')!,
      pc: int.parse(frameMatch.namedGroup('pc')!),
      symbol: symbol,
      offset: offset,
      location: location,
    );
  }

  void processLines() {
    for (; lineNo < lines.length; lineNo++) {
      var line = lines[lineNo];

      // Strip markdown quote.
      if (line.startsWith('> ')) {
        line = line.substring(2);
      }

      // If we have an indication that we are processing raw logcat or flutter
      // verbose output then strip the prefix characteristic for those log
      // types.
      if (logLinePattern != null) {
        final m = logLinePattern!.firstMatch(line);
        if (m != null) {
          line = m.namedGroup('rest')!;
        } else {
          // No longer in the raw log output. If we started collecting a crash
          // flush it and continue handling the line.
          endCrash();
        }
      }

      if (line.isEmpty) {
        continue;
      }

      // First check for crash markers.
      if (line.contains(_androidCrashMarker)) {
        // Start of the Android crash.
        startCrash('android');
        continue;
      }

      if (line.contains(_iosCrashMarker)) {
        // Start of the iOS crash.
        startCrash('ios');
        continue;
      }

      final dartvmCrashMatch = _dartvmCrashMarker.firstMatch(line);
      if (dartvmCrashMatch != null) {
        startCrash(dartvmCrashMatch.namedGroup('os')!);
        format = 'dartvm';
        arch = dartvmCrashMatch.namedGroup('arch');
        if (arch == 'ia32') {
          arch = 'x86';
        }
        continue;
      }

      if (format == 'dartvm') {
        if (line.contains(_endOfDumpStackTracePattern)) {
          endCrash();
          continue;
        }

        final frameMatch = _dartvmFramePattern.firstMatch(line);
        if (frameMatch != null) {
          frames.add(CrashFrame.dartvm(
            pc: int.parse(frameMatch.namedGroup('pc')!),
            binary: frameMatch.namedGroup('binary')!,
            offset: int.parse(frameMatch.namedGroup('offset')!),
          ));
        }
      }

      if (os == 'android') {
        // Handle `Build fingerprint: '...'` line.
        final androidVersion = _androidBuildFingerprintPattern
            .firstMatch(line)
            ?.namedGroup('version');
        if (androidVersion != null) {
          androidMajorVersion = int.tryParse(androidVersion.split('.').first);
        }

        // Handle `ABI: '...'` line.
        final abiMatch = _androidAbiPattern.firstMatch(line);
        if (abiMatch != null) {
          arch = abiMatch.namedGroup('abi');
          if (arch == 'x86_64') {
            arch = 'x64';
          }
          continue;
        }

        // Handle backtrace: start.
        if (_backtraceStartPattern.hasMatch(line)) {
          collectingFrames = true;
          continue;
        }

        // If backtrace has started then process line corresponding for a frame.
        if (collectingFrames) {
          final frameMatch = _androidFramePattern.firstMatch(line);
          if (frameMatch != null) {
            final rest = frameMatch.namedGroup('rest')!;
            final buildIdMatch = _buildIdPattern.firstMatch(rest);
            frames.add(CrashFrame.android(
              no: frameMatch.namedGroup('no')!,
              pc: int.parse(frameMatch.namedGroup('pc')!, radix: 16),
              binary: frameMatch.namedGroup('binary')!,
              rest: rest,
              buildId: buildIdMatch?.namedGroup('id'),
            ));
          } else {
            endCrash();
          }
        }
        continue;
      }

      if (os == 'ios') {
        // Handle EOF marking the end of crash report.
        if (line.contains(_eofPattern)) {
          endCrash();
          continue;
        }

        // Handle line that describes App.framework binary image.
        // We use it as a marker to detect release mode builds.
        if (line.contains(_appFrameworkPattern)) {
          mode = 'release';
          continue;
        }

        // Handle `Code Type: ...` line.
        final abiMatch = _iosAbiPattern.firstMatch(line);
        if (abiMatch != null) {
          arch = abiMatch.namedGroup('abi') == 'ARM-64' ? 'arm64' : 'arm32';
          continue;
        }

        // Handle `Thread ... Crashed:` line
        if (line.contains(_crashedThreadPattern)) {
          collectingFrames = true;
          continue;
        }

        if (collectingFrames) {
          final frame = parseIosFrame(line);
          if (frame != null) {
            frames.add(frame);
          } else {
            collectingFrames = false;
            // Don't flush the crash yet - we want to read report until the
            // end and check if it is a release build or not.
          }
        }

        continue;
      }
    }

    endCrash();
  }

  void startCrash(String os) {
    endCrash();
    this.os = os;
    frames = <CrashFrame>[];
    arch = mode = null;
    logLinePattern = null;
    collectingFrames = false;
    format = 'native';
    androidMajorVersion = null;
    if (os == 'android') {
      detectAndroidLogFormat();
    }
  }

  void endCrash() {
    // We are not interested in crashes where we did not collect any frames.
    if (frames.isNotEmpty) {
      if (os == 'android') {
        androidMajorVersion ??= guessAndroidVersion();
      }

      crashes.add(Crash(
        engineVariant: EngineVariant(
          os: os!,
          arch: overrides?.arch ?? arch,
          mode: overrides?.mode ?? mode,
        ),
        frames: frames,
        format: format!,
        androidMajorVersion: androidMajorVersion,
      ));
    }
    frames = [];
    collectingFrames = false;
    logLinePattern = null;
  }

  /// Android crashes might come from `adb logcat` or `flutter run -v`
  /// output. In which case we need to strip prefix characteristic for
  /// those.
  void detectAndroidLogFormat() {
    final line = lines[lineNo];
    if (line.contains(_flutterLogPattern)) {
      logLinePattern = _flutterLogPattern;
      guessLaunchMode();
    } else if (line.contains(_deviceLabPattern)) {
      logLinePattern = _deviceLabPattern;
      guessLaunchMode();
    } else if (line.contains(_logcatPattern)) {
      logLinePattern = _logcatPattern;
    }
  }

  int? guessAndroidVersion() {
    // On Android 11 has introduced a change[1] which mangles APK install
    // locations with a random prefix (and suffix). We can use the presence of
    // this prefix to detect that we are running on Android 11 or above.
    //
    // [1]: https://partner-android.googlesource.com/platform/frameworks/base/+/f56f1c5c587ed5af452ed1b339218dabc12c9f93
    if (frames.any((f) => f.binary.startsWith('/data/app/~~'))) {
      return 11;
    }
    return null; // Can't guess.
  }

  void guessLaunchMode() {
    if (overrides?.mode != null) {
      return;
    }

    // Try to look backwards through log lines to determine launch mode.
    for (var i = lineNo - 1; i >= 0; i--) {
      final logLineMatch = logLinePattern!.firstMatch(lines[i]);
      if (logLineMatch == null) {
        break;
      }
      final modeMatch =
          _launchModePattern.firstMatch(logLineMatch.namedGroup('rest')!);
      if (modeMatch != null) {
        mode = modeMatch.namedGroup('mode');
        return;
      }
    }
  }

  static final _androidCrashMarker =
      '*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***';

  static final _iosCrashMarker = RegExp(
      r'(Incident Identifier:\s+([A-F0-9]+-?)+)|(Exception Type:\s+EXC_CRASH)');

  static final _dartvmCrashMarker =
      RegExp(r'version=.*on "(?<os>android)_(?<arch>arm|arm64|ia32|x64)"\s*$');

  static final _lineEnding = RegExp(r'\r?\n');
  static final _logcatPattern = RegExp(r'^.*?:(?=$|\s)\s*(?<rest>.*)$');
  static final _flutterLogPattern =
      RegExp(r'^\s*\[\s*(\+?\s*\d+\s*(s|ms|h))?\]\s+(?<rest>.*)$');
  static final _deviceLabPattern = RegExp(
      r'(\d+-\d+-\d+T\d+:\d+:\d+.\d+: )?(stdout|stderr):\s*\[\s*(\+?\s*\d+\s*(s|ms|h))?\]\s+(?<rest>.*)');

  static final _androidAbiPattern =
      RegExp(r"^\s*ABI: '(?<abi>x86|x86_64|x64|arm|arm64)'\s*$");

  // Android Compatibility Definition mandates build fingerprint format to be:
  //
  //   $(BRAND)/$(PRODUCT)/$(DEVICE):
  //     $(VERSION.RELEASE)/$(ID)/$(VERSION.INCREMENTAL):$(TYPE)/$(TAGS)
  //
  // For our purposes we are only interested in VERSION.RELEASE component of the
  // fingerprint.
  //
  // See https://source.android.com/compatibility/11/android-11-cdd
  static final _androidBuildFingerprintPattern =
      RegExp(r"Build fingerprint: '[^:']+:(?<version>[\d\.]+)/[^']*'");
  static final _backtraceStartPattern = RegExp(r'^\s*backtrace:\s*$');
  static final _androidFramePattern = RegExp(
      r'^\s*#(?<no>\d+)\s+pc\s+(0x)?(?<pc>[0-9a-f]+)\s+(?<binary>[^\s]+)(?<rest>.*)$');
  static final _buildIdPattern = RegExp(r'\(BuildId: (?<id>[0-9a-f]+)\)');
  static final _launchModePattern =
      RegExp(r'^\s*Launching .* on .* in (?<mode>debug|release|profile) mode');

  static final _eofPattern = RegExp(r'^\s*EOF\s*$');
  static final _appFrameworkPattern = RegExp(
      r'^\s*0x[a-f0-9]+\s+-\s+0x[a-f0-9]+\s+App\s+arm\w+\s+<[a-f0-9]+>\s+/var/containers');
  static final _iosAbiPattern = RegExp(r'\s*Code\s+Type:\s+(?<abi>[\-\w]+)\s+');
  static final _crashedThreadPattern = RegExp(r'^\s*Thread \d+ Crashed:');
  static final _iosFramePattern = RegExp(
      r'^\s*(?<no>\d+)\s+(?<binary>\S+)\s+(?<pc>0x[a-f0-9]+)\s+(?<rest>.*)$',
      unicode: true,
      caseSensitive: false);
  static final _offsetSuffixPattern =
      RegExp(r'^(?<symbol>.*)\s+\+\s+(?<offset>\d+)$');

  static final _endOfDumpStackTracePattern = '-- End of DumpStackTrace';
  static final _dartvmFramePattern = RegExp(
      r'(^|\s+)pc\s+(?<pc>0x[a-f0-9]+)\s+fp\s+(?<fp>0x[a-f0-9]+)\s+(?<binary>[^\s+]+)\+(?<offset>0x[a-f0-9]+)');

  final _internalFramePattern = RegExp(
      r'(?<pc>0x[a-f0-9]+)\s*\((?<binary>\S+)\s+(\+\s+(?<offset>0x[a-f0-9]+)|(?<location>[^+][^\)]+))\)(?<symbol>.*)',
      caseSensitive: false);
}

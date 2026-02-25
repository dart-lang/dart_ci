This folder contains implementation of symbolization tooling capable of
extracting Android and iOS crashes from plain text comments on GitHub or
from local text files and then automatically symbolize these crash reports
using Flutter Engine symbols stored in the Cloud Storage.

# Using this locally

```
$ dart pub global activate -sgit https://github.com/dart-lang/dart_ci.git --git-path github-label-notifier/symbolizer/
$ dart pub global run symbolizer:symbolize <file-or-uri> ["overrides"]
$ dart pub global run symbolizer:symbolize --help
```

# Symbolization overrides

Not all information might be available in the stack trace itself. In this case
_symbolization overrides_ can be used to fill in gaps. They have the following
format:

```
[engine#<sha>|flutter#<commit>] [profile|release|debug] [x86|arm|arm64|x64]
```

- `engine#<sha>` - use symbols for specific _engine commit_;
- `flutter#<commit>` use symbols for specific Flutter Framework commit
  (this is just another way of specifiying engine commit);
- `profile|release|debug` use symbols for specific _build mode_ (iOS builds
  only have `release` symbols available though);
- `x86|arm|arm64|x64` use symbols for specific _architecture_.

If your backtrace comes from Crashlytics with lines that look like this:

```
4  Flutter                        0x106013134 (Missing)
```

You would need to use `force ios [arm64|arm] [engine#<sha>|flutter#<commit>]`
overrides:

- `force ios` instructs tooling to ignore native crash markers and simply look
  for lines that match `ios` backtrace format;
- `[arm64|arm]` gives information about architecture, which is otherwise
  missing from the report;
- `engine#sha|flutter#commit` gives engine version;

If your backtrace has lines that look like this:

```
0x0000000105340708(Flutter + 0x002b4708)
```

You would need to use `internal [arm64|arm] [engine#<sha>|flutter#<commit>]`
overrides:

- `internal` instructs tooling to ignore native crash markers and look for
  lines that match this special _internal_ backtrace format.

### Note about Relative PCs

To symbolize stack trace correctly symbolizer needs to know PC relative to
binary image load base. Native crash formats usually include this information:

- On Android `pc` column actually contains relative PCs rather then absolute.
  Though Android versions prior to Android 11 have issues with their unwinder
  which makes these relative PCs skewed in different ways (see
  [this bug](https://github.com/android/ndk/issues/1366) for more information).
  This package tries best to correct for these known issues;
- On iOS crash parser is looking for lines like this `Flutter + <rel-pc>`
  which gives it necessary information.

Some crash formats (Crashlytics) do not contain neither load base nor relative
PCs. In this case symbolizer will try to determine load base heuristically
based on the set of return addresses available in the backtrace: it will look
through Flutter Engine binary for all call sites and then iterate through
potential load bases to see if one of them makes all of PCs present in the
backtrace fall onto callsites. The pattern of call sites in the binary is often
unique enough for the symbolizer to be able to determine a single possible load
base based on 3-4 unique return addresses.

# Scripts

## `bin/configure.dart`

Creates `.config.json` with authorization tokens. It is recommended to run
this script to at least configure GitHub OAuth token to ensure that
you don't hit GitHub's API quota limits for unauthorized users.

```console
$ bin/configure.dart --github-token ...
```

## `bin/symbolize.dart`

```console
$ bin/symbolize.dart <input-file|URI> 'keywords*'
```

Symbolize contents of the given file or GitHub comment or issue using overrides
specified through keywords.

# Development

## Tokens

You would at minimum need GitHub OAuth token to run test - otherwise they
hit GitHub API limits for unauthorized users and timeout.

Run `bin/configure.dart` to create `.config.json`.

```
bin/configure.dart --github-token ...
```

## NDK tooling

To run tests or scripts locally you would need to create `tools` folder
containing a small subset of NDK tooling. This is done by running

```console
$ ./get-tools-from-ndk.sh <path-to-ndk>
```

## Changing `model.dart`

We use [`freezed`](https://pub.dev/packages/freezed) to define our model
classes. To regenerate `model.g.dart` and `mode.freezed.dart` after editing
`model.dart` run:

```console
$ dart run build_runner build
```

# Testing

```console
$ dart test test -j1 --no-chain-stack-traces
```

- `-j1` is needed to avoid racy access to symbols cache from multiple
  tests
- `--no-chain-stack-traces` needed to avoid timeouts caused by
  stack trace chaining overheads.

To update expectation files set `REGENERATE_EXPECTATIONS` environment
variable to `true` (`export REGENERATE_EXPECTATIONS=true`).

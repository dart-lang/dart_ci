<!--
This is flutter-symbolizer-bot README file. If you are making changes to
this file update https://github.com/flutter-symbolizer-bot/flutter-symbolizer-bot/blob/main/README.md
as well
-->

### Hi there 👋

I am a bot that can symbolize Flutter Engine crashes. If you have any bug
reports or questions contact @mraleph

👉 **I only answer to commands of public members of Flutter GitHub org!** To
check whether your membership is public just open your profile in Incognito
Window and check if Flutter org badge is visible. Read more about org membership
privacy settings [here](https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-your-github-user-account/publicizing-or-hiding-organization-membership).

I can automatically detect the following crashes:

- Android crashes marked with `*** *** *** ... *** *** ***` line.
- iOS crashes starting with `Incident Identifier: ...` line.

For symbolization I would need to know engine commit hash and build mode. I
support extracting engine version from `flutter doctor` output (with or
without `-v`) and I can sometimes guess build mode (e.g. by using `Build ID`
included into stack traces on Android).

However often reports don't include all required information or don't use native
format so you would need to provide me with additional hints, see
[Commands](#commands) below.

### Commands

When you mention me in the comment you can include a number of
_symbolization overrides_ which would fill in the gaps in information for me.

```
@flutter-symbolizer-bot [engine#<sha>|flutter#<commit>] [profile|release|debug] [x86|arm|arm64|x64]
```

**Important ⚠️**: `@flutter-symbolizer-bot` **MUST** be the very first thing
in your comment.

- `engine#<sha>` allows to specify which _engine commit_ I should use;
- `flutter#<commit>` allows to specify which Flutter Framework commit I
  should use (this is just another way of specifiying engine commit);
- `profile|release|debug` tells me which _build mode_ I should use (iOS builds
  only have `release` symbols available though);
- `x86|arm|arm64|x64` tells me which _architecture_ I should use.

You can point me to a specific comment by including the link to it:

```
@flutter-symbolizer-bot [link|this]
```

- `link`, which looks like
  `https://github.com/flutter/flutter/issues/ISSUE#issue(comment)?-ID`, asks me
   to look for crashes in the specific comment;
- `this` asks me to symbolize content of
  _the comment which contains the command_.

If your backtrace comes from Crashlytics with lines that look like this:

```
4  Flutter                        0x106013134 (Missing)
```

You would need to tell me `@flutter-symbolizer-bot force ios [arm64|arm] [engine#<sha>|flutter#<commit>] link|this`:

- `force ios` tells me to ignore native crash markers and simply look for lines
  that match `ios` backtrace format;
- `[arm64|arm]` gives me information about architecture, which is otherwise
  missing from the report;
- `engine#sha|flutter#commit` gives me engine version;
- `link|this` specifies which comment to symbolize. Note ⚠️: because this is a
  departure from native crash report formats you *must* tell me which comment
  to symbolize manually

If your backtrace has lines that look like this:

```
0x0000000105340708(Flutter + 0x002b4708)
```

You would need to tell me `@flutter-symbolizer-bot internal [arm64|arm] [engine#<sha>|flutter#<commit>] link|this`:

- `internal` tells me to ignore native crash markers and look for lines that
  match _internal_ backtrace format.

### Note about Relative PCs

To symbolize stack trace correctly I need to know PC relative to binary image
load base. Native crash formats usually include this information:

- On Android `pc` column actually contains relative PCs rather then absolute.
  Though Android versions prior to Android 11 have issues with their unwinder
  which makes these relative PCs skewed in different ways (see
  [this bug](https://github.com/android/ndk/issues/1366) for more information).
  I try my best to correct for these known issues;
- On iOS I am looking for lines like this `Flutter + <rel-pc>` which gives me
  necessary information.

Some crash formats (Crashlytics) do not contain neither load base nor relative
PCs. In this case I try to determine load base heuristically based on the set
of return addresses available in the backtrace: I look through Flutter Engine
binary for all call sites and then iterate through potential load bases to see
if one of them makes all of PCs present in the backtrace fall onto callsites.
The pattern of call sites in the binary is often unique enough for me to be
able to determine a single possible load base based on 3-4 unique return
addresses.
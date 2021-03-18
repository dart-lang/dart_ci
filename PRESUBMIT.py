# Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.
"""Presubmit script for dart_ci repository.

See http://dev.chromium.org/developers/how-tos/depottools/presubmit-scripts
for more details about the presubmit API built into git cl.
"""

import subprocess


def _NeedsFormat(path):
  return subprocess.call(['dart', 'format', '--set-exit-if-changed',
                          '--output','none', path]) != 0


def _CheckDartFormat(input_api, output_api):
  files = [
      git_file.AbsoluteLocalPath()
      for git_file in input_api.AffectedTextFiles()
  ]
  unformatted_files = [
      path for path in files
      if path.endswith('.dart') and _NeedsFormat(path)
  ]
  if unformatted_files:
    escapedNewline = ' \\\n'
    return [
        output_api.PresubmitError(
            'File output does not match dartfmt.\n'
            'Fix these issues with:\n'
            'dart format%s%s' %
            (escapedNewline, escapedNewline.join(unformatted_files)))
    ]
  return []


def CommonChecks(input_api, output_api):
  return _CheckDartFormat(input_api, output_api)


CheckChangeOnCommit = CommonChecks
CheckChangeOnUpload = CommonChecks

#!/usr/bin/env bash

# Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Schedules builders to build executables from the dart_ci scripts for all
# supported platforms and upload them as CIPD packages under
# https://chrome-infra-packages.appspot.com/p/dart/ci/builder_scripts.

set -e

if [ -z "$1" ]; then
  echo "Revision required as first argument." >&2
  exit 1
fi

declare -a BUILDERS=(
    "dart-ci-scripts-linux"
    "dart-ci-scripts-win"
    "dart-ci-scripts-mac"
    "dart-ci-scripts-mac-arm64")

for INDEX in "${!BUILDERS[@]}"; do
  BUILDER=dart/ci/${BUILDERS[$INDEX]}
  BUILD_ID=$(bb add\
    -commit $1\
    -json\
    $BUILDER\
    | jq -r '.id')
  echo $BUILDER: $BUILD_ID
done

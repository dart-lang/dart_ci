#!/bin/sh
# Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

set -xe

NDK=$1
OS=$2

if [[ -z $OS ]]; then
  OS=$(uname | tr '[:upper:]' '[:lower:]')
fi

echo "Running with NDK $NDK for OS $OS"

for BINARY in "llvm-symbolizer" "llvm-objdump" "llvm-readobj"; do
  mkdir -p tools/android-ndk/toolchains/llvm/prebuilt/$OS-x86_64/bin/
  cp $NDK/toolchains/llvm/prebuilt/$OS-x86_64/bin/$BINARY tools/android-ndk/toolchains/llvm/prebuilt/$OS-x86_64/bin/$BINARY
done
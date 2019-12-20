#!/bin/sh
# Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

set -e

webdev build --output web:build/web -r
rm -rf build/web/packages
firebase deploy -P dart-ci --only hosting:dart-github-notifier

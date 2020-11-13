#!/bin/sh
# Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

set -e

export SYMBOLIZER_SERVER=localhost:4040

# Don't use real SendGrid servers during testing - instead redirect API
# calls to a mock server.
export SENDGRID_MOCK_SERVER=localhost:8151

# Note: these are randomly generated secrets purely for testing purposes.
# They should not be used during deployment.
export GITHUB_SECRET=f32205e9a6d0b8157dcc1935af96aa9fe5719109
export SENDGRID_SECRET=SG.I9JN-n6oQb-X686126S.qJasdasdasda_lyadasd

pub run build_runner build --output=build

firebase emulators:start --project github-label-notifier

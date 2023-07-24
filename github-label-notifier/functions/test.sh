#!/bin/sh
# Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

set -e

# Don't use real SendGrid servers during testing - instead redirect API
# calls to a mock server.
export SENDGRID_MOCK_SERVER=localhost:8151

# Similarly don't use real symbolizer server. We are going to start our own
# mock server.
export SYMBOLIZER_SERVER=localhost:4040

# Note: these are invented *fake* secrets purely for testing purposes.
export GITHUB_SECRET=a_fake_github_secret_value
export SENDGRID_SECRET=fake_SG.I9JN-n6oQb-X686126S.qJasdasdasda_lyadasd

export PORT=8002

firebase emulators:exec --project github-label-notifier 'dart test/integration_test.dart'

#!/bin/sh
# Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

set -e

if [[ -z "$GITHUB_SECRET" ]]; then
    echo "Must specify GITHUB_SECRET environment variable"
    exit 1
fi

if [[ -z "$SENDGRID_SECRET" ]]; then
    echo "Must specify SENDGRID_SECRET environment variable"
    exit 1
fi

# First step is to run the build
pub run build_runner build --output=build

# Create a deployment folder.
rm -rf deploy
mkdir -p deploy/build/node
cp build/node/index.dart.js deploy/build/node
cp package.json deploy/

# Deploy the function.
gcloud functions deploy githubWebhook --project dart-ci --source deploy --trigger-http \
    --runtime nodejs10 --memory 128MB \
    --set-env-vars GITHUB_SECRET=$GITHUB_SECRET,SENDGRID_SECRET=$SENDGRID_SECRET

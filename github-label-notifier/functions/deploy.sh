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
gcloud run deploy github-webhook --port 8080 --project dart-ci \
    --region us-central1 --timeout 120s \
    --memory 128Mi \
    --source=./ --allow-unauthenticated \
    --description 'The Github label notifier service' \
    --set-env-vars "GITHUB_SECRET=$GITHUB_SECRET,SENDGRID_SECRET=$SENDGRID_SECRET"

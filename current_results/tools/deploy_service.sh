#!/usr/bin/env bash
#
# Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.
#
# Build with cloud build and deploy the project to GCE

set -ex

if [ $# -ne 1 ]; then
  cat <<EOF
Usage: $0 <cloud project name>

This script deploys the current results server.

It builds a docker image from the code in the working directory,
and deploys it to the current-results-server instance in the given project.
EOF
  exit 1
fi

PROJECT=$1

gcloud config set project $PROJECT

# Are we in the dart_ci/current_results directory?
if ! grep "# Current results of Dart CI" README.md; then
  echo "error: Current directory is not current_results server source."
fi

gcloud builds submit --project=$PROJECT --tag gcr.io/$PROJECT/current_results

gcloud compute ssh current-results-server --zone=us-central1-a \
  --command="docker kill current-results; docker rm current-results; docker pull gcr.io/$PROJECT/current_results"

gcloud compute ssh current-results-server --zone=us-central1-a \
  --command="docker run -d --security-opt seccomp=unconfined --log-driver=gcplogs --net=bridge_net --publish=8080:8080 --name=current-results gcr.io/$PROJECT/current_results"

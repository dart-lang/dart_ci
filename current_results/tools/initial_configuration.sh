#!/usr/bin/env bash
#
# Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.
#
# One-time setup to run the current-results service on a cloud project.

if [ $# -ne 1 ]; then
  cat <<EOF
Usage: $0 <cloud project name>

This script initializes a project to run the current-results service

EOF
  exit 1
fi

PROJECT=$1
REGION=us-central1

gcloud config set project $PROJECT

gcloud services enable vpcaccess.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Reserve the cloud run hostname for the backend service.
# We need this generated hostname for later deployment.
gcloud run deploy current-results-backend \
  --image="gcr.io/cloudrun/hello" \
  --allow-unauthenticated \
  --platform managed \
  --region us-central1 \
  --use-http2 \
  --cpu=1 \
  --memory=2Gi

# Reserve the cloud run hostname for the ESPv2 proxy service.
# We need this generated hostname for later deployment.
gcloud run deploy current-results \
  --image="gcr.io/cloudrun/hello" \
  --allow-unauthenticated \
  --platform managed \
  --region us-central1

# TODO Add a call to Fetch running every 5 minutes (with POST) to cloud scheduler.

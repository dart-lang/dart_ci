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

gcloud compute project-info add-metadata \
  --metadata google-compute-default-region=us-central1,google-compute-default-zone=us-central1-a

gcloud compute instances create current-results-server \
  --image-project cos-cloud --image-family=cos-117-lts --machine-type=e2-small \
  --zone us-central1-a --metadata google-logging-enabled=true

# This command requires the organization policy
# constraints/compute.vmCanIpForward
# The service cannot be deployed in a project in an organization that
# does not allow VM IP forwarding
gcloud compute networks vpc-access connectors create cloud-run-to-gce \
  --network default --region us-central1 --range 10.126.0.0/28

echo "This command should output 'state:READY'"

# Reserve the cloud run hostname for the service.
# We need this generated hostname for later deployment.
gcloud run deploy current-results --image="gcr.io/cloudrun/hello" \
  --allow-unauthenticated --platform managed --region us-central1

gcloud compute ssh current-results-server --zone=us-central1-a \
  --command="docker network create --driver bridge bridge_net; docker-credential-gcr configure-docker"

# TODO Add a call to Fetch running every 5 minutes (with POST) to cloud scheduler.

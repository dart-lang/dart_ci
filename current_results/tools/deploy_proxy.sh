#!/usr/bin/env bash
#
# Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.
#
# Deploy the ESPv2 proxy to the current-results service on Cloud Run
set -ex

if [ $# -ne 1 ]; then
  cat <<EOF
Usage: $0 <cloud project name>

This script deploys the Endpoints configuration and proxy service for
the current results service

EOF
  exit 1
fi

PROJECT=$1
REGION=us-central1
ZONE=a
ESP_TAG=2.55.0 # This needs to be updated if the ESP container gets outdated.

script_dir=$(dirname "${BASH_SOURCE[0]}")
echo $script_dir

gcloud config set project $PROJECT

service_url=$(gcloud run services describe --platform managed current-results --format="value(status.url)" --region=$REGION)
service_hostname=${service_url#https://}

echo $service_hostname

backend_url=$(gcloud run services describe --platform managed current-results-backend --format="value(status.url)" --region=$REGION)
backend_hostname=${backend_url#https://}

echo $backend_hostname

sed "s/SERVICE_HOSTNAME/$service_hostname/ ; s/BACKEND_HOSTNAME/$backend_hostname/ ; s/PROJECT/$PROJECT/ ; s/REGION/$REGION/ ; s/ZONE/$ZONE/" \
  < $script_dir/../endpoints/cloud_run_api_config_template.yaml \
  > $script_dir/../endpoints/generated/cloud_run_api_config.yaml

gcloud endpoints services deploy $script_dir/../endpoints/generated/api_descriptor.pb \
  $script_dir/../endpoints/generated/cloud_run_api_config.yaml

config_id=$(gcloud endpoints configs list --service=$service_hostname --project=$PROJECT --sort-by=~id --format='value(id)' --limit 1)

gcloud services enable $service_hostname

# Build a ESPv2 docker image with the correct configuration
$script_dir/../third_party/gcloud_build_image -c $config_id \
  -s $service_hostname -p $PROJECT \
  -v $ESP_TAG

gcloud run deploy current-results \
  --image="gcr.io/$PROJECT/endpoints-runtime-serverless:$ESP_TAG-${service_hostname}-$config_id" \
  --allow-unauthenticated --platform managed \
  --project=$PROJECT  --region=$REGION \
  --set-env-vars=ESPv2_ARGS=--cors_preset=basic

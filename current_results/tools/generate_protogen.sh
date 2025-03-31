#!/usr/bin/env bash

# Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Generate the required Dart files for protobufs

set -e

GOOGLEAPIS_GIT=https://github.com/googleapis/googleapis
GOOGLEAPIS_PATH=third_party/googleapis

PROTOBUF_GIT=https://github.com/protocolbuffers/protobuf
PROTOBUF_PATH=third_party/protobuf

git -C $GOOGLEAPIS_PATH pull || git clone $GOOGLEAPIS_GIT $GOOGLEAPIS_PATH
git -C $PROTOBUF_PATH pull || git clone $PROTOBUF_GIT $PROTOBUF_PATH

mkdir -p endpoints/generated
mkdir -p lib/src/generated

protoc \
  -I$GOOGLEAPIS_PATH \
  -I$PROTOBUF_PATH/src \
  -I../common \
  -Ilib/protos \
  --include_imports \
  --include_source_info \
  --dart_out=grpc:lib/src/generated \
  --descriptor_set_out endpoints/generated/api_descriptor.pb \
  $PROTOBUF_PATH/src/google/protobuf/duration.proto \
  $PROTOBUF_PATH/src/google/protobuf/empty.proto \
  $PROTOBUF_PATH/src/google/protobuf/field_mask.proto \
  $PROTOBUF_PATH/src/google/protobuf/timestamp.proto \
  $GOOGLEAPIS_PATH/google/pubsub/v1/pubsub.proto \
  $GOOGLEAPIS_PATH/google/pubsub/v1/schema.proto \
  ../common/result.proto \
  lib/protos/query.proto

dart format lib/src/generated/

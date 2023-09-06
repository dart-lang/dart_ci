#!/usr/bin/env bash

# Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Generate the required Dart files for protobufs

set -e

if [ -z "$GOOGLEAPIS_PATH" ]
then
  echo Set the variable \'GOOGLEAPIS_PATH\' to a checkout of \
    \'https://github.com/googleapis/googleapis/\'!
  exit 1
fi

if [ -z "$PROTOBUF_PATH" ]
then
  echo Set the variable \'PROTOBUF_PATH\' to a checkout of \
    \'https://github.com/protocolbuffers/protobuf.git\'!
  exit 1
fi

protoc --dart_out=lib/src/generated -I$PROTOBUF_PATH/src $PROTOBUF_PATH/src/google/protobuf/duration.proto
protoc --dart_out=lib/src/generated -I$PROTOBUF_PATH/src $PROTOBUF_PATH/src/google/protobuf/empty.proto
protoc --dart_out=lib/src/generated -I$PROTOBUF_PATH/src $PROTOBUF_PATH/src/google/protobuf/field_mask.proto
protoc --dart_out=lib/src/generated -I$PROTOBUF_PATH/src $PROTOBUF_PATH/src/google/protobuf/timestamp.proto
protoc --dart_out=grpc:lib/src/generated -I$GOOGLEAPIS_PATH $GOOGLEAPIS_PATH/google/pubsub/v1/pubsub.proto
protoc --dart_out=grpc:lib/src/generated -I$GOOGLEAPIS_PATH $GOOGLEAPIS_PATH/google/pubsub/v1/schema.proto

protoc --dart_out=lib/src/generated ../common/result.proto -I../common
protoc --dart_out=grpc:lib/src/generated -Ilib/protos -Ithird_party/proto lib/protos/query.proto
dartfmt -w lib/src/generated/query* lib/src/generated/result*

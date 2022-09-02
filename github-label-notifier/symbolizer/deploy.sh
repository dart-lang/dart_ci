#!/bin/sh
# Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

set -xe

for BINARY in "llvm-symbolizer" "llvm-objdump" "llvm-readobj"; do
  if [[ ! -f "tools/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/${BINARY}" ]]; then
    echo "Missing linux-x86_64 build of ${BINARY}."
    echo "Point get-tools-from-ndk.sh to Linux NDK to extract it."
    exit 1
  fi
done

DART_VERSION=$(dart --version 2>&1 | grep -o -e '\d*\.\d*.\d*')

if [[ $DART_VERSION != "2.18.0" ]]; then
  echo "Version mismatch with server version: $DART_VERSION expected 2.18.0"
  exit 1
fi

# Run all tests
pub run test --no-chain-stack-traces -j1

rm -rf deploy
mkdir -p deploy/symbolizer
dart --snapshot-kind=kernel --snapshot=deploy/symbolizer/symbolizer.dill bin/server.dart
cp -r tools deploy/symbolizer/tools
dart bin/configure.dart --output=deploy/symbolizer/.config.json \
                        --github-token=$GITHUB_TOKEN            \
                        --sendgrid-token=$SENDGRID_TOKEN        \
                        --failure-email=$FAILURE_EMAIL
pushd deploy
zip -r symbolizer.zip symbolizer
rm -rf symbolizer
popd

cat <<EOT >deploy/deploy.sh
#!/bin/sh

set -ex

DEPLOY_CMD='rm -rf symbolizer && unzip symbolizer.zip && sudo supervisorctl restart all'
gcloud beta compute scp --zone "us-central1-a" --project "dart-ci" symbolizer.zip crash-symbolizer:~/
gcloud beta compute ssh --zone "us-central1-a" --project "dart-ci" --command "\$DEPLOY_CMD" crash-symbolizer
EOT
chmod +x deploy/deploy.sh

if [[ -z "$DEPLOYMENT_PROXY" ]]; then
  cd deploy && ./deploy.sh
else
  scp deploy/symbolizer.zip $DEPLOYMENT_PROXY:/tmp/symbolizer.zip
  scp deploy/deploy.sh $DEPLOYMENT_PROXY:/tmp/deploy.sh
  ssh $DEPLOYMENT_PROXY 'cd /tmp && ./deploy.sh'
fi

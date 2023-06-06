# Dart results feed

This is the Dart Angular app that presents the changed test
results from CI (continuous integration) testing of Dart.
It uses Firebase and Firestore, and is hosted at
https://dart-ci.firebaseapp.com/

## Prerequisites (Verified 2021-09-06)

- Dart SDK version 2.10.0-stable
- webdev 2.5.9 (run `pub global activate webdev 2.5.9`)

## Building
Build and deploy the project using cloud build with the command

    gcloud --project=dart-ci builds submit

Local builds can be run with

    webdev build --output=web:build/web

## Testing
Run tests (one at a time only) with the commands

    pub run build_runner test --fail-on-severe -- -p chrome

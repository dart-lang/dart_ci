# Dart results feed

This is the Dart Angular app that presents the changed test
results from CI (continuous integration) testing of Dart.
It uses Firebase and Firestore, and is hosted at
https://dart-ci.firebaseapp.com/

## Prerequisites

- Dart SDK version 2.10.0-stable
- webdev 2.5.9 (run `pub global activate webdev 2.5.9`)

## Building
Build the project with the command

    webdev build

## Testing
Run tests (one at a time only) with the commands

    pub run build_runner test --fail-on-severe -- -p chrome

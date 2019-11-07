# Cloud Functions for Dart CI

Dart test results are sent to Pub/Sub and stored in Firestore
by these functions, written in Dart and compiled to NodeJS.

These functions write to the document collections 'results' and 'commits'
in the projects 'dart-ci' and 'dart-ci-staging'

## Installation

````
pub get
npm install
pub run build_runner build --output=build
firebase -P dart-ci-staging deploy --only functions
````




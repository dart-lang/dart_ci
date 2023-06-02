# current_results_ui

A web UI displaying current test results for Dart CI

## About

This web app displays results from the Current Results API in the dart-ci
project.

## Usage

The page is visible at

https://dart-current-results.web.app

It includes options to filter the current results show by test
name (partial prefixes of test name allowed) and by configuration (partial
prefixes allowed).

## Deployment

It is written for deployment in Flutter web, but may work on other platforms.

It is deployed to the  the dart_ci Firebase
hosted web app at https://dart-current-results.app.web/

It is built and deployed with the Flutter master channel.

Build and deploy with

    gcloud --project=dart-ci builds submit

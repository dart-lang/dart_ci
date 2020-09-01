# ui_current_results

A web UI displaying current test results for Dart CI

## About

This web app displays results from the Current Results API in the dart-ci
project. During development and while testing before deployment, it
fetches results from the Current Results API in the dart-ci-staging project.

It is written in Flutter web, and has a few uses of dart:html that prevent
it from working on other Flutter platforms.

It is deployed to the current_results directory of the dart_ci Firebase
hosted web app at https://dart-ci.firebaseapp.com/ (dart-ci-staging for
testing).

## Usage

The page is visible at

https://dart-ci-staging.firebaseapp.com/current_results/index.html

It includes options to filter the current results show by test
name (partial prefixes of test name allowed) and by configuration (partial
prefixes allowed).

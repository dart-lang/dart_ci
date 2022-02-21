# current_results_ui

A web UI displaying current test results for Dart CI

## About

This web app displays results from the Current Results API in the dart-ci
project.

## Usage

The page is visible at

https://dart-ci-staging.firebaseapp.com/current_results/index.html

It includes options to filter the current results show by test
name (partial prefixes of test name allowed) and by configuration (partial
prefixes allowed).

## Deployment

It is written for deployment in Flutter web, but may work on other platforms.

It is deployed to the current_results directory of the dart_ci Firebase
hosted web app at https://dart-ci.firebaseapp.com/ (dart-ci-staging for
testing).

It is currently built and deployed with Flutter version 2.11.0-0.1.pre.

Build with

    flutter build web

and deploy by copying the contents of build/web to

    [results_feed]/build/web/current_results

before deploying the results feed.

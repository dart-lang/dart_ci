# Dart Github label notifier deployment

This project should be deployed to the dart-github-notifier target,
which is defined for both the dart-ci-staging and dart-ci projects.

On dart-ci-staging, it deploys to the website
dart-github-notifier-staging.firebaseapp.com
and on dart-ci, it deploys to
dart-github-label-notified.firebaseapp.com

## Staging

To deploy to staging, the api key and urls in
lib/src/services/subscription_service.dart
must be replaced with those for staging, found
in the dart-ci-staging Firebase console.

## Deployment

To build and deploy, use `deploy.sh` script.

# dart_ci

## Tools used by Dart's continuous integration (CI) testing infrastructure.

The repository is based at github.com/dart-lang/dart_ci. It is mirrored to dart.googlesource.com/dart_ci. Changes need to be landed as pull requests in this repo.

### Results Feed

The results feed is an angular Dart application that displays changed results from the CI and from CQ runs (try-jobs). The code is in the results_feed directory. It is deployed to ci.dart.dev, using Firebase hosting.

### Current results server and UI

A Flutter Web application that displays current test results fetched from a server that keeps all the latest test results in memory.

### Github Label Notifier

Internal users get automatic notifications of new GitHub issues created in certain repositories,
by subscribing to issue labels on those repositories. This tool provides a UI for internal users
to subscribe to their chosen issue labels. That UI is hosted at dart-github-label-notifier.firebaseapp.com.
It also defines cloud functions that are triggered by
GitHub webhooks and use the issue label subscriptions to send email notifications using SendGrid.
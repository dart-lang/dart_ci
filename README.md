# dart_ci

## Tools used by Dart's continuous integration (CI) testing infrastructure.

The repository is based at dart.googlesource.com/dart_ci. It is mirrored to github.com/dart-lang/dart_ci.  Do not land pull requests on Github.

### Results Feed

The results feed is an angular Dart application that displays changed results from the CI and from CQ runs (tryjobs). The code is in the results_feed directory. It is deployed to ci.dart.dev, using Firebase hosting.

### Cloud functions

The automated testing of Dart on the CI and CQ publishes results to Cloud Pubsub, and cloud functions triggered by those Pubsub messages process the data and store it in Firestore.  These functions are located in the functions directory, and are deployed on the dart-ci Google Cloud project.

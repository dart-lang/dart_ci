# Current results of Dart CI

This server runs on Google Cloud Run, and provides the most recent test results
from the Dart CI (continuous integration) testing visible at
https://ci.chromium.org/p/dart/g/be/console

## Build and deploy

The service takes about forty seconds to load all the existing
latest results.json files from all the configurations, so its reponse
to the first request after deploying will take at least that long.
When an instance is started, a health check verifies that it is responding
to web requests, and this health check has a 4 minute timeout.
An instance is also started, and the health check run, when deploying a
new version.

### Generating protogen classes

Pre-requisites:
- Install the protoc compiler: https://developers.google.com/protocol-buffers/docs/downloads
- Install https://pub.dev/packages/protoc_plugin/install
- A copy of https://github.com/googleapis/googleapis
- A copy of https://github.com/protocolbuffers/protobuf

To generate the required Dart files for the protos, run
`tools/generate_protogen.sh` with the environtment variables
`GOOGLEAPIS_PATH` and `PROTOBUF_PATH` set to the location of the checkouts
mentioned above.

### Staging
To build the server and deploy to cloud run on staging, run

```
gcloud builds submit --project=dart-ci-staging --tag gcr.io/dart-ci-staging/current_results
gcloud run deploy --project=dart-ci-staging current-results --image gcr.io/dart-ci-staging/current_results --platform=managed --allow-unauthenticated
```

Unauthenticated access is allowed only while the server being developed does
not modify any data, remove that flag before adding APIs that modify data.

### Production XXX NOT READY YET
To build the server and deploy to cloud run on production, run

```
gcloud builds submit --project=dart-ci --tag gcr.io/dart-ci/current_results
gcloud run deploy --project=dart-ci current-results --image gcr.io/dart-ci/current_results --platform=managed
```

## Services

### Data cached by server

The server reads the current results.json and flaky.json from cloud storage
at gs://dart-test-results/configuration/master/[configuration name]/[build number]/
and stores selected fields from those records in memory. (Flaky.json reads not
implemented).

### Updating results data

The server exposes a service to Pub/Sub on the same project, which is
triggered by any object creation on the dart-test-results bucket.  If the
object is a /configuration/master/[configuration name]/latest file, the build
number is read from that file and the cached results.json and flaky.json are
updated from that build.

### Serving results data

A gRPC service is defined, with a query message type and a response message
type defined by protocol buffers.  It will allow queries by test name or
test name prefix and by configuration or configuration set.

### Managing flakiness

APIs will be defined to query current flakiness data, and to revoke the
flakiness mark on test-configuration pairs.  When designing the API to
revoke flakiness, security and auditing concerns must be addressed by
requiring authentication.
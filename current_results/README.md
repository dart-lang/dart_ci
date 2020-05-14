# Current results of Dart CI

This server runs on Google Cloud Run, and provides the most recent test results
from the Dart CI (continuous integration) testing visible at
https://ci.chromium.org/p/dart/g/be/console

## Build and deploy

The service takes about two minutes to load all the existing
latest results.json files from all the configurations, so it's reponse
to the first request after deploying will take at lest that long.
When deploying, a health check verifies that it is responding
to web requests, and this health check has a 4 minute timeout.
The instance started for the health check does not seem to
remain alive, so the first real request has the same
startup delay.

### Generating protogen classes
To generate the Dart code reading the records from results.json,
run protogen on the .proto file declaring them:
```
protoc --dart_out=gen ../common/result.proto
```

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
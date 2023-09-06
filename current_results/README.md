# Current results of Dart CI

This server runs on Google Cloud Run, and provides the most recent test results
from the Dart CI (continuous integration) testing visible at
https://ci.chromium.org/p/dart/g/be/console.

This service is the backend for https://dart-current-results.web.app/
which provides a filterable view of the current test status across
all configurations.

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
`tools/generate_protogen.sh` with the environment variables
`GOOGLEAPIS_PATH` and `PROTOBUF_PATH` set to the location of the checkouts
mentioned above.

### Deployment
To build the server and deploy to production, run

```
gcloud builds submit --project=dart-ci --tag gcr.io/dart-ci/current_results
```
When that build has completed successfully, run
```
gcloud compute ssh current-results-server --project=dart-ci --zone=us-central1-a --command="docker kill current-results; docker rm current-results; docker pull gcr.io/dart-ci/current_results"
gcloud compute ssh current-results-server --project=dart-ci --zone=us-central1-a --command="docker run -d --net=bridge_net --publish=8080:8080 --name=current-results gcr.io/dart-ci/current_results"
```

There is also a REST proxy which provides the public REST api for this backend server.
Instructions on deploying this ESPv2 proxy (https://github.com/GoogleCloudPlatform/esp-v2)
are in internal team documentation. The connection between the public REST api and the gRPC api
is configured in the lib/protos/query.proto file in this repository.

## Services

### Data cached by server

The server reads the current results.json from cloud storage
at gs://dart-test-results/configuration/main/[configuration name]/[build number]/
and caches selected fields from those records in memory.

### Updating results data

The server exposes a service to Pub/Sub on the same project, which is
triggered by any object creation on the dart-test-results bucket.  If the
object is a /configuration/main/[configuration name]/latest file, the build
number is read from that file and the cached results.json is
updated from that build.

### Serving results data

A gRPC service is defined, with a query message type and a response message
type defined by protocol buffers.  It allows test result queries by test name or
test name prefix and by configuration or configuration prefix.

# Current results of Dart CI

This server runs on Google Cloud Run, and provides the most recent test results
from the Dart CI (continuous integration) testing visible at
https://ci.chromium.org/p/dart/g/be/console.

This service is the backend for https://dart-current-results.web.app/
which provides a filterable view of the current test status across
all configurations.

The current results service is a gRPC server written in Dart, running
on GCE. Cloud Endpoints is used to configure access to the server's API,
and the ESPv2 proxy is used to manage the API and provide a REST translation of
the API.

The results service listens for new Dart CI results uploaded to cloud storage,
and loads them into an in-memory database of all current CI results.
Queries on these results are supported the by the API.

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


To generate the required Dart files for the protos, run
`tools/generate_protogen.sh`.

### Deployment
There are three deployment scripts, one for the initial deployment of the
current results service to a cloud project, and one for redeploying the
current results server, and one for redeploying the Cloud Endpoints
configuration and the ESPv2 proxy. Three deployment scripts, there
are three deployment scripts.

These scripts should be run with the current directory set to the
current_results directory in a checkout of the dart.googlesource.com/dart_ci
repository, with the version you wish to deploy checked out.

* initial_configuration.sh (only needed once to setup a new project)
* deploy_service.sh
* deploy_endpoints_configuration.sh

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

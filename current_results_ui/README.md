# current_results_ui

A web UI displaying current test results for Dart CI

## About

This web app displays results from the Current Results API in the dart-ci
project.

## Development

Before running the application, you may need to generate mock files for tests and ensure the code is correctly formatted.

### Code Generation

This project uses `build_runner` to generate mock files for testing. To generate these files, run the following command:

```sh
dart run build_runner build --delete-conflicting-outputs
```

This project also depends on generated protobuf code. For instructions on how to regenerate these files, see the [current_results README](../current_results/README.md).

### Code Formatting

To ensure consistent code style, format the code using the following command:

```sh
dart format .
```

## Usage

The page is visible at

https://dart-current-results.web.app

It includes options to filter the current results show by test
name (partial prefixes of test name allowed) and by configuration (partial
prefixes allowed).

## Deployment

The app is deployed to the dart_ci Firebase project as a [hosted web app].


It is built and deployed automatically with the Flutter master channel using the
[community flutter cloud builder]. The builder's docker images need to manually
updated using the instructions in the builder's readme.

To build and deploy local changes manually (not recommended), run the following
command at the root of the checkout:

```
gcloud --project=dart-ci builds submit \
  --config=current_results_ui/cloudbuild.yaml
```

[hosted web app]: https://dart-current-results.app.web/
[community flutter cloud builder]: https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/flutter

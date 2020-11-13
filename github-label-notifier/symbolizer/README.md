This folder contains implementation of symbolization tooling capable of
extracting Android and iOS crashes from plain text comments on GitHub and
then automatically symbolize these crash reports using Flutter Engine symbols
stored in the Cloud Storage.

# `bin/server.dart`

Server exposing simple HTTP API to this functionality. It has two endpoints:

- `POST /symbolize` with GitHub's `issue` JSON payload runs symbolization on the
  issue's body and returns result as a JSON serialized list of
  `SymbolizationResult`.
- `POST /command` with GitHub's [`issue_comment`](https://docs.github.com/en/free-pro-team@latest/developers/webhooks-and-events/webhook-events-and-payloads#issue_comment)
  payload executes the given comment as a bot command (if it represents one).

Note: the server itself does not listen to GitHub events - instead there is a
Cloud Function exposed as a GitHub WebHook which routes relevant
`issue_comment` events to it.

# Scripts

## `bin/configure.dart`

Creates `.config.json` with authorization tokens. It is recommended to run
this script to at least configure GitHub OAuth token to ensure that
you don't hit GitHub's API quota limits for unauthorized users.

```console
$ bin/configure.dart --github-token ... --sendgrid-token ... --failure-email ...
```

## `bin/command.dart`

```console
$ bin/command.dart [--act] <issue-number> 'keywords*'
```

Execute the given string of keywords as a `@flutter-symbolizer-bot` command in
context of the issue with the given `issue-number` number.

By default would simply print `@flutter-symbolizer-bot` response to stdout.

If `--act` is passed then bot would actually post a comment with its response
to the issue using GitHub OAuth token from `.config.json`.

## `bin/symbolize.dart`

```console
$ bin/symbolize.dart <input-file> 'keywords*'
```

Symbolize contents of the given file using overrides specified through keywords.

# Development

## Tokens

You would at minimum need GitHub OAuth token to run test - otherwise they
hit GitHub API limits for unauthorized users and timeout.

Run `bin/configure.dart` to create `.config.json`.

```
bin/configure.dart --github-token ... --sendgrid-token ... --failure-email ...
```

## NDK tooling

To run tests or scripts locally you would need to create `tools` folder
containing a small subset of NDK tooling. This is done by running

```console
$ ./get-tools-from-ndk.sh <path-to-ndk>
```

## Changing `model.dart`

We use [`freezed`](https://pub.dev/packages/freezed) to define our model
classes. To regenerate `model.g.dart` and `mode.freezed.dart` after editing
`model.dart` run:

```console
$ pub run build_runner build
```

# Testing

```console
$ pub run test -j1 --no-chain-stack-traces
```

- `-j1` is needed to avoid racy access to symbols cache from multiple
  tests
- `--no-chain-stack-traces` needed to avoid timeouts caused by
  stack trace chaining overheads.

To update expectation files set `REGENERATE_EXPECTATIONS` environment
variable to `true` (`export REGENERATE_EXPECTATIONS=true`).

# Deployment

Bot is running on `crash-symbolizer` Compute Engine instance and is kept
alive by `superviserd`. The GCE instance is not directly reachable from
the outside world. To deploy a new version run:

```console
$ GITHUB_TOKEN=... SENDGRID_TOKEN=... FAILURE_EMAIL=... ./deploy.sh
```

- `GITHUB_TOKEN` provides OAuth token for `flutter-symbolizer-bot` account;
- `SENDGRID_TOKEN` provides SendGrid API token
- `FAILURE_EMAIL` configures email that bot should report exceptions to.
- Under certain conditions your machine might not be able to connect to
  GCE instance. In this case you will need to proxy your deployment through
  another machine that *can* connect to the instance. You can specify
  this "proxy" machine via `DEPLOYMENT_PROXY`.

## SDK version

We deploy the code in form of Kernel binary - which means your local SDK
needs to match the version of Dart SDK installed on `crash-symbolizer`.
Deployment script will verify this for you.

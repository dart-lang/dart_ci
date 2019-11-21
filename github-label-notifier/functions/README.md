This folder contains the source for a Cloud Function implementing a GitHub
WebHook endpoint which can react to issues being labeled and send notifications
to subscribers.

# Testing

To run local tests use `test.sh` script from this folder.

# Deployment

To deploy use `deploy.sh` script.

Note that deploying requires configuring two environment variables:

* `GITHUB_SECRET` should be equal to the Hook Secret which you will use when
creating a GitHub Hook at https://github.com/{org}/{repo}/settings/hooks
* `SENDGRID_SECRET` should be equal to SendGrid API secret which you get when
you add SendGrid to your Cloud Project (see
[docs](https://sendgrid.com/docs/for-developers/partners/google/) for the
initial setup).

## Firestore

Firestore needs to contain `github-label-subscriptions` collection.

The following Security Rules must be configured to ensure that each user can
only edit its own subscriptions

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /github-label-subscriptions/{userId} {
      allow read, update, delete: if request.auth.uid == userId;
      allow create: if request.auth.uid != null;
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

# Implementation Details

Subscriptions are stored in the Firestore collection called
`github-label-subscriptions` with each document at
`github-label-subscriptions/{userId}` path has the following format

```proto
message Subscription {
    string email = 1;

    // Each subscription has format repo-name:label-name. For example
    // subscribing to label 'bug' in 'dart-lang/sdk' repo would be
    // recorded as 'dart-lang/sdk:bug'.
    repeated string subscriptions = 2;
}
```

Subscriptions are intended to be managed by users themselves so they are indexed
by Firebase UID issued by Firebase authentification.

Mails are sent via SendGrid.

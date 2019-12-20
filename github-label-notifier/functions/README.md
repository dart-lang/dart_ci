This folder contains the source for a Cloud Function implementing a GitHub
WebHook endpoint which can react to issues being labeled and send notifications
to subscribers.

It also can inspect newly opened issues for specific keywords and treat matches
as if a specific label was assigned to an issue.

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

    match /github-keyword-subscriptions/{repo} {
      allow read: if true;
      allow write, create, update, delete: if false
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

# Implementation Details

Subscriptions to labels are stored in the Firestore collection called
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

Subscriptions to keywords for specific repositories are stored at
`github-keyword-subscriptions/{repositoryName}`, where `{repositoryName}`
is full repository name with `/` replaced with `$`.

```proto
// Represents a subscription to keywords inside issue body. If the match is
// found then this is treated as if the issue is labeled with the given label.
message KeywordSubscription {
    string label = 1;
    repeated string keywords = 2;
}
```

Note: security rules prevent editing keyword subscriptions by anybody - so they
can only be changed via Firebase Console UI.

Mails are sent via SendGrid.

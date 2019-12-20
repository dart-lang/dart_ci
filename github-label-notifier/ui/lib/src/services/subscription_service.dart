// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' as firestore;

/// Service for accessing label subscription information stored in the
/// Firestore.
class SubscriptionsService {
  firebase.App _app;
  Stream<firebase.User> _onAuth;

  /// Returns a stream which fires an event every time authentication state
  /// changes.
  Stream<firebase.User> get onAuth {
    if (_onAuth == null) {
      final controller = StreamController<firebase.User>();
      _ensureApp().then((app) {
        app.auth().onAuthStateChanged.pipe(controller.sink);
      }).catchError((error, StackTrace stackTrace) {
        controller.addError(error, stackTrace);
      });
      _onAuth = controller.stream;
    }
    return _onAuth;
  }

  /// Returns true if we have an authenticated user.
  bool get isLoggedIn => _app?.auth()?.currentUser != null;

  /// Returns email of the currently authenticated user.
  String get userEmail => _app?.auth()?.currentUser?.email;

  /// Provides user a chance to authenticate using Google Auth.
  Future<void> logIn() async {
    final app = await _ensureApp();

    if (isLoggedIn) return;

    final provider = firebase.GoogleAuthProvider();
    provider.addScope('openid https://www.googleapis.com/auth/datastore');
    await app.auth().signInWithPopup(provider);
  }

  /// Returns subscriptions of the current user grouped by repository name.
  ///
  /// As a side-effect creates an empty subscription record for the current
  /// user in the firestore - if it is the first time the user is logging in.
  Future<Map<String, List<String>>> getSubscriptions() async {
    final ref = await _computeSubscriptionsRef();
    if (ref == null) {
      return {};
    }

    final doc = await ref.get();

    final List<String> subscriptions =
        doc.exists ? doc.data()['subscriptions'].cast<String>() : <String>[];

    final groupedByRepo = <String, List<String>>{};
    for (var labelId in subscriptions) {
      final label = GithubLabel.fromId(labelId);

      groupedByRepo
          .putIfAbsent(label.repositoryName, () => <String>[])
          .add(label.labelName);
    }

    return groupedByRepo;
  }

  /// Fetch configuration of keyword subscription for the specific repository.
  Future<KeywordSubscription> getKeywordSubscription(
      String repositoryName) async {
    final app = await _ensureApp();
    if (!isLoggedIn) {
      return null;
    }

    final sanitizedRepositoryName = repositoryName.replaceAll('/', r'$');
    final snapshot = await app
        .firestore()
        .doc('github-keyword-subscriptions/$sanitizedRepositoryName')
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return KeywordSubscription(
        label: snapshot.get('label'),
        keywords: snapshot.get('keywords').cast<String>());
  }

  /// Adds a subscription to a label for the current user.
  Future<void> subscribeTo(String repositoryName, String labelName) async {
    final labelId =
        GithubLabel(repositoryName: repositoryName, labelName: labelName)
            .toId();

    final ref = await _computeSubscriptionsRef();
    if (ref == null) {
      return;
    }

    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'email': userEmail,
        'subscriptions': [labelId]
      }, firestore.SetOptions(merge: true));
    } else {
      await ref.update(data: {
        'subscriptions': firestore.FieldValue.arrayUnion([labelId]),
      });
    }
  }

  /// Removes a subscription to a label for the current user.
  Future<void> unsubscribeFrom(String repositoryName, String labelName) async {
    final ref = await _computeSubscriptionsRef();
    if (ref == null) {
      return;
    }

    await ref.update(data: {
      'subscriptions': firestore.FieldValue.arrayRemove([
        GithubLabel(repositoryName: repositoryName, labelName: labelName).toId()
      ]),
    });
  }

  /// Initializes firebase App.
  Future<firebase.App> _ensureApp() async {
    if (_app == null) {
      _app = firebase.initializeApp(
          apiKey: "AIzaSyBFKKpPdV3xPQU4jPYiMvUnUfhB5pDDMRI",
          authDomain: "dart-ci.firebaseapp.com",
          databaseURL: "https://dart-ci.firebaseio.com",
          projectId: "dart-ci",
          storageBucket: "dart-ci.appspot.com");
      await _app.auth().setPersistence(firebase.Persistence.LOCAL);
    }
    return _app;
  }

  /// Returns path to a firestore document which contains subscriptions for
  /// the current logged in user (and null if there is no currently logged in
  /// user).
  Future<firestore.DocumentReference> _computeSubscriptionsRef() async {
    final app = await _ensureApp();

    if (!isLoggedIn) {
      return null;
    }

    final currentUser = app.auth().currentUser;
    final userId = currentUser.uid;
    return app.firestore().doc('github-label-subscriptions/${userId}');
  }
}

/// Describes a label in a specific repository.
class GithubLabel {
  final String repositoryName;
  final String labelName;

  GithubLabel({this.repositoryName, this.labelName});

  factory GithubLabel.fromId(String labelId) {
    final components = labelId.split(':');
    return GithubLabel(
        repositoryName: components.first,
        labelName: components.skip(1).join(':'));
  }

  String toId() => '$repositoryName:$labelName';
}

/// Represents subscription to particular keywords in a repository.
///
/// Whenever a new issue is opened that contains one of the keywords
/// in the body notifier will notify users subscribed to the specified label.
class KeywordSubscription {
  final String label;
  final List<String> keywords;

  KeywordSubscription({this.label, this.keywords});
}

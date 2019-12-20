// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Interface to subscribers information stored in the firestore.
library github_label_notifier.subscriptions_db;

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:meta/meta.dart';

final _app = FirebaseAdmin.instance.initializeApp();
final _firestore = _app.firestore();

void ensureInitialized() {
  // For some reason the very first query takes very long time (>10s).
  // We work around that by making a dummy query at the startup.
  lookupLabelSubscriberEmails('', '');
}

/// Return a list of emails subscribed to the given label in the given
/// repository.
Future<List<String>> lookupLabelSubscriberEmails(
    String repositoryName, String labelName) async {
  final labelId = '${repositoryName}:${labelName}';

  final subscriptions = await _firestore
      .collection('github-label-subscriptions')
      .where('subscriptions', arrayContains: labelId)
      .get();
  return [
    for (final doc in subscriptions.documents) doc.data.getString('email')
  ];
}

/// Represents subscription to particular keywords in the issue body.
///
/// When a match is found we treat it as if the issue was labeled with the
/// given label.
class KeywordSubscription {
  final String label;
  final List<String> keywords;

  KeywordSubscription({@required this.label, @required List<String> keywords})
      : keywords = keywords.where(_isOk).toList();

  /// Checks if the given string contains match to any of the keywords
  /// and returns the matched one.
  String match(String body) {
    return _makeRegExp().firstMatch(body)?.group(0);
  }

  RegExp _makeRegExp() {
    final keywordsAlt = keywords.map((kw) => '$kw').join('|');
    return RegExp('(?<=\\b|_)($keywordsAlt)(?=\\b|_)', caseSensitive: false);
  }

  static final _keywordRegExp = RegExp(r'^[\w_/]+$');
  static bool _isOk(String keyword) => _keywordRegExp.hasMatch(keyword);
}

/// Get keyword subscriptions for the given repository.
Future<KeywordSubscription> lookupKeywordSubscription(
    String repositoryName) async {
  final sanitizedRepositoryName = repositoryName.replaceAll('/', r'$');
  final subscriptions = await _firestore
      .document('github-keyword-subscriptions/$sanitizedRepositoryName')
      .get();

  if (!subscriptions.exists) {
    return null;
  }
  return KeywordSubscription(
      label: subscriptions.data.getString('label'),
      keywords: subscriptions.data.getList('keywords').cast<String>());
}

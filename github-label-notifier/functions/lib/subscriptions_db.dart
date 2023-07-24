// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Interface to subscribers information stored in the firestore.
library github_label_notifier.subscriptions_db;

import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'firestore_helpers.dart';

late final String project;
late final String database;
late final String documents;
late final String keywordCollection;
late final String keywordDatabase;
late final String labelCollection;
late final String labelDatabase;
late final AutoRefreshingAuthClient _client;
late final FirestoreApi _firestore;

Future<void> _ensureInitialized() async {
  _client = await clientViaApplicationDefaultCredentials(
      scopes: ['https://www.googleapis.com/auth/cloud-platform']);
  project = Platform.environment['GCLOUD_PROJECT'] ?? 'dart-ci';
  database = 'projects/$project/databases/(default)';
  documents = '$database/documents';
  keywordCollection = 'github-keyword-subscriptions';
  keywordDatabase = '$documents/$keywordCollection';
  labelCollection = 'github-label-subscriptions';
  labelDatabase = '$documents/$labelCollection';
  final firestoreHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];
  final firestoreUrl = firestoreHost == null
      ? 'https://firestore.googleapis.com/'
      : 'http://$firestoreHost/';
  _firestore = FirestoreApi(_client, rootUrl: firestoreUrl);
  // For some reason the very first query takes very long time (>10s).
  // We work around that by making a dummy query at the startup.
  unawaited(lookupLabelSubscriberEmails('', ''));
}

final ensureInitialized = _ensureInitialized();

/// For testing only - figure out how?
FirestoreApi get firestoreApi => _firestore;

/// Return a list of emails subscribed to the given label in the given
/// repository.
Future<List<String>> lookupLabelSubscriberEmails(
    String repositoryName, String labelName) async {
  final labelId = '$repositoryName:$labelName';

  final subscriptions = await _firestore.projects.databases.documents.runQuery(
      RunQueryRequest(
          structuredQuery: StructuredQuery(
              from: [CollectionSelector(collectionId: labelCollection)],
              where: arrayContains('subscriptions', labelId))),
      documents);
  if (subscriptions.first.document == null) return [];
  return [
    for (final response in subscriptions)
      SafeDocument(response.document!).getString('email')
  ];
}

/// Represents subscription to particular keywords in the issue body.
///
/// When a match is found we treat it as if the issue was labeled with the
/// given label.
class KeywordSubscription {
  final String label;
  final List<String> keywords;

  KeywordSubscription({required this.label, required List<String> keywords})
      : keywords = keywords.where(_isOk).toList();

  /// Checks if the given string contains match to any of the keywords
  /// and returns the matched one.
  String? match(String body) {
    return _makeRegExp().firstMatch(body)?.group(0);
  }

  RegExp _makeRegExp() {
    final keywordsAlt = keywords.map((kw) => kw).join('|');
    return RegExp('(?<=\\b|_)($keywordsAlt)(?=\\b|_)', caseSensitive: false);
  }

  static final _keywordRegExp = RegExp(r'^[\w_/]+$');
  static bool _isOk(String keyword) => _keywordRegExp.hasMatch(keyword);
}

/// Get keyword subscriptions for the given repository.
Future<KeywordSubscription?> lookupKeywordSubscription(
    String repositoryName) async {
  final sanitizedRepositoryName = repositoryName.replaceAll('/', r'$');
  final documentName = '$keywordDatabase/$sanitizedRepositoryName';
  // documents.get fails if the document isn't present.
  // documents.batchGet is broken because of issue googleapis/303.
  // documents.runQuery can not filter on the docuement name.
  // So fetch all keyword documents with documents.listDocuments.
  final subscriptionsDocuments = await _firestore.projects.databases.documents
      .listDocuments(documents, keywordCollection);
  final subscriptionsDocument = subscriptionsDocuments.documents!
      .firstWhereOrNull((document) => document.name == documentName);
  if (subscriptionsDocument == null) {
    return null;
  }
  final subscriptions = SafeDocument(subscriptionsDocument);
  return KeywordSubscription(
      label: subscriptions.getString('label'),
      keywords: subscriptions.getList('keywords')?.cast<String>() ?? []);
}

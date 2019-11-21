// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Interface to subscribers information stored in the firestore.
library github_label_notifier.subscriptions_db;

import 'package:firebase_admin_interop/firebase_admin_interop.dart';

final _app = FirebaseAdmin.instance.initializeApp();
final _firestore = _app.firestore();

void ensureInitialized() {
  // For some reason the very first query takes very long time (>10s).
  // We work around that by making a dummy query at the startup.
  lookupSubscriberEmails('', '');
}

/// Return a list of emails subscribed to the given label in the given
/// repository.
Future<List<String>> lookupSubscriberEmails(
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

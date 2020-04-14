// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase/firestore.dart' as firestore;

import 'firestore_service.dart';

class Build {
  Build.fromDocument(firestore.DocumentSnapshot document) {
    builder = document.get('builder');
    buildNumber = document.get('build_number');
    index = document.get('index');
  }

  String builder;
  int buildNumber;
  int index;

  @override
  String toString() =>
      'Build(builder: $builder, buildNumber: $buildNumber, index: $index)';
}

class BuildService {
  BuildService(this._firestoreService);

  final FirestoreService _firestoreService;
  final Map<String, Map<int, FutureOr<Build>>> _lookupBuild = {};
  Future<Map<String, String>> _builders;
  Future fetchingBuilders;

  FutureOr<Build> buildForResult(String configuration, int index) async {
    _builders ??= _fetchBuilders();
    final builder = (await _builders)[configuration];
    final builds = _lookupBuild.putIfAbsent(builder, () => {});

    return builds.putIfAbsent(index, _fetchBuild(builder, index));
  }

  Future<Build> Function() _fetchBuild(String builder, int index) => () async {
        final buildDocument =
            await _firestoreService.fetchBuild(builder, index);
        return Build.fromDocument(buildDocument);
      };

  Future<Map<String, String>> _fetchBuilders() async {
    await _firestoreService.getFirebaseClient();
    final builderDocs = await _firestoreService.fetchBuilders();
    return {for (var doc in builderDocs) doc.id: doc.get('builder')};
  }
}

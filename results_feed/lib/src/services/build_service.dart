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
  final Map<String, Map<int, Future<Build>>> _builds = {};
  Map<String, String> _builders;
  List<String> _configurations;
  Future _buildersFetched;

  Future get _ready => _buildersFetched ??= _fetchBuilders();

  Future<Build> buildForResult(String configuration, int index) async {
    await _ready;
    final builder = _builders[configuration];
    return _builds
        .putIfAbsent(builder, () => {})
        .putIfAbsent(index, _fetchBuild(builder, index));
  }

  Future<Build> Function() _fetchBuild(String builder, int index) => () async {
        final buildDocument =
            await _firestoreService.fetchBuild(builder, index);
        return Build.fromDocument(buildDocument);
      };

  Future _fetchBuilders() async {
    await _firestoreService.getFirebaseClient();
    final builderDocs = await _firestoreService.fetchBuilders();
    _builders = {for (var doc in builderDocs) doc.id: doc.get('builder')};
  }

  FutureOr<List<String>> get configurations =>
      _configurations ??
      _ready.then((_) => _configurations = _builders.keys.toList());
}

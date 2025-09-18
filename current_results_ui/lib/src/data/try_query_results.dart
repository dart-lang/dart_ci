// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import '../../filter.dart';
import '../../query.dart';
import '../generated/query.pb.dart';
import '../services/results_service.dart';

class TryQueryResults extends QueryResultsBase {
  final int cl;
  final int patchset;
  final ResultsService _resultsService;

  TryQueryResults({
    required this.cl,
    required this.patchset,
    required Filter filter,
    ResultsService? resultsService,
  }) : _resultsService = resultsService ?? ResultsService(),
       super(filter, fetchInitialResults: true, supportsEmptyQuery: true);

  @override
  Stream<Iterable<(ChangeInResult, Result)>> createResultsStream() async* {
    yield await _resultsService.fetchChanges(cl, patchset);
  }
}

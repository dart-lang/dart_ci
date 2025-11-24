// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import '../../../data/models/filter.dart';
import '../../../data/models/review.dart';
import '../../../data/services/results_service.dart';
import '../../../shared/generated/query.pb.dart';
import '../../results_overview/data/results_repository.dart';

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
       super(filter, supportsEmptyQuery: true);

  @override
  Stream<Iterable<(ChangeInResult, Result)>> createResultsStream() async* {
    yield await _resultsService.fetchChanges(cl, patchset);
  }

  Future<Review> fetchReviewInfo() async => _resultsService.fetchReviewInfo(cl);
}

// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'model/review.dart';
import 'src/data/try_query_results.dart';
import 'src/services/results_service.dart';
import 'src/widgets/results_view.dart';

class TryResultsScreen extends StatefulWidget {
  final int initialTabIndex;
  final ResultsService _resultsService;

  TryResultsScreen({
    super.key,
    this.initialTabIndex = 0,
    ResultsService? resultsService,
  }) : _resultsService = resultsService ?? ResultsService();

  @override
  State<TryResultsScreen> createState() => _TryResultsScreenState();
}

class _TryResultsScreenState extends State<TryResultsScreen> {
  Review? _reviewInfo;

  @override
  void initState() {
    super.initState();
    final queryResults = Provider.of<TryQueryResults>(context, listen: false);
    _fetchData(queryResults.cl);
  }

  Future<void> _fetchData(int cl) async {
    final reviewInfo = await widget._resultsService.fetchReviewInfo(cl);
    if (mounted) {
      setState(() {
        _reviewInfo = reviewInfo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final queryResults = context.watch<TryQueryResults>();
    return ResultsView(
      title: _reviewInfo?.subject ?? 'Try Results',
      filter: queryResults.filter,
      initialTabIndex: widget.initialTabIndex,
      showInstructionsOnEmptyQuery: false,
      titleBuilder: (context, title) {
        return InkWell(
          onTap: () => url_launcher.launchUrl(
            Uri.https(
              'dart-review.googlesource.com',
              '/c/sdk/+/${queryResults.cl}/${queryResults.patchset}',
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24.0,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }
}

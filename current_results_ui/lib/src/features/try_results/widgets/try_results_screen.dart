// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../../data/models/review.dart';
import '../../../shared/widgets/results_view.dart';
import '../data/try_results_repository.dart';

class TryResultsScreen extends StatefulWidget {
  const TryResultsScreen({super.key});

  @override
  State<TryResultsScreen> createState() => _TryResultsScreenState();
}

class _TryResultsScreenState extends State<TryResultsScreen> {
  Review? _reviewInfo;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final queryResults = Provider.of<TryQueryResults>(context, listen: false);
    final reviewInfo = await queryResults.fetchReviewInfo();
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

// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../filter.dart';
import '../../query.dart';
import '../../results.dart';
import 'app_bar_actions.dart';

typedef TitleBuilder = Widget Function(BuildContext context, String title);

Widget defaultTitleBuilder(BuildContext context, String title) {
  return Text(title, style: const TextStyle(fontSize: 24.0));
}

class ResultsView extends StatefulWidget {
  final String title;
  final int initialTabIndex;
  final TitleBuilder titleBuilder;
  final bool showInstructionsOnEmptyQuery;
  final Filter filter;

  const ResultsView({
    super.key,
    required this.title,
    required this.filter,
    this.initialTabIndex = 0,
    this.titleBuilder = defaultTitleBuilder,
    this.showInstructionsOnEmptyQuery = true,
  });

  @override
  State<ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    Provider.of<QueryResultsBase>(context, listen: false).filter =
        widget.filter;
    _tabController = TabController(
      initialIndex: widget.initialTabIndex,
      length: 3,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ResultsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      Provider.of<QueryResultsBase>(context, listen: false).filter =
          widget.filter;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TabController>.value(
      value: _tabController,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: const Center(child: FetchingProgress()),
          title: widget.titleBuilder(context, widget.title),
          actions: buildAppBarActions(context),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'FAILURES'),
              Tab(text: 'FLAKES'),
              Tab(text: 'ALL'),
            ],
            onTap: (int tab) {
              final uri = GoRouter.of(
                context,
              ).routeInformationProvider.value.uri;
              final newUri = uri.replace(
                queryParameters: {
                  ...uri.queryParameters,
                  'showAll': tab == 2 ? 'true' : null,
                  'flaky': tab == 1 ? 'true' : null,
                }..removeWhere((key, value) => value == null),
              );
              GoRouter.of(context).go(newUri.toString());
            },
          ),
        ),
        persistentFooterButtons: const [
          ResultsSummary(),
          TestSummary(),
          ApiPortalLink(),
          JsonLink(),
          TextPopup(),
        ],
        body: SelectionArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: FilterUI(),
              ),
              const Divider(color: Colors.black12, height: 20),
              Expanded(
                child: ResultsPanel(
                  showInstructionsOnEmptyQuery:
                      widget.showInstructionsOnEmptyQuery,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

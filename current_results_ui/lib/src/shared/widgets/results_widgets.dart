// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../features/results_overview/data/results_repository.dart';
import '../../features/results_overview/presentation/widgets/instructions.dart';
import '../generated/query.pb.dart';

const Color _lightCoral = Color.fromARGB(255, 240, 128, 128);
const Color _gold = Color.fromARGB(255, 255, 215, 0);

enum ResultKind {
  pass(Colors.lightGreen),
  fail(_lightCoral),
  flaky(_gold);

  const ResultKind(this.color);
  final Color color;
}

class ResultsPanel extends StatelessWidget {
  final bool showInstructionsOnEmptyQuery;
  const ResultsPanel({super.key, this.showInstructionsOnEmptyQuery = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResultsBase>(
      builder: (context, queryResults, child) {
        if (!queryResults.hasQuery && showInstructionsOnEmptyQuery) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Instructions(),
          );
        }

        final counts = queryResults.counts;
        final tabController = Provider.of<TabController>(context);

        bool isFailed(String name) => counts[name]!.countFailing > 0;
        bool isFlaky(String name) => counts[name]!.countFlaky > 0;
        bool all(String name) => true;

        final filter = [isFailed, isFlaky, all][tabController.index];
        final filteredNames = queryResults.names.where(filter).toList();

        return ListView.builder(
          primary: true,
          itemCount: filteredNames.length,
          itemBuilder: (BuildContext context, int index) {
            final name = filteredNames[index];
            final changeGroups = queryResults.grouped[name]!;
            final counts = queryResults.counts[name]!;

            return ExpandableResult(name, changeGroups, counts, index % 2 == 1);
          },
        );
      },
    );
  }
}

class ExpandableResult extends StatefulWidget {
  final String name;
  final Map<ChangeInResult, List<Result>> changeGroups;
  final Counts counts;
  final bool oddRow;

  ExpandableResult(this.name, this.changeGroups, this.counts, this.oddRow)
    : super(key: Key(name));

  @override
  State<ExpandableResult> createState() => _ExpandableResultState();
}

class _ExpandableResultState extends State<ExpandableResult> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    final changeGroups = widget.changeGroups;
    final backgroundColor = widget.oddRow ? Colors.grey[200] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: backgroundColor,
          child: Row(
            key: ValueKey(name),
            children: [
              const SizedBox(width: 8),
              IconButton(
                icon: expanded
                    ? const Icon(Icons.keyboard_arrow_down)
                    : const Icon(Icons.keyboard_arrow_right),
                onPressed: () => setState(() => expanded = !expanded),
                splashRadius: 20,
              ),
              for (final item in countItems(widget.counts))
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        item.text,
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 16.0),
                    maxLines: 1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Tooltip(
                  message: 'Show latest failures',
                  waitDuration: const Duration(milliseconds: 500),
                  child: IconButton(
                    icon: const Icon(Icons.history),
                    splashRadius: 20,
                    onPressed: () => url_launcher.launchUrl(
                      Uri(
                        path: '/',
                        fragment: 'showLatestFailures=false&test=$name',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: backgroundColor,
          padding: const EdgeInsets.only(left: 76),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topLeft,
            firstChild: const Row(),
            secondChild: ExpandedResultInfo(
              changeGroups: changeGroups,
              name: name,
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ),
      ],
    );
  }
}

class ExpandedResultInfo extends StatelessWidget {
  const ExpandedResultInfo({
    required this.changeGroups,
    required this.name,
    super.key,
  });

  final Map<ChangeInResult, List<Result>> changeGroups;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final ChangeInResult change in changeGroups.keys)
          for (final result in changeGroups[change]!)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: change.kind.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(change.text),
                ),
                const SizedBox(width: 5),
                Flexible(child: Text(result.configuration, maxLines: 1)),
                if (change.kind == ResultKind.fail)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: _link(
                      "log",
                      _openTestLog(result.configuration, name),
                    ),
                  ),
                const SizedBox(width: 5),
                _link("source", _openTestSource(result.revision, result.name)),
              ],
            ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class CountItem {
  final String text;
  final Color color;

  CountItem._(this.text, this.color);

  factory CountItem(int count, Color color) {
    return CountItem._('$count', color);
  }
}

List<CountItem> countItems(Counts counts) {
  return [
    if (counts.countPassing > 0)
      CountItem(counts.countPassing, ResultKind.pass.color),
    if (counts.countFailing > 0)
      CountItem(counts.countFailing, ResultKind.fail.color),
    if (counts.countFlaky > 0)
      CountItem(counts.countFlaky, ResultKind.flaky.color),
  ];
}

Widget _link(String text, Function onClick) {
  final link = Text(
    text,
    style: const TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
  );
  return InkWell(onTap: onClick as void Function()?, child: link);
}

Function _openTestSource(String revision, String name) {
  return () {
    url_launcher.launchUrl(
      Uri.https('dart-ci.appspot.com', '/test/$revision/$name'),
    );
  };
}

Function _openTestLog(String configuration, String name) {
  return () {
    url_launcher.launchUrl(
      Uri.https('dart-ci.appspot.com', '/log/any/$configuration/latest/$name'),
    );
  };
}

class ResultsSummary extends StatelessWidget {
  const ResultsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResultsBase>(
      builder: (context, results, child) {
        return Summary("Results:", results.resultCounts);
      },
    );
  }
}

class FetchingProgress extends StatelessWidget {
  const FetchingProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResultsBase>(
      builder: (context, results, child) {
        if (results.isDone) {
          return const SizedBox();
        } else {
          return const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          );
        }
      },
    );
  }
}

class TestSummary extends StatelessWidget {
  const TestSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResultsBase>(
      builder: (context, results, child) {
        return Summary("Tests:", results.testCounts);
      },
    );
  }
}

class Summary extends StatelessWidget {
  final String typeText;
  final Counts counts;

  const Summary(this.typeText, this.counts, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(typeText, style: const TextStyle(fontWeight: FontWeight.bold)),
        Pill(ResultKind.fail.color, counts.countFailing, 'failing'),
        Pill(ResultKind.flaky.color, counts.countFlaky, 'flaky'),
        Pill(Colors.black26, counts.count, 'total'),
        SizedBox.fromSize(size: const Size.fromWidth(8.0)),
      ],
    );
  }
}

class Pill extends StatelessWidget {
  static final intl.NumberFormat nf = intl.NumberFormat.decimalPattern();

  final Color color;
  final int count;
  final String tooltip;

  const Pill(this.color, this.count, this.tooltip, {super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 2.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Text(nf.format(count), style: const TextStyle(fontSize: 14.0)),
      ),
    );
  }
}

class ApiPortalLink extends StatelessWidget {
  const ApiPortalLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('API portal'),
      onPressed: () => url_launcher.launchUrl(
        Uri.https(
          'endpointsportal.dart-ci.cloud.goog',
          '/docs/current-results-qvyo5rktwa-uc.a.run.app/g'
              '/routes/v1/results/get',
        ),
      ),
    );
  }
}

class JsonLink extends StatelessWidget {
  const JsonLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResultsBase>(
      builder: (context, results, child) {
        return TextButton(
          child: const Text('JSON'),
          onPressed: () => url_launcher.launchUrl(
            Uri.https(apiHost, 'v1/results', {
              'filter': results.filter.terms.join(','),
              'pageSize': '4000',
            }),
          ),
        );
      },
    );
  }
}

class TextPopup extends StatelessWidget {
  const TextPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResultsBase>(
      builder: (context, QueryResultsBase results, child) {
        return Tooltip(
          message: 'Results query as text',
          waitDuration: const Duration(milliseconds: 500),
          child: TextButton(
            child: const Text('Copy to clipboard as text'),
            onPressed: () {
              final text = [resultTextHeader]
                  .followedBy(
                    results.names
                        .expand((name) => results.grouped[name]!.values)
                        .expand((list) => list)
                        .map(resultAsCommaSeparated),
                  )
                  .join('\n');
              Clipboard.setData(ClipboardData(text: text));
            },
          ),
        );
      },
    );
  }
}

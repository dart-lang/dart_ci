// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Add fields with data about the test run and the commit tested, and
// with the result on the last build tested, to the test results file.

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:resource/resource.dart' show Resource;

import 'package:dart_ci/src/fetch_changes.dart';

class MinMax {
  int min = null;
  int max = null;

  void add(int value) {
    if (value == null) return;
    if (min == null || value < min) min = value;
    if (max == null || value > max) max = value;
  }

  String toString() => "($min:$max)";
}

/// A map containing sorted lists of configurations as values.  The keys
/// are the configurations in that set joined by "<br>". We need these
/// sets as keys in a later map, so we use the keys, and can recover the sets.
Map<String, List<String>> configSets;

class SummaryData {
  final String configSetKey;
  final String test;

  /// Test name, including suite
  final String change;

  /// Change in results, as string "was, now, expected"
  final MinMax previousCommits;

  /// MinMax of indices of commits before this change
  final MinMax commits;

  /// MinMax of indices of commits after or at this change.

  SummaryData(this.configSetKey, this.test, this.change, this.previousCommits,
      this.commits);
}

/// Sort SummaryData objects first by blamelist end, then by blamelist start,
/// by configSetKey, and finally by name.
/// All objects with the same blamelist and same
/// configSetKey will then be grouped together.
int compare4keys(SummaryData a, SummaryData b) {
  return [
    a.commits.max.compareTo(b.commits.max),
    a.previousCommits.min.compareTo(b.previousCommits.min),
    a.configSetKey.compareTo(b.configSetKey),
    a.test.compareTo(b.test)
  ].firstWhere((c) => c != 0, orElse: () => 0);
}

Future<String> createChangesPage() async {
  final hashes = <String>[];
  final commitData = <String>[];
  final reviewLinks = <String>[];
  const reviewPrefix = "Reviewed-on: ";
  // Load data from gerrit/git REST API
  final commits = (await commitInformation())["log"] as List<dynamic>;
  for (Map<String, dynamic> commit in commits) {
    hashes.add(commit["commit"]);
    reviewLinks.add(commit["message"]
        .split('\n')
        .firstWhere((String line) => line.startsWith(reviewPrefix),
            orElse: () =>
                reviewPrefix +
                "https://dart.googlesource.com/sdk/+/" +
                commit["commit"])
        .substring(reviewPrefix.length));
    // Time comes as a string in format "Wed Apr 03 15:03:46 2019 +0000"
    // This comes from the Gitiles API at
    // http://go/gob/users/rest-api#gitiles-api.
    final time = commit["committer"]["time"].substring(0, 16);
    final author = commit["author"]["email"];
    final subject = LineSplitter.split(commit["message"]).first;
    commitData.add("$time $author $subject");
  }

  // Changes come from global server data, fetched by server.
  final summaryData = summarizePageData(changes, hashes);
  summaryData.sort(compare4keys);
  return htmlPage(summaryData, hashes, commitData, reviewLinks);
}

/// Fetch information about the commits to sdk @ dart.googlesource
/// using Gitiles API: http://go/gob/users/rest-api#gitiles-api
Future<Map<String, dynamic>> commitInformation() async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(
      "https://dart.googlesource.com/sdk/+log/master?n=400&format=JSON"));
  final response = await request.close();
  return (await response
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .skip(1)
      .transform(json.decoder)
      .single) as Map<String, dynamic>;
}

/// Group all changes by test name, change in result (all three of
/// previous result, new result, expected result in one key).
/// Dynamically create subgroups from this sorted group by greedily
/// taking all changes whose blamelist intersects with the blamelist
/// that starts last, taking them out to form a subgroup, and repeating.
/// For each subgroup, take the configurations of all the changes, and make
/// this set of configurations a key (by sorting and toString).
/// Create a data object summarizing this subgroup, with the test name,
/// change in result, set of configurations,
/// and blamelist intersection and union of the changes in this subgroup.
/// Report this list of summary objects.
List<SummaryData> summarizePageData(
    List<dynamic> changes, List<String> hashes) {
  final Map<String, int> hashIndex = Map.fromEntries(
      Iterable.generate(hashes.length, (i) => MapEntry(hashes[i], i)));

  final resultsForTestAndChange =
      Map<String, Map<String, List<Map<String, dynamic>>>>();

  for (final Map<String, dynamic> change in changes) {
    String key;
    if ('true' == change['matches'] ||
        change['matches'] is bool && change['matches']) {
      key =
          "${change['previous_result']} -> <strong>${change['result']} &#x2714;</strong>";
    } else {
      key =
          "${change['previous_result']} -> <strong>${change['result']}</strong>  (expected ${change['expected']})";
    }
    resultsForTestAndChange
        .putIfAbsent(
            change['name'], () => Map<String, List<Map<String, dynamic>>>())
        .putIfAbsent(key, () => <Map<String, dynamic>>[])
        .add(change);
  }

  configSets = <String, List<String>>{};
  final summarizedData = <SummaryData>[];

  for (final test in resultsForTestAndChange.keys) {
    for (final results in resultsForTestAndChange[test].keys) {
      var changesToProcess = resultsForTestAndChange[test][results];
      while (changesToProcess.isNotEmpty) {
        final previousHashIndexes = MinMax();
        for (final change in changesToProcess) {
          previousHashIndexes.add(hashIndex[change["previous_commit_hash"]]);
        }
        // SectionLimit is the index of the latest commit where a change
        // is known to happen _after_ that point.
        final sectionLimit = previousHashIndexes.min;

        // We found the change that happened the latest (the commit before it
        // happened is the latest).  We take all changes that _could_ have
        // happened on the same commit as this one. These are the changes whose
        // blamelists intersect with it.  So we take all changes that first see
        // the change after sectionLimit.
        final firstSection = <Map<String, dynamic>>[];
        final remainingChanges = <Map<String, dynamic>>[];
        for (final change in changesToProcess) {
          if (hashIndex[change["commit_hash"]] < sectionLimit) {
            firstSection.add(change);
          } else {
            remainingChanges.add(change);
          }
        }
        changesToProcess = remainingChanges;

        // Summarize firstSection into a SummaryData object.
        final configs = <String>[];
        final previousCommits = MinMax();
        final commits = MinMax();
        for (var change in firstSection) {
          configs.add(change["configuration"]);
          previousCommits.add(hashIndex[change["previous_commit_hash"]]);
          commits.add(hashIndex[change["commit_hash"]]);
        }
        configs.sort();
        final configSetKey = configs.join(",<br>");
        configSets[configSetKey] = configs;
        summarizedData.add(
            SummaryData(configSetKey, test, results, previousCommits, commits));
      }
    }
  }
  return summarizedData;
}

String prelude() => '''
<!DOCTYPE html><html><head><title>Results Feed</title>
<style>
  span.indent   {padding-left: 4em;}
  textarea      {font-family: monospace;}
  span.commit   {font-family: monospace; color: gray;}
  td            {font-family: monospace;}
  div.blamelist {font-family: monospace; background-color: lightgray; padding: 10px;}
  h1            {color: blue;}
  td            {vertical-align: top;}
  td.outer      {padding: 10px;}
  td.nopad      {padding: 0px;}
  td.nomatch    {background-color: Salmon;}
  td.match      {background-color: PaleGreen;}
</style>
<script>function showBlamelist(id) {
  if (document.getElementById(id + "-off").style.display == "none") {
    document.getElementById(id + "-on").style.display = "none";
    document.getElementById(id + "-off").style.display = "block";
  } else {
    document.getElementById(id + "-off").style.display = "none";
    document.getElementById(id + "-on").style.display = "block";
  }
}

function showInline(id) {
  if (document.getElementById(id + "-off").style.display == "none") {
    document.getElementById(id + "-on").style.display = "none";
    document.getElementById(id + "-off").style.display = "inline";
  } else {
    document.getElementById(id + "-off").style.display = "none";
    document.getElementById(id + "-on").style.display = "inline";
  }
}
</script>
</head><body><h1>Results Feed</h1>
''';

String postlude() => '''</body></html>''';

String htmlPage(List<SummaryData> data, List<String> hashes,
    List<String> commitData, List<String> reviewLinks) {
  var idCounter = 1;
  String getNewId() {
    idCounter++;
    return "id$idCounter";
  }

  // Group the summaries by blamelist end, blamelist begin, and config set.
  List groups = [
    [
      [
        [data.first]
      ]
    ]
  ];
  SummaryData previous = data.first;
  for (SummaryData summary in data.skip(1)) {
    if (previous.commits.max != summary.commits.max) {
      groups.add([
        [
          [summary]
        ]
      ]);
    } else if (previous.previousCommits.min != summary.previousCommits.min) {
      groups.last.add([
        [summary]
      ]);
    } else if (previous.configSetKey != summary.configSetKey) {
      groups.last.last.add([summary]);
    } else {
      groups.last.last.last.add(summary);
    }
    previous = summary;
  }

  StringBuffer page = StringBuffer(prelude());
  page.write("<table>");

  int commit = 0;
  for (final blamelistEndList in groups) {
    int blamelistEnd = blamelistEndList.last.last.last.commits.max;
    for (; commit <= blamelistEnd; ++commit) {
      // Info from git about this commit:
      page.write("<span class='commit'><a href='${reviewLinks[commit]}'>"
          "${hashes[commit].substring(0, 8)}</a>&nbsp;&nbsp;"
          "${commitData[commit]}</span><br>");
    }

    for (final blamelistList in blamelistEndList) {
      int blamelistBegin = blamelistList.last.last.previousCommits.min;
      // Output a blamelist
      void writeChange(int i) {
        page.write(
            "<span class='indent'><a href='${reviewLinks[i]}'>${hashes[i]}</a>"
            " ${commitData[i]}</span><br>");
      }

      final size = blamelistBegin - blamelistEnd;
      page.write("<div class='blamelist'><strong>Blamelist:</strong><br>");
      const int summarize_size = 6;
      if (size < summarize_size) {
        for (int i = blamelistEnd; i < blamelistBegin; ++i) {
          writeChange(i);
        }
      } else {
        var id = '$blamelistEnd-$blamelistBegin';
        page.write("<div onclick='showBlamelist(\"$id\")'>");
        for (int i = blamelistEnd; i < blamelistEnd + 3; ++i) {
          writeChange(i);
        }
        page.write("<div class='expand_off' id='$id-off'>"
            "<span class='indent'>...</span></div>");
        page.write("<div class='expand_on' id='$id-on' style='display:none'>");
        for (int i = blamelistEnd + 3; i < blamelistBegin - 1; ++i) {
          writeChange(i);
        }
        page.write("</div>");
        writeChange(blamelistBegin - 1);
        page.write("</div>");
      }
      page.write("</div>");

      for (final configSetList in blamelistList) {
        page.write("<table>");
        for (final summary in configSetList) {
          var testclass = "nomatch";
          if (summary.change.endsWith("&#x2714;</strong>")) {
            // Test matches
            testclass = "match";
          }
          page.write("<tr><td class='$testclass'>${summary.test}</td>"
              "<td class='$testclass'> &nbsp;&nbsp;${summary.change}</td></tr>");
        }
        page.write("</table>");

        final configSetKey = configSetList.last.configSetKey;
        final configSet = configSets[configSetKey];
        var plural = "s";
        if (configSet.length == 1) plural = "";
        page.write("&nbsp;&nbsp;&nbsp;&nbsp;on configuration$plural ");

        final configsByProduct = SplayTreeMap<String, List<String>>();
        for (final config in configSet) {
          configsByProduct
              .putIfAbsent(config.split('-').first, () => <String>[])
              .add(config);
        }
        for (final entry in configsByProduct.entries) {
          if (entry.value.length == 1) {
            page.write("${entry.value.first} ");
          } else {
            final id = getNewId();
            page.write("<span class='expand_off' onclick='showInline(\"$id\")' "
                "id='$id-off'>${entry.key}... </span>");
            page.write("<span class='expand_on' onclick='showInline(\"$id\")' "
                "id='$id-on' style='display:none'>");
            page.write(" ${entry.value.join(' ')} </span>");
          }
        }
        page.write("<br><br>");
      }
    }
  }
  page.write(postlude());
  return page.toString();
}

Future<List<String>> loadLines(Resource resource) => resource
    .openRead()
    .transform(utf8.decoder)
    .transform(LineSplitter())
    .toList();

Future<Object> loadJson(Resource resource) async {
  final json = await resource.openRead().transform(utf8.decoder).join();
  return jsonDecode(json);
}

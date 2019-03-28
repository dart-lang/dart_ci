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

Map<String, List<String>> configSets;
int idCounter = 1;

class ByConfigSetData {
  String formattedConfigSet;
  String test; // Test name, including suite
  String change; // Change in results, reported as string "was, now, expected"
  MinMax before; // MinMax of indices of commits before this change
  MinMax after; // MinMax of indices of commits after or at this change.

  ByConfigSetData(
      this.formattedConfigSet, this.test, this.change, this.before, this.after);
}

Future<String> createChangesPage() async {
  var hashes = <String>[];
  var commitData = <String>[];
  var reviewLinks = <String>[];
  const reviewPrefix = "Reviewed-on: ";
  // Load data from gerrit/git REST API
  final commits = (await commitInformation())["log"] as List<dynamic>;
  for (Map<String, dynamic> commit in commits) {
    hashes.add(commit["commit"]);
    reviewLinks.add(commit["message"]
        .split('\n')
        .firstWhere((String line) => line.startsWith(reviewPrefix),
            orElse: () =>
                "${reviewPrefix}https://dart.googlesource.com/sdk/+/${hashes.last}")
        .substring(reviewPrefix.length));
    final time = commit["committer"]["time"].substring(0, 16);
    final author = commit["author"]["email"];
    final subject = commit["message"].split('\n').first;
    commitData.add("$time $author $subject");
  }

  // Changes come from global server data, fetched by server.
  final data = computePageData(changes, hashes);
  return htmlPage(data, hashes, commitData, reviewLinks);
}

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
/// Store a data object summarizing this subgroup, with the test name,
/// change in result, set of configurations,
/// and blamelist intersection and union of the changes in this subgroup.
/// The object is stored in a multi-level map keyed by blamelist intersection
/// last commit, blamelist intersection first commit, and set of configurations.
Map<int, Map<int, Map<String, List<ByConfigSetData>>>> computePageData(
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

  configSets = Map<String, List<String>>();
  final byBlamelist = Map<int, Map<int, Map<String, List<ByConfigSetData>>>>();

  for (final test in resultsForTestAndChange.keys) {
    for (final results in resultsForTestAndChange[test].keys) {
      var changes = resultsForTestAndChange[test][results];
      while (changes.isNotEmpty) {
        var before = MinMax();
        for (var change in changes) {
          before.add(hashIndex[change["previous_commit_hash"]]);
        }
        // Sort changes by before, take all where after < first before, repeat
        var firstSection = changes
            .where((change) => hashIndex[change["commit_hash"]] < before.min)
            .toList();
        changes = changes
            .where((change) => hashIndex[change["commit_hash"]] >= before.min)
            .toList();
        final configs = <String>[];
        before = MinMax();
        final after = MinMax();
        for (var change in firstSection) {
          configs.add(change["configuration"]);
          before.add(hashIndex[change["previous_commit_hash"]]);
          after.add(hashIndex[change["commit_hash"]]);
        }
        configs.sort();
        final formattedSet = configs.join(",<br>");
        configSets[formattedSet] = configs;
        final summaryData =
            ByConfigSetData(formattedSet, test, results, before, after);
        byBlamelist
            .putIfAbsent(summaryData.after.max,
                () => Map<int, Map<String, List<ByConfigSetData>>>())
            .putIfAbsent(summaryData.before.min,
                () => Map<String, List<ByConfigSetData>>())
            .putIfAbsent(
                summaryData.formattedConfigSet, () => List<ByConfigSetData>())
            .add(summaryData);
      }
    }
  }
  return byBlamelist;
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

String htmlPage(Map<int, Map<int, Map<String, List<ByConfigSetData>>>> data,
    List<String> hashes, List<String> commitData, List<String> reviewLinks) {
  StringBuffer page = StringBuffer(prelude());

  page.write("<table>");
  var after = MinMax();
  data.keys.forEach(after.add);
  for (var afterKey = 0; afterKey <= after.max; ++afterKey) {
    // Info from git about this commit:
    page.write("<span class='commit'><a href='${reviewLinks[afterKey]}'>"
        "${hashes[afterKey].substring(0, 8)}</a>&nbsp;&nbsp;"
        "${commitData[afterKey]}</span><br>");
    if (!data.containsKey(afterKey)) continue;
    final beforeKeys = data[afterKey].keys.toList()..sort();
    for (var beforeKey in beforeKeys) {
      void writeChange(int i) {
        page.write(
            "<span class='indent'><a href='${reviewLinks[i]}'>${hashes[i]}</a>"
            " ${commitData[i]}</span><br>");
      }

      final size = beforeKey - afterKey;
      page.write("<div class='blamelist'><strong>Blamelist:</strong><br>");
      const int summarize_size = 6;
      if (size < summarize_size) {
        for (int i = afterKey; i < beforeKey; ++i) {
          writeChange(i);
        }
      } else {
        var id = '$afterKey-$beforeKey';
        page.write("<div onclick='showBlamelist(\"$id\")'>");
        for (int i = afterKey; i < afterKey + 3; ++i) {
          writeChange(i);
        }
        page.write("<div class='expand_off' id='$id-off'>"
            "<span class='indent'>...</span></div>");
        page.write("<div class='expand_on' id='$id-on' style='display:none'>");
        for (int i = afterKey + 3; i < beforeKey - 1; ++i) {
          writeChange(i);
        }
        page.write("</div>");
        writeChange(beforeKey - 1);
        page.write("</div>");
      }
      page.write("</div>");

      var configSetKeys = data[afterKey][beforeKey].keys.toList()..sort();
      for (var configSetKey in configSetKeys) {
        page.write("<table>");
        final tests = data[afterKey][beforeKey][configSetKey]
          ..sort((a, b) => a.test.compareTo(b.test));
        for (final test in tests) {
          var testclass = "nomatch";
          if (test.change.endsWith("&#x2714;</strong>")) {
            // Test matches
            testclass = "match";
          }
          page.write("<tr><td class='$testclass'>${test.test}</td>"
              "<td class='$testclass'> &nbsp;&nbsp;${test.change}</td></tr>");
        }
        page.write("</table>");

        var plural = "s";
        if (configSets[configSetKey].length == 1) plural = "";
        page.write("&nbsp;&nbsp;&nbsp;&nbsp;on configuration$plural");

        final configsByProduct = SplayTreeMap<String, List<String>>();
        for (final config in configSets[configSetKey]) {
          configsByProduct
              .putIfAbsent(config.split('-').first, () => <String>[])
              .add(config);
        }
        for (final entry in configsByProduct.entries) {
          if (entry.value.length == 1) {
            page.write("${entry.value.first} ");
          } else {
            idCounter++;
            final id = "p$idCounter";
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

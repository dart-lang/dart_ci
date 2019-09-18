// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Feed of recent approvals.

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dart_ci/src/get_log.dart';

// TODO: Hack.
const builders = [
  "analyzer-analysis-server-linux",
  "analyzer-linux-release",
  "analyzer-mac-release",
  "analyzer-win-release",
  "app-kernel-linux-debug-x64",
  "app-kernel-linux-product-x64",
  "app-kernel-linux-release-x64",
  "cross-vm-linux-release-arm64",
  "dart2js-csp-minified-linux-x64-chrome",
  "dart2js-minified-strong-linux-x64-d8",
  "dart2js-strong-hostasserts-linux-ia32-d8",
  "dart2js-strong-linux-x64-chrome",
  "dart2js-strong-linux-x64-firefox",
  "dart2js-strong-mac-x64-chrome",
  "dart2js-strong-mac-x64-safari",
  "dart2js-strong-win-x64-chrome",
  "dart2js-strong-win-x64-ie11",
  "dart2js-unit-linux-x64-release",
  "ddc-linux-release-chrome",
  "ddc-mac-release-chrome",
  "ddc-win-release-chrome",
  "front-end-linux-release-x64",
  "front-end-mac-release-x64",
  "front-end-win-release-x64",
  "pkg-linux-debug",
  "pkg-linux-release",
  "pkg-mac-release",
  "pkg-win-release",
  "vm-canary-linux-debug",
  "vm-dartkb-linux-debug-simarm64",
  "vm-dartkb-linux-debug-x64",
  "vm-dartkb-linux-product-simarm64",
  "vm-dartkb-linux-product-x64",
  "vm-dartkb-linux-release-simarm64",
  "vm-dartkb-linux-release-x64",
  "vm-ffi-android-debug-arm",
  "vm-ffi-android-debug-arm64",
  "vm-ffi-android-product-arm",
  "vm-ffi-android-product-arm64",
  "vm-ffi-android-release-arm",
  "vm-ffi-android-release-arm64",
  "vm-kernel-asan-linux-release-x64",
  "vm-kernel-checked-linux-release-x64",
  "vm-kernel-linux-debug-ia32",
  "vm-kernel-linux-debug-simdbc64",
  "vm-kernel-linux-debug-x64",
  "vm-kernel-linux-product-x64",
  "vm-kernel-linux-release-ia32",
  "vm-kernel-linux-release-simarm",
  "vm-kernel-linux-release-simarm64",
  "vm-kernel-linux-release-simdbc64",
  "vm-kernel-linux-release-x64",
  "vm-kernel-mac-debug-simdbc64",
  "vm-kernel-mac-debug-x64",
  "vm-kernel-mac-product-x64",
  "vm-kernel-mac-release-simdbc64",
  "vm-kernel-mac-release-x64",
  "vm-kernel-optcounter-threshold-linux-release-ia32",
  "vm-kernel-optcounter-threshold-linux-release-x64",
  "vm-kernel-precomp-android-release-arm",
  "vm-kernel-precomp-bare-linux-release-simarm",
  "vm-kernel-precomp-bare-linux-release-simarm64",
  "vm-kernel-precomp-bare-linux-release-x64",
  "vm-kernel-precomp-linux-debug-x64",
  "vm-kernel-precomp-linux-product-x64",
  "vm-kernel-precomp-linux-release-simarm",
  "vm-kernel-precomp-linux-release-simarm64",
  "vm-kernel-precomp-linux-release-x64",
  "vm-kernel-precomp-mac-release-simarm64",
  "vm-kernel-precomp-obfuscate-linux-release-x64",
  "vm-kernel-precomp-win-release-simarm64",
  "vm-kernel-precomp-win-release-x64",
  "vm-kernel-reload-linux-debug-x64",
  "vm-kernel-reload-linux-release-x64",
  "vm-kernel-reload-mac-debug-simdbc64",
  "vm-kernel-reload-mac-release-simdbc64",
  "vm-kernel-reload-rollback-linux-debug-x64",
  "vm-kernel-reload-rollback-linux-release-x64",
  "vm-kernel-win-debug-ia32",
  "vm-kernel-win-debug-x64",
  "vm-kernel-win-product-x64",
  "vm-kernel-win-release-ia32",
  "vm-kernel-win-release-x64",
];

class Approval implements Comparable {
  final String builder;
  final String configuration;
  final String name;
  final String suite;
  final String testName;
  final String result;
  final bool matches;

  Approval(this.builder, this.configuration, this.name, this.suite,
      this.testName, this.result, this.matches);

  String get sortKey => "$name:$configuration";

  bool operator ==(Object other) =>
      other is Approval && other.sortKey == sortKey;

  int compareTo(Object other) {
    if (other is Approval) {
      return sortKey.compareTo(other.sortKey);
    }
    return -1;
  }
}

class ApprovalEvent {
  final approver;
  final approvedAt;
  final changeId;

  ApprovalEvent(this.approver, this.approvedAt, this.changeId);

  final approvals = new SplayTreeSet<Approval>();
}

final approvalEvents = new SplayTreeMap<String, ApprovalEvent>();

Future getApprovals() async {
  for (final builder in builders) {
    try {
      print("Downloading approvals for $builder");
      final data = await getApproval(builder);
      if (data == null) continue;
      for (final line in LineSplitter.split(data)) {
        final record = jsonDecode(line);
        final approver = record["approver"];
        final approvedAt = record["approved_at"];
        if (approver == null || approvedAt == null) {
          continue;
        }
        final String name = record["name"];
        final String configuration = record["configuration"];
        final String suite = record["suite"];
        final String testName = record["test_name"];
        final String result = record["result"];
        final bool matches = record["matches"];
        if (matches) continue;
        final approvalEvent = approvalEvents.putIfAbsent(
            approvedAt, () => new ApprovalEvent(approver, approvedAt, null));
        final approval = new Approval(
            builder, configuration, name, suite, testName, result, matches);
        approvalEvent.approvals.add(approval);
        final preapprovals = record["preapprovals"] ?? <String, dynamic>{};
        for (final changeId in preapprovals.keys) {
          final preapprovalRecord = preapprovals[changeId];
          final preapprover = preapprovalRecord["preapprover"];
          final preapprovedAt = preapprovalRecord["preapproved_at"];
          final String preapprovedResult = preapprovalRecord["result"];
          final bool preapprovedMatches = preapprovalRecord["matches"];
          if (preapprovedMatches) continue;
          final preapprovalEvent = approvalEvents.putIfAbsent(
              "preapprovedAt $changeId",
              () => new ApprovalEvent(preapprover, preapprovedAt, changeId));
          final preapproval = new Approval(builder, configuration, name, suite,
              testName, preapprovedResult, preapprovedMatches);
          preapprovalEvent.approvals.add(preapproval);
        }
      }
    } catch (e, st) {
      print("Failed to download approvals for $builder: $e\n$st");
    }
  }
}

void serveApprovals(HttpRequest request) async {
  request.response.headers.contentType = ContentType.html;
  request.response.write("""<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Approvals Feed</title>
  </head>
  <body>
    <h1>Approvals Feed</h1>
""");
  for (final event in approvalEvents.values.toList().reversed.take(100)) {
    final time = event.approvedAt.replaceAll("T", " ").substring(0, 19);
    final approver = event.approver;
    final action = event.changeId != null
        ? "<a href='https://dart-review.googlesource.com/q/${event.changeId}'>"
            "pre-approved ${event.changeId}"
            "</a>"
        : "approved";
    request.response.write("<h2>$time $approver $action</h2>\n");
    request.response.write("<table>\n");
    for (final approval in event.approvals) {
      final what = approval.matches ? "succeeding" : approval.result;
      final color = approval.matches ? "green" : "red";
      request.response.write("<tr>");
      request.response.write("<td>${approval.name}</td>");
      request.response.write("<td><b style='color: $color;'>$what</b></td>");
      request.response.write("<td>${approval.builder}</td>");
      request.response.write("<td>${approval.configuration}</td>");
      request.response.write("</tr>\n");
    }
    request.response.write("</table>\n");
  }
  request.response.write("""  </body>
</html>
""");
  request.response.close();
}

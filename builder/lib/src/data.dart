// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:googleapis/firestore/v1.dart';
import 'firestore_helpers.dart';
import 'result.dart';

extension type ResultRecord(Document doc) {
  ResultRecord.fromMap(Map<String, dynamic> data)
    : this(Document(fields: taggedMap(data)));

  String get name => doc.fields![fName]!.stringValue!;
  set name(String value) => doc.fields![fName] = taggedValue(value);
  String get result => doc.fields![fResult]!.stringValue!;
  String get previousResult => doc.fields![fPreviousResult]!.stringValue!;
  String get expected => doc.fields![fExpected]!.stringValue!;
  int get blamelistStartIndex =>
      int.parse(doc.fields![fBlamelistStartIndex]!.integerValue!);
  int get blamelistEndIndex =>
      int.parse(doc.fields![fBlamelistEndIndex]!.integerValue!);
  bool get approved => doc.fields![fApproved]?.booleanValue ?? false;
  bool get active => doc.fields![fActive]?.booleanValue ?? false;
  List<String> get configurations => doc
      .fields![fConfigurations]!
      .arrayValue!
      .values!
      .map((v) => v.stringValue!)
      .toList();
  List<String>? get activeConfigurations {
    final val = doc.fields![fActiveConfigurations];
    if (val == null || val.nullValue != null) return null;
    return val.arrayValue?.values?.map((v) => v.stringValue!).toList() ?? [];
  }

  int? get pinnedIndex =>
      int.tryParse(doc.fields![fPinnedIndex]?.integerValue ?? '');
  String? get blamelistStartCommit =>
      doc.fields![fBlamelistStartCommit]?.stringValue;
  String? get blamelistEndCommit =>
      doc.fields![fBlamelistEndCommit]?.stringValue;

  set blamelistStartCommit(String? value) =>
      doc.fields![fBlamelistStartCommit] = taggedValue(value);
  set blamelistEndCommit(String? value) =>
      doc.fields![fBlamelistEndCommit] = taggedValue(value);

  String get testResult => [name, result, previousResult, expected].join(' ');

  Map<String, dynamic> toJson() =>
      untagMap(doc.fields!).cast<String, dynamic>();
}

extension type ChangeRecord(Document doc) implements ResultRecord {
  ChangeRecord.fromMap(Map<String, dynamic> data)
    : this(Document(fields: taggedMap(data)));

  String get configuration => doc.fields!['configuration']!.stringValue!;
  String get builderName => doc.fields![fBuilderName]!.stringValue!;
  int get buildNumber => int.parse(doc.fields![fBuildNumber]!.stringValue!);
  String get commitHash => doc.fields![fCommitHash]!.stringValue!;
  set commitHash(String value) => doc.fields![fCommitHash] = taggedValue(value);
  String? get previousCommitHash =>
      doc.fields![fPreviousCommitHash]?.stringValue;

  bool get changed => doc.fields![fChanged]?.booleanValue ?? false;
  bool get flaky => doc.fields![fFlaky]?.booleanValue ?? false;
  bool get previousFlaky => doc.fields![fPreviousFlaky]?.booleanValue ?? false;
  bool get matches => doc.fields![fMatches]?.booleanValue ?? false;

  bool get isChangedResult => changed && (!flaky || !previousFlaky);

  bool get isFailure => !matches && result != 'flaky';

  void transform() {
    if (doc.fields![fPreviousResult]?.stringValue == null) {
      doc.fields![fPreviousResult] = taggedValue('new test');
    }
    if (doc.fields![fPreviousFlaky]?.booleanValue == true) {
      doc.fields![fPreviousResult] = taggedValue('flaky');
    }
    if (doc.fields![fFlaky]?.booleanValue == true) {
      doc.fields![fResult] = taggedValue('flaky');
      doc.fields![fMatches] = taggedValue(false);
    }
  }
}

extension type ConfigurationRecord(Document doc) {
  String get builder => doc.fields!['builder']!.stringValue!;
}

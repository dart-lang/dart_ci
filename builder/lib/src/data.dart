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

extension type TryResultRecord(Document doc) {
  String get name => doc.fields![fName]!.stringValue!;
  String get result => doc.fields![fResult]!.stringValue!;
  String get previousResult => doc.fields![fPreviousResult]!.stringValue!;
  String get expected => doc.fields![fExpected]!.stringValue!;
  int get review => int.parse(doc.fields![fReview]!.integerValue!);
  int get patchset => int.parse(doc.fields!['patchset']!.integerValue!);
  bool get approved => doc.fields![fApproved]?.booleanValue ?? false;
  List<String> get configurations => doc
      .fields![fConfigurations]!
      .arrayValue!
      .values!
      .map((v) => v.stringValue!)
      .toList();

  String get testResult => [name, result, previousResult, expected].join(' ');
}

extension type TryBuildRecord(Document doc) {
  String get builder => doc.fields!['builder']!.stringValue!;
  int get buildNumber => int.parse(doc.fields!['build_number']!.integerValue!);
  String get buildbucketId => doc.fields!['buildbucket_id']!.stringValue!;
  int get review => int.parse(doc.fields![fReview]!.integerValue!);
  int get patchset => int.parse(doc.fields!['patchset']!.integerValue!);
  bool get success => doc.fields!['success']?.booleanValue ?? false;
  bool get completed => doc.fields!['completed']?.booleanValue ?? false;
  bool get truncated => doc.fields!['truncated']?.booleanValue ?? false;
}

extension type BuildRecord(Document doc) {
  String get builder => doc.fields!['builder']!.stringValue!;
  int get buildNumber => int.parse(doc.fields!['build_number']!.integerValue!);
  int get index => int.parse(doc.fields!['index']!.integerValue!);
  bool get success => doc.fields!['success']?.booleanValue ?? false;
  bool get completed => doc.fields!['completed']?.booleanValue ?? false;
}

extension type ReviewRecord(Document doc) {
  String get review => doc.name!.split('/').last;
  String get subject => doc.fields!['subject']!.stringValue!;
  int? get landedIndex =>
      int.tryParse(doc.fields!['landed_index']?.integerValue ?? '');
  String? get revertOf => doc.fields!['revert_of']?.stringValue;
}

extension type PatchsetRecord(Document doc) {
  int get number => int.parse(doc.fields!['number']!.integerValue!);
  int get patchsetGroup =>
      int.parse(doc.fields!['patchset_group']!.integerValue!);
  String get kind => doc.fields!['kind']!.stringValue!;
  String? get description => doc.fields!['description']?.stringValue;
}

extension type CommentRecord(Document doc) {
  String get id => doc.name!.split('/').last;
  String get author => doc.fields!['author']!.stringValue!;
  String get comment => doc.fields!['comment']!.stringValue!;
  int get review => int.parse(doc.fields![fReview]!.integerValue!);
  int? get blamelistStartIndex =>
      int.tryParse(doc.fields![fBlamelistStartIndex]?.integerValue ?? '');
  int? get blamelistEndIndex =>
      int.tryParse(doc.fields![fBlamelistEndIndex]?.integerValue ?? '');
  bool get approved => doc.fields![fApproved]?.booleanValue ?? false;
}

extension type CommitRecord(Document doc) {
  CommitRecord.fromJson(String hash, Map<String, dynamic> data)
    : this(
        Document(
          fields: taggedMap(data),
          name: 'projects/dummy/databases/(default)/documents/commits/$hash',
        ),
      );

  int get index => int.parse(doc.fields![fIndex]!.integerValue!);
  String? get revertOf => doc.fields![fRevertOf]?.stringValue;
  bool get isRevert => doc.fields!.containsKey(fRevertOf);
  int? get review => int.tryParse(doc.fields![fReview]?.integerValue ?? '');
  String get hash => doc.name!.split('/').last;

  Map<String, Object?> toJson() => untagMap(doc.fields!);
}

extension type ConfigurationRecord(Document doc) {
  String get builder => doc.fields!['builder']!.stringValue!;
}

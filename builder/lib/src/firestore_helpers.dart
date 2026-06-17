// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:googleapis/firestore/v1.dart';
import 'result.dart';

extension MapValueExtensions on Map<String, Value> {
  int? getInt(String key) {
    final val = this[key];
    if (val == null || val.nullValue != null) return null;
    return getValue(val) as int?;
  }
  String? getString(String key) {
    final val = this[key];
    if (val == null || val.nullValue != null) return null;
    return getValue(val) as String?;
  }
  bool? getBool(String key) {
    final val = this[key];
    if (val == null || val.nullValue != null) return null;
    return getValue(val) as bool?;
  }
  List<dynamic>? getList(String key) {
    final val = this[key];
    if (val == null || val.nullValue != null) return null;
    return getValue(val) as List<dynamic>?;
  }
  bool isNull(String key) {
    return !containsKey(key) || this[key]!.nullValue == 'NULL_VALUE';
  }
}

Map<String, Value> taggedMap(Map<String, dynamic> fields) {
  return fields.map((key, value) => MapEntry(key, taggedValue(value)));
}

Value taggedValue(dynamic value) {
  if (value is int) {
    return Value()..integerValue = '$value';
  } else if (value is String) {
    return Value()..stringValue = value;
  } else if (value is bool) {
    return Value()..booleanValue = value;
  } else if (value is DateTime) {
    return Value()..timestampValue = value.toUtc().toIso8601String();
  } else if (value is List) {
    return Value()
      ..arrayValue = (ArrayValue()
        ..values = value.map((element) => taggedValue(element)).toList());
  } else if (value == null) {
    return Value()..nullValue = 'NULL_VALUE';
  } else {
    throw Exception('unsupported value type ${value.runtimeType}');
  }
}

dynamic getValue(Value value) {
  if (value.integerValue != null) {
    return int.parse(value.integerValue!);
  } else if (value.stringValue != null) {
    return value.stringValue;
  } else if (value.booleanValue != null) {
    return value.booleanValue;
  } else if (value.arrayValue != null) {
    return value.arrayValue!.values?.map(getValue).toList() ?? [];
  } else if (value.timestampValue != null) {
    return DateTime.parse(value.timestampValue!);
  } else if (value.nullValue != null) {
    return null;
  }
  throw Exception('unsupported value ${value.toJson()}');
}

Map<String, dynamic> untagMap(Map<String, Value> map) {
  return map.map((key, value) => MapEntry(key, getValue(value)));
}

List<CollectionSelector> inCollection(String name) {
  return [CollectionSelector()..collectionId = name];
}

FieldReference field(String name) {
  return FieldReference()..fieldPath = name;
}

Order orderBy(String fieldName, bool ascending) {
  return Order()
    ..field = field(fieldName)
    ..direction = ascending ? 'ASCENDING' : 'DESCENDING';
}

Filter fieldEquals(String fieldName, dynamic value) {
  return Filter()
    ..fieldFilter = (FieldFilter()
      ..field = field(fieldName)
      ..op = 'EQUAL'
      ..value = taggedValue(value));
}

Filter fieldLessThanOrEqual(String fieldName, dynamic value) {
  return Filter()
    ..fieldFilter = (FieldFilter()
      ..field = field(fieldName)
      ..op = 'LESS_THAN_OR_EQUAL'
      ..value = taggedValue(value));
}

Filter fieldGreaterThanOrEqual(String fieldName, dynamic value) {
  return Filter()
    ..fieldFilter = (FieldFilter()
      ..field = field(fieldName)
      ..op = 'GREATER_THAN_OR_EQUAL'
      ..value = taggedValue(value));
}

Filter arrayContains(String fieldName, dynamic value) {
  return Filter()
    ..fieldFilter = (FieldFilter()
      ..field = field(fieldName)
      ..op = 'ARRAY_CONTAINS'
      ..value = taggedValue(value));
}

Filter compositeFilter(List<Filter> filters) {
  return Filter()
    ..compositeFilter = (CompositeFilter()
      ..filters = filters
      ..op = 'AND');
}

extension type ResultRecord(Document doc) {
  ResultRecord.fromMap(Map<String, dynamic> data)
    : this(Document(fields: taggedMap(data)));

  String get testName => doc.fields!.getString(fName)!;
  String get result => doc.fields!.getString(fResult)!;
  String get previousResult => doc.fields!.getString(fPreviousResult)!;
  String get expected => doc.fields!.getString(fExpected)!;
  int get blamelistStartIndex => doc.fields!.getInt(fBlamelistStartIndex)!;
  int get blamelistEndIndex => doc.fields!.getInt(fBlamelistEndIndex)!;
  bool get approved => doc.fields!.getBool(fApproved) ?? false;
  bool get active => doc.fields!.getBool(fActive) ?? false;
  List<String> get configurations => doc.fields!.getList(fConfigurations)!.cast<String>();
  List<String>? get activeConfigurations => doc.fields!.getList(fActiveConfigurations)?.cast<String>();
  int? get pinnedIndex => doc.fields!.getInt(fPinnedIndex);
  String? get blamelistStartCommit => doc.fields!.getString(fBlamelistStartCommit);
  String? get blamelistEndCommit => doc.fields!.getString(fBlamelistEndCommit);

  String get testResult => [
        testName,
        result,
        previousResult,
        expected,
      ].join(' ');
}

extension type TryResultRecord(Document doc) {
  String get testName => doc.fields!.getString(fName)!;
  String get result => doc.fields!.getString(fResult)!;
  String get previousResult => doc.fields!.getString(fPreviousResult)!;
  String get expected => doc.fields!.getString(fExpected)!;
  int get review => doc.fields!.getInt(fReview)!;
  int get patchset => doc.fields!.getInt('patchset')!;
  bool get approved => doc.fields!.getBool(fApproved) ?? false;
  List<String> get configurations => doc.fields!.getList(fConfigurations)!.cast<String>();

  String get testResult => [
        testName,
        result,
        previousResult,
        expected,
      ].join(' ');
}

extension type TryBuildRecord(Document doc) {
  String get builder => doc.fields!.getString('builder')!;
  int get buildNumber => doc.fields!.getInt('build_number')!;
  String get buildbucketId => doc.fields!.getString('buildbucket_id')!;
  int get review => doc.fields!.getInt(fReview)!;
  int get patchset => doc.fields!.getInt('patchset')!;
  bool get success => doc.fields!.getBool('success') ?? false;
  bool get completed => doc.fields!.getBool('completed') ?? false;
  bool get truncated => doc.fields!.getBool('truncated') ?? false;
}

extension type BuildRecord(Document doc) {
  String get builder => doc.fields!.getString('builder')!;
  int get buildNumber => doc.fields!.getInt('build_number')!;
  int get index => doc.fields!.getInt('index')!;
  bool get success => doc.fields!.getBool('success') ?? false;
  bool get completed => doc.fields!.getBool('completed') ?? false;
}

extension type ReviewRecord(Document doc) {
  String get review => doc.name!.split('/').last;
  String get subject => doc.fields!.getString('subject')!;
  int? get landedIndex => doc.fields!.getInt('landed_index');
  String? get revertOf => doc.fields!.getString('revert_of');
}

extension type PatchsetRecord(Document doc) {
  int get number => doc.fields!.getInt('number')!;
  int get patchsetGroup => doc.fields!.getInt('patchset_group')!;
  String get kind => doc.fields!.getString('kind')!;
  String? get description => doc.fields!.getString('description');
}

extension type CommentRecord(Document doc) {
  String get id => doc.name!.split('/').last;
  String get author => doc.fields!.getString('author')!;
  String get comment => doc.fields!.getString('comment')!;
  int get review => doc.fields!.getInt(fReview)!;
  int? get blamelistStartIndex => doc.fields!.getInt(fBlamelistStartIndex);
  int? get blamelistEndIndex => doc.fields!.getInt(fBlamelistEndIndex);
  bool get approved => doc.fields!.getBool(fApproved) ?? false;
}

extension type CommitRecord(Document doc) {
  CommitRecord.fromJson(String hash, Map<String, dynamic> data)
    : this(Document(
        fields: taggedMap(data),
        name: 'projects/dummy/databases/(default)/documents/commits/$hash',
      ));

  int get index => doc.fields!.getInt(fIndex)!;
  String? get revertOf => doc.fields!.getString(fRevertOf);
  bool get isRevert => doc.fields!.containsKey(fRevertOf);
  int? get review => doc.fields!.getInt(fReview);
  String get hash => doc.name!.split('/').last;

  Map<String, Object?> toJson() => untagMap(doc.fields!);
}

extension type ConfigurationRecord(Document doc) {
  String get builder => doc.fields!.getString('builder')!;
}

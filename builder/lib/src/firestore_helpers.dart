// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:googleapis/firestore/v1.dart';

class SafeDocument {
  final String name;
  final Map<String, Value> fields;

  SafeDocument(Document document)
      : name = document.name!,
        fields = document.fields!;

  Document toDocument() => Document(name: name, fields: fields);
  int? getInt(String name) {
    final value = fields[name]?.integerValue;
    if (value == null) {
      return null;
    }
    return int.parse(value);
  }

  String? getString(String name) {
    return fields[name]?.stringValue;
  }

  bool? getBool(String name) {
    return fields[name]?.booleanValue;
  }

  List<dynamic>? getList(String name) {
    final arrayValue = fields[name]?.arrayValue;
    if (arrayValue == null) return null;
    return arrayValue.values?.map(getValue).toList() ?? [];
  }

  bool isNull(String name) {
    return !fields.containsKey(name) ||
        fields['name']!.nullValue == 'NULL_VALUE';
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
    return value.arrayValue!.values!.map(getValue).toList();
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

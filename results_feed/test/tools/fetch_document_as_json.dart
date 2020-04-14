// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This is a utility script to grab Firestore documents as JSON objects,
// used when preparing sample data for our test code.

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

const host = 'firestore.googleapis.com';
const project = 'dart-ci';
const urlBase =
    'https://$host/v1/projects/$project/databases/(default)/documents';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Run command with a list of Firestore document references as args.');
    exit(0);
  }
  final client = Client();
  final documents = {};

  for (final reference in args) {
    final result = await client.get(Uri.parse('$urlBase/$reference'));
    final json = jsonDecode(result.body);
    final fields = json['fields'];
    documents[reference] = {
      for (final field in fields.keys) field: toValue(fields[field])
    };
  }
  print(jsonEncode(documents));
}

dynamic toValue(dynamic valueJson) {
  final dynamic result = parseFirstNonNullValue(valueJson, {
    'stringValue': (String x) => x,
    'integerValue': (String x) => int.parse(x),
    'booleanValue': (bool x) => x,
    'arrayValue': (m) => m['values'].map(toValue).toList()
  });
  if (result == null) {
    print('Unknown value type $valueJson');
    exit(1);
  }
  return result;
}

dynamic parseFirstNonNullValue(
    Map<String, dynamic> value, Map<String, Function> types) {
  for (final type in types.keys) {
    if (value.containsKey(type)) return types[type](value[type]);
  }
}

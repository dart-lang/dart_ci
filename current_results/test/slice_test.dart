// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:current_results/src/generated/query.pbgrpc.dart' as query_api;
import 'package:current_results/src/result.dart';
import 'package:test/test.dart';
import 'package:current_results/src/slice.dart';

void main() {
  test('add results', () {
    final slice = Slice();
    slice.add([
      '{"name":"co19/Language/Classes/Abstract_Instance_Members/inherited_t07",'
          '"configuration":"dart2wasm-linux-d8","suite":"co19",'
          '"test_name":"Language/Classes/Abstract_Instance_Members/inherited_t07",'
          '"time_ms":971,"result":"Pass","expected":"Pass","matches":true,'
          '"bot_name":"dart-tests-jammy-31-f5hd",'
          '"commit_hash":"540922cdc9aa8f0cbd5497de99cba891bbe8138b",'
          '"commit_time":1742839022,"build_number":"3848",'
          '"builder_name":"dart2wasm-linux-d8","flaky":false,'
          '"previous_flaky":false,'
          '"previous_commit_hash":"2f657a46d4726e0c89cce684f3f9e8b9433ef35f",'
          '"previous_commit_time":1742834525,"previous_build_number":"3847",'
          '"previous_result":"Pass","changed":false}',
    ]);
    var expectedResult = Result(
      "co19/Language/Classes/Abstract_Instance_Members/inherited_t07",
      "dart2wasm-linux-d8",
      "540922cdc9aa8f0cbd5497de99cba891bbe8138b",
      "Pass",
      false,
      "Pass",
      Duration(milliseconds: 971),
      [],
    );
    expect(slice.size, 1);
    expect(
      slice
          .getSortedResults(
            '',
            ['dart2wasm-linux-d8'],
            {},
            null,
            needed: 100,
          )[0]
          .toMap(),
      expectedResult.toMap(),
    );
    expect(slice.results(query_api.GetResultsRequest()).results, [
      expectedResult.toQueryResult(),
    ]);
  });
}

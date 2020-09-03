///
//  Generated code. Do not modify.
//  source: query.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'google/protobuf/empty.pbjson.dart' as $0;

const GetResultsRequest$json = const {
  '1': 'GetResultsRequest',
  '2': const [
    const {'1': 'names', '3': 1, '4': 3, '5': 9, '10': 'names'},
    const {
      '1': 'configurations',
      '3': 2,
      '4': 3,
      '5': 9,
      '10': 'configurations'
    },
    const {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    const {'1': 'page_token', '3': 4, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

const GetResultsResponse$json = const {
  '1': 'GetResultsResponse',
  '2': const [
    const {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.current_results.Result',
      '10': 'results'
    },
    const {
      '1': 'next_page_token',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'nextPageToken'
    },
  ],
};

const Result$json = const {
  '1': 'Result',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'configuration', '3': 2, '4': 1, '5': 9, '10': 'configuration'},
    const {'1': 'result', '3': 3, '4': 1, '5': 9, '10': 'result'},
    const {'1': 'expected', '3': 4, '4': 1, '5': 9, '10': 'expected'},
    const {'1': 'flaky', '3': 5, '4': 1, '5': 8, '10': 'flaky'},
    const {'1': 'time_ms', '3': 6, '4': 1, '5': 5, '10': 'timeMs'},
  ],
};

const ListTestsRequest$json = const {
  '1': 'ListTestsRequest',
  '2': const [
    const {'1': 'prefix', '3': 1, '4': 1, '5': 9, '10': 'prefix'},
    const {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
  ],
};

const ListTestsResponse$json = const {
  '1': 'ListTestsResponse',
  '2': const [
    const {'1': 'names', '3': 1, '4': 3, '5': 9, '10': 'names'},
  ],
};

const ListConfigurationsRequest$json = const {
  '1': 'ListConfigurationsRequest',
  '2': const [
    const {'1': 'prefix', '3': 1, '4': 1, '5': 9, '10': 'prefix'},
  ],
};

const ListConfigurationsResponse$json = const {
  '1': 'ListConfigurationsResponse',
  '2': const [
    const {
      '1': 'configurations',
      '3': 1,
      '4': 3,
      '5': 9,
      '10': 'configurations'
    },
  ],
};

const FetchResponse$json = const {
  '1': 'FetchResponse',
  '2': const [
    const {
      '1': 'updates',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.current_results.ConfigurationUpdate',
      '10': 'updates'
    },
  ],
};

const ConfigurationUpdate$json = const {
  '1': 'ConfigurationUpdate',
  '2': const [
    const {'1': 'configuration', '3': 1, '4': 1, '5': 9, '10': 'configuration'},
  ],
};

const QueryServiceBase$json = const {
  '1': 'Query',
  '2': const [
    const {
      '1': 'GetResults',
      '2': '.current_results.GetResultsRequest',
      '3': '.current_results.GetResultsResponse'
    },
    const {
      '1': 'ListTests',
      '2': '.current_results.ListTestsRequest',
      '3': '.current_results.ListTestsResponse'
    },
    const {
      '1': 'ListTestPathCompletions',
      '2': '.current_results.ListTestsRequest',
      '3': '.current_results.ListTestsResponse'
    },
    const {
      '1': 'ListConfigurations',
      '2': '.current_results.ListConfigurationsRequest',
      '3': '.current_results.ListConfigurationsResponse'
    },
    const {
      '1': 'Fetch',
      '2': '.google.protobuf.Empty',
      '3': '.current_results.FetchResponse'
    },
  ],
};

const QueryServiceBase$messageJson = const {
  '.current_results.GetResultsRequest': GetResultsRequest$json,
  '.current_results.GetResultsResponse': GetResultsResponse$json,
  '.current_results.Result': Result$json,
  '.current_results.ListTestsRequest': ListTestsRequest$json,
  '.current_results.ListTestsResponse': ListTestsResponse$json,
  '.current_results.ListConfigurationsRequest': ListConfigurationsRequest$json,
  '.current_results.ListConfigurationsResponse':
      ListConfigurationsResponse$json,
  '.google.protobuf.Empty': $0.Empty$json,
  '.current_results.FetchResponse': FetchResponse$json,
  '.current_results.ConfigurationUpdate': ConfigurationUpdate$json,
};

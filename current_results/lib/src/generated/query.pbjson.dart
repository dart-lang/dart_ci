///
//  Generated code. Do not modify.
//  source: query.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = const {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');
@$core.Deprecated('Use getResultsRequestDescriptor instead')
const GetResultsRequest$json = const {
  '1': 'GetResultsRequest',
  '2': const [
    const {'1': 'filter', '3': 1, '4': 1, '5': 9, '10': 'filter'},
    const {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    const {'1': 'page_token', '3': 3, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `GetResultsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getResultsRequestDescriptor = $convert.base64Decode(
    'ChFHZXRSZXN1bHRzUmVxdWVzdBIWCgZmaWx0ZXIYASABKAlSBmZpbHRlchIbCglwYWdlX3NpemUYAiABKAVSCHBhZ2VTaXplEh0KCnBhZ2VfdG9rZW4YAyABKAlSCXBhZ2VUb2tlbg==');
@$core.Deprecated('Use getResultsResponseDescriptor instead')
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

/// Descriptor for `GetResultsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getResultsResponseDescriptor = $convert.base64Decode(
    'ChJHZXRSZXN1bHRzUmVzcG9uc2USMQoHcmVzdWx0cxgBIAMoCzIXLmN1cnJlbnRfcmVzdWx0cy5SZXN1bHRSB3Jlc3VsdHMSJgoPbmV4dF9wYWdlX3Rva2VuGAIgASgJUg1uZXh0UGFnZVRva2Vu');
@$core.Deprecated('Use resultDescriptor instead')
const Result$json = const {
  '1': 'Result',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'configuration', '3': 2, '4': 1, '5': 9, '10': 'configuration'},
    const {'1': 'result', '3': 3, '4': 1, '5': 9, '10': 'result'},
    const {'1': 'expected', '3': 4, '4': 1, '5': 9, '10': 'expected'},
    const {'1': 'flaky', '3': 5, '4': 1, '5': 8, '10': 'flaky'},
    const {'1': 'time_ms', '3': 6, '4': 1, '5': 5, '10': 'timeMs'},
    const {'1': 'experiments', '3': 7, '4': 3, '5': 9, '10': 'experiments'},
    const {'1': 'revision', '3': 8, '4': 1, '5': 9, '10': 'revision'},
  ],
};

/// Descriptor for `Result`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resultDescriptor = $convert.base64Decode(
    'CgZSZXN1bHQSEgoEbmFtZRgBIAEoCVIEbmFtZRIkCg1jb25maWd1cmF0aW9uGAIgASgJUg1jb25maWd1cmF0aW9uEhYKBnJlc3VsdBgDIAEoCVIGcmVzdWx0EhoKCGV4cGVjdGVkGAQgASgJUghleHBlY3RlZBIUCgVmbGFreRgFIAEoCFIFZmxha3kSFwoHdGltZV9tcxgGIAEoBVIGdGltZU1zEiAKC2V4cGVyaW1lbnRzGAcgAygJUgtleHBlcmltZW50cxIaCghyZXZpc2lvbhgIIAEoCVIIcmV2aXNpb24=');
@$core.Deprecated('Use listTestsRequestDescriptor instead')
const ListTestsRequest$json = const {
  '1': 'ListTestsRequest',
  '2': const [
    const {'1': 'prefix', '3': 1, '4': 1, '5': 9, '10': 'prefix'},
    const {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `ListTestsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTestsRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0VGVzdHNSZXF1ZXN0EhYKBnByZWZpeBgBIAEoCVIGcHJlZml4EhQKBWxpbWl0GAIgASgFUgVsaW1pdA==');
@$core.Deprecated('Use listTestsResponseDescriptor instead')
const ListTestsResponse$json = const {
  '1': 'ListTestsResponse',
  '2': const [
    const {'1': 'names', '3': 1, '4': 3, '5': 9, '10': 'names'},
  ],
};

/// Descriptor for `ListTestsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTestsResponseDescriptor = $convert
    .base64Decode('ChFMaXN0VGVzdHNSZXNwb25zZRIUCgVuYW1lcxgBIAMoCVIFbmFtZXM=');
@$core.Deprecated('Use listConfigurationsRequestDescriptor instead')
const ListConfigurationsRequest$json = const {
  '1': 'ListConfigurationsRequest',
  '2': const [
    const {'1': 'prefix', '3': 1, '4': 1, '5': 9, '10': 'prefix'},
  ],
};

/// Descriptor for `ListConfigurationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listConfigurationsRequestDescriptor =
    $convert.base64Decode(
        'ChlMaXN0Q29uZmlndXJhdGlvbnNSZXF1ZXN0EhYKBnByZWZpeBgBIAEoCVIGcHJlZml4');
@$core.Deprecated('Use listConfigurationsResponseDescriptor instead')
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

/// Descriptor for `ListConfigurationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listConfigurationsResponseDescriptor =
    $convert.base64Decode(
        'ChpMaXN0Q29uZmlndXJhdGlvbnNSZXNwb25zZRImCg5jb25maWd1cmF0aW9ucxgBIAMoCVIOY29uZmlndXJhdGlvbnM=');
@$core.Deprecated('Use fetchResponseDescriptor instead')
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

/// Descriptor for `FetchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchResponseDescriptor = $convert.base64Decode(
    'Cg1GZXRjaFJlc3BvbnNlEj4KB3VwZGF0ZXMYASADKAsyJC5jdXJyZW50X3Jlc3VsdHMuQ29uZmlndXJhdGlvblVwZGF0ZVIHdXBkYXRlcw==');
@$core.Deprecated('Use configurationUpdateDescriptor instead')
const ConfigurationUpdate$json = const {
  '1': 'ConfigurationUpdate',
  '2': const [
    const {'1': 'configuration', '3': 1, '4': 1, '5': 9, '10': 'configuration'},
  ],
};

/// Descriptor for `ConfigurationUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configurationUpdateDescriptor = $convert.base64Decode(
    'ChNDb25maWd1cmF0aW9uVXBkYXRlEiQKDWNvbmZpZ3VyYXRpb24YASABKAlSDWNvbmZpZ3VyYXRpb24=');

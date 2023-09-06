//
//  Generated code. Do not modify.
//  source: result.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use resultDescriptor instead')
const Result$json = {
  '1': 'Result',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'configuration', '3': 2, '4': 1, '5': 9, '10': 'configuration'},
    {'1': 'suite', '3': 100, '4': 1, '5': 9, '10': 'suite'},
    {'1': 'test_name', '3': 101, '4': 1, '5': 9, '10': 'testName'},
    {'1': 'time_ms', '3': 3, '4': 1, '5': 5, '10': 'timeMs'},
    {'1': 'result', '3': 4, '4': 1, '5': 9, '10': 'result'},
    {'1': 'expected', '3': 5, '4': 1, '5': 9, '10': 'expected'},
    {'1': 'matches', '3': 6, '4': 1, '5': 8, '10': 'matches'},
    {'1': 'bot_name', '3': 7, '4': 1, '5': 9, '10': 'botName'},
    {'1': 'commit_hash', '3': 8, '4': 1, '5': 9, '10': 'commitHash'},
    {'1': 'commit_time', '3': 102, '4': 1, '5': 5, '10': 'commitTime'},
    {'1': 'build_number', '3': 9, '4': 1, '5': 9, '10': 'buildNumber'},
    {'1': 'builder_name', '3': 10, '4': 1, '5': 9, '10': 'builderName'},
    {'1': 'flaky', '3': 11, '4': 1, '5': 8, '10': 'flaky'},
    {'1': 'previous_flaky', '3': 12, '4': 1, '5': 8, '10': 'previousFlaky'},
    {
      '1': 'previous_commit_hash',
      '3': 13,
      '4': 1,
      '5': 9,
      '10': 'previousCommitHash'
    },
    {
      '1': 'previous_commit_time',
      '3': 14,
      '4': 1,
      '5': 5,
      '10': 'previousCommitTime'
    },
    {
      '1': 'previous_build_number',
      '3': 15,
      '4': 1,
      '5': 9,
      '10': 'previousBuildNumber'
    },
    {'1': 'previous_result', '3': 16, '4': 1, '5': 9, '10': 'previousResult'},
    {'1': 'changed', '3': 17, '4': 1, '5': 8, '10': 'changed'},
    {'1': 'experiments', '3': 18, '4': 3, '5': 9, '10': 'experiments'},
  ],
};

/// Descriptor for `Result`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resultDescriptor = $convert.base64Decode(
    'CgZSZXN1bHQSEgoEbmFtZRgBIAEoCVIEbmFtZRIkCg1jb25maWd1cmF0aW9uGAIgASgJUg1jb2'
    '5maWd1cmF0aW9uEhQKBXN1aXRlGGQgASgJUgVzdWl0ZRIbCgl0ZXN0X25hbWUYZSABKAlSCHRl'
    'c3ROYW1lEhcKB3RpbWVfbXMYAyABKAVSBnRpbWVNcxIWCgZyZXN1bHQYBCABKAlSBnJlc3VsdB'
    'IaCghleHBlY3RlZBgFIAEoCVIIZXhwZWN0ZWQSGAoHbWF0Y2hlcxgGIAEoCFIHbWF0Y2hlcxIZ'
    'Cghib3RfbmFtZRgHIAEoCVIHYm90TmFtZRIfCgtjb21taXRfaGFzaBgIIAEoCVIKY29tbWl0SG'
    'FzaBIfCgtjb21taXRfdGltZRhmIAEoBVIKY29tbWl0VGltZRIhCgxidWlsZF9udW1iZXIYCSAB'
    'KAlSC2J1aWxkTnVtYmVyEiEKDGJ1aWxkZXJfbmFtZRgKIAEoCVILYnVpbGRlck5hbWUSFAoFZm'
    'xha3kYCyABKAhSBWZsYWt5EiUKDnByZXZpb3VzX2ZsYWt5GAwgASgIUg1wcmV2aW91c0ZsYWt5'
    'EjAKFHByZXZpb3VzX2NvbW1pdF9oYXNoGA0gASgJUhJwcmV2aW91c0NvbW1pdEhhc2gSMAoUcH'
    'JldmlvdXNfY29tbWl0X3RpbWUYDiABKAVSEnByZXZpb3VzQ29tbWl0VGltZRIyChVwcmV2aW91'
    'c19idWlsZF9udW1iZXIYDyABKAlSE3ByZXZpb3VzQnVpbGROdW1iZXISJwoPcHJldmlvdXNfcm'
    'VzdWx0GBAgASgJUg5wcmV2aW91c1Jlc3VsdBIYCgdjaGFuZ2VkGBEgASgIUgdjaGFuZ2VkEiAK'
    'C2V4cGVyaW1lbnRzGBIgAygJUgtleHBlcmltZW50cw==');

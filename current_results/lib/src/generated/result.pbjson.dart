///
//  Generated code. Do not modify.
//  source: result.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use resultDescriptor instead')
const Result$json = const {
  '1': 'Result',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'configuration', '3': 2, '4': 1, '5': 9, '10': 'configuration'},
    const {'1': 'suite', '3': 100, '4': 1, '5': 9, '10': 'suite'},
    const {'1': 'test_name', '3': 101, '4': 1, '5': 9, '10': 'testName'},
    const {'1': 'time_ms', '3': 3, '4': 1, '5': 5, '10': 'timeMs'},
    const {'1': 'result', '3': 4, '4': 1, '5': 9, '10': 'result'},
    const {'1': 'expected', '3': 5, '4': 1, '5': 9, '10': 'expected'},
    const {'1': 'matches', '3': 6, '4': 1, '5': 8, '10': 'matches'},
    const {'1': 'bot_name', '3': 7, '4': 1, '5': 9, '10': 'botName'},
    const {'1': 'commit_hash', '3': 8, '4': 1, '5': 9, '10': 'commitHash'},
    const {'1': 'commit_time', '3': 102, '4': 1, '5': 5, '10': 'commitTime'},
    const {'1': 'build_number', '3': 9, '4': 1, '5': 9, '10': 'buildNumber'},
    const {'1': 'builder_name', '3': 10, '4': 1, '5': 9, '10': 'builderName'},
    const {'1': 'flaky', '3': 11, '4': 1, '5': 8, '10': 'flaky'},
    const {
      '1': 'previous_flaky',
      '3': 12,
      '4': 1,
      '5': 8,
      '10': 'previousFlaky'
    },
    const {
      '1': 'previous_commit_hash',
      '3': 13,
      '4': 1,
      '5': 9,
      '10': 'previousCommitHash'
    },
    const {
      '1': 'previous_commit_time',
      '3': 14,
      '4': 1,
      '5': 5,
      '10': 'previousCommitTime'
    },
    const {
      '1': 'previous_build_number',
      '3': 15,
      '4': 1,
      '5': 9,
      '10': 'previousBuildNumber'
    },
    const {
      '1': 'previous_result',
      '3': 16,
      '4': 1,
      '5': 9,
      '10': 'previousResult'
    },
    const {'1': 'changed', '3': 17, '4': 1, '5': 8, '10': 'changed'},
    const {'1': 'experiments', '3': 18, '4': 3, '5': 9, '10': 'experiments'},
  ],
};

/// Descriptor for `Result`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resultDescriptor = $convert.base64Decode(
    'CgZSZXN1bHQSEgoEbmFtZRgBIAEoCVIEbmFtZRIkCg1jb25maWd1cmF0aW9uGAIgASgJUg1jb25maWd1cmF0aW9uEhQKBXN1aXRlGGQgASgJUgVzdWl0ZRIbCgl0ZXN0X25hbWUYZSABKAlSCHRlc3ROYW1lEhcKB3RpbWVfbXMYAyABKAVSBnRpbWVNcxIWCgZyZXN1bHQYBCABKAlSBnJlc3VsdBIaCghleHBlY3RlZBgFIAEoCVIIZXhwZWN0ZWQSGAoHbWF0Y2hlcxgGIAEoCFIHbWF0Y2hlcxIZCghib3RfbmFtZRgHIAEoCVIHYm90TmFtZRIfCgtjb21taXRfaGFzaBgIIAEoCVIKY29tbWl0SGFzaBIfCgtjb21taXRfdGltZRhmIAEoBVIKY29tbWl0VGltZRIhCgxidWlsZF9udW1iZXIYCSABKAlSC2J1aWxkTnVtYmVyEiEKDGJ1aWxkZXJfbmFtZRgKIAEoCVILYnVpbGRlck5hbWUSFAoFZmxha3kYCyABKAhSBWZsYWt5EiUKDnByZXZpb3VzX2ZsYWt5GAwgASgIUg1wcmV2aW91c0ZsYWt5EjAKFHByZXZpb3VzX2NvbW1pdF9oYXNoGA0gASgJUhJwcmV2aW91c0NvbW1pdEhhc2gSMAoUcHJldmlvdXNfY29tbWl0X3RpbWUYDiABKAVSEnByZXZpb3VzQ29tbWl0VGltZRIyChVwcmV2aW91c19idWlsZF9udW1iZXIYDyABKAlSE3ByZXZpb3VzQnVpbGROdW1iZXISJwoPcHJldmlvdXNfcmVzdWx0GBAgASgJUg5wcmV2aW91c1Jlc3VsdBIYCgdjaGFuZ2VkGBEgASgIUgdjaGFuZ2VkEiAKC2V4cGVyaW1lbnRzGBIgAygJUgtleHBlcmltZW50cw==');

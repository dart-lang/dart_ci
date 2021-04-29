// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:grpc/grpc.dart';

import 'package:current_results/src/generated/google/pubsub/v1/pubsub.pbgrpc.dart';

class BucketNotifications {
  SubscriberClient client;
  Subscription subscription;

  Future<void> initialize() async {
    final authenticator = await applicationDefaultCredentialsAuthenticator(
        ['https://www.googleapis.com/auth/pubsub']);
    final channel = ClientChannel('pubsub.googleapis.com',
        options:
            const ChannelOptions(credentials: ChannelCredentials.secure()));
    client = SubscriberClient(channel, options: authenticator.toCallOptions);
    subscription = await client.createSubscription(Subscription()
      ..topic = 'projects/dart-ci/topics/results-storage-objects');
  }

  Future<List<PubsubMessage>> getMessages() async {
    final response = await client.pull(PullRequest()
      ..subscription = subscription.name
      ..maxMessages = 1000);
    if (response.receivedMessages.isNotEmpty) {
      await client.acknowledge(AcknowledgeRequest()
        ..subscription = subscription.name
        ..ackIds
            .addAll(response.receivedMessages.map((message) => message.ackId)));
    }
    return [for (final message in response.receivedMessages) message.message];
  }
}

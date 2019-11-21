// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library contains bindings to a few helpful methods from node's `crypto`
/// module (https://nodejs.org/api/crypto.html).
@JS()
library github_label_notifier.node_crypto;

import 'package:js/js.dart';
import 'package:node_interop/node.dart';

final CryptoModule crypto = require('crypto');

@JS()
@anonymous
abstract class CryptoModule {
  /// Creates and returns an [Hmac] object that uses the given [algorithm] and
  /// [key].
  ///
  /// See [docs](https://nodejs.org/api/crypto.html#crypto_crypto_createhmac_algorithm_key_options).
  external Hmac createHmac(String algorithm, String key);

  /// Compares two [Buffer] objects using a constant time algorithm.
  ///
  /// See [docs](https://nodejs.org/api/crypto.html#crypto_crypto_timingsafeequal_a_b).
  external bool timingSafeEqual(Buffer a, Buffer b);
}

@JS()
@anonymous
abstract class Hmac {
  /// Append data to the content of this [Hmac].
  ///
  /// See [docs](https://nodejs.org/api/crypto.html#crypto_hmac_update_data_inputencoding).
  external Hmac update(String data);

  /// Compute the digest of the content accumulated via [update].
  ///
  /// See [docs](https://nodejs.org/api/crypto.html#crypto_hmac_digest_encoding).
  external String digest(String encoding);
}

// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// An HttpClient implementation that redirects all requests
// to be sent to a specified host and port instead.
// This can be used with HttpOverrides to override the default
// HttpClient from dart:io for testing purposes.

import 'package:http/http.dart';
import 'package:http/io_client.dart';

class RedirectingIOClient extends IOClient {
  final String _host;
  final int _port;

  RedirectingIOClient(this._host, this._port);
  @override
  Future<IOStreamedResponse> send(BaseRequest request) async {
    final oldRequest = request as Request;
    final modifiedUrl =
        oldRequest.url.replace(scheme: "http", host: _host, port: _port);
    final modifiedRequest = Request(oldRequest.method, modifiedUrl)
      ..headers.addAll(oldRequest.headers)
      ..body = oldRequest.body;
    return super.send(modifiedRequest);
  }
}

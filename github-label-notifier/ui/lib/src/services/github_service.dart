// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:github/github.dart';

/// Service for fetching various information from the GitHub through the API.
class GithubService {
  Future<List<String>> listLabels(String repository) => IssuesService(GitHub())
      .listLabels(RepositorySlug.full(repository))
      .map((label) => label.name)
      .toList();
}

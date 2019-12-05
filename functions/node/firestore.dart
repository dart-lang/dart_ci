// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// FirestoreService is implemented by FirestoreServiceImpl, for production
/// use, and by FirestoreServiceMock, for testing.
/// The implementation must be in a separate file, so that testing can
/// run on Dart native, not just on the nodeJS platform.
abstract class FirestoreService {
  Future<bool> hasPatchset(String review, String patchset);

  Future<Map<String, dynamic>> getCommit(String hash);

  Future<Map<String, dynamic>> getLastCommit();

  Future<void> addCommit(String id, Map<String, dynamic> data);

  Future<void> updateConfiguration(String configuration, String builder);

  Future<void> updateBuildInfo(String builder, int buildNumber, int index);

  Future<void> storeChange(
      Map<String, dynamic> change, int startIndex, int endIndex,
      {bool approved});

  Future<void> storeTryChange(
      Map<String, dynamic> change, int review, int patchset);

  Future<void> storeReview(String review, Map<String, dynamic> data);
  Future<void> storePatchset(
      String review, int patchset, Map<String, dynamic> data);

  Future<bool> reviewIsLanded(int review);

  Future<void> linkReviewToCommit(int review, int index);

  Future<void> linkCommentsToCommit(int review, int index);

  Future<List<Map<String, dynamic>>> tryApprovals(int review);
}

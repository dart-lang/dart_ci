// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// FirestoreService is implemented by FirestoreServiceImpl, for production
/// use, and by FirestoreServiceMock, for testing.
/// The implementation must be in a separate file, so that testing can
/// run on Dart native, not just on the nodeJS platform.
abstract class FirestoreService {
  int get documentsFetched;
  int get documentsWritten;

  Future<bool> isStaging();

  Future<bool> hasPatchset(String review, String patchset);

  Future<Map<String, dynamic>> getCommit(String hash);

  Future<Map<String, dynamic>> getCommitByIndex(int index);

  Future<Map<String, dynamic>> getLastCommit();

  Future<void> addCommit(String id, Map<String, dynamic> data);

  Future<void> updateConfiguration(String configuration, String builder);

  Future<void> updateBuildInfo(String builder, int buildNumber, int index);

  Future<String> findResult(
      Map<String, dynamic> change, int startIndex, int endIndex);

  Future<void> storeResult(Map<String, dynamic> result);

  Future<bool> updateResult(
      String result, String configuration, int startIndex, int endIndex,
      {bool failure});

  Future<List<Map<String, dynamic>>> findRevertedChanges(int index);

  Future<bool> storeTryChange(
      Map<String, dynamic> change, int review, int patchset);

  Future<void> updateActiveResult(
      Map<String, dynamic> activeResult, String configuration);

  Future<List<Map<String, dynamic>>> findActiveResults(
      Map<String, dynamic> change);

  Future<void> storeReview(String review, Map<String, dynamic> data);

  Future<void> storePatchset(
      String review, int patchset, Map<String, dynamic> data);

  Future<bool> reviewIsLanded(int review);

  Future<void> linkReviewToCommit(int review, int index);

  Future<void> linkCommentsToCommit(int review, int index);

  Future<List<Map<String, dynamic>>> tryApprovals(int review);

  Future<List<Map<String, dynamic>>> tryResults(
      int review, String configuration);

  Future<void> storeChunkStatus(String builder, int index, bool success);

  Future<void> storeBuildChunkCount(String builder, int index, int numChunks);

  Future<void> storeTryChunkStatus(String builder, int buildNumber,
      String buildbucketID, int review, int patchset, bool success);

  Future<void> storeTryBuildChunkCount(String builder, int buildNumber,
      String buildbucketID, int review, int patchset, int numChunks);
}

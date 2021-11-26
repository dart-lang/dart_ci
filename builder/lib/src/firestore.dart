// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:math' show max, min;

import 'package:builder/src/result.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:http/http.dart' as http;

import 'firestore_helpers.dart';

export 'firestore_helpers.dart';

class Commit {
  final DataWrapper wrapper;
  final String hash;
  Commit(this.hash, Document document) : wrapper = DataWrapper(document);
  Commit.fromJson(this.hash, Map<String, dynamic> data)
      : wrapper = DataWrapper.fields(taggedMap(data));
  int get index => wrapper.getInt('index');
  String get revertOf => wrapper.getString(fRevertOf);
  bool get isRevert => wrapper.fields.containsKey(fRevertOf);
  int get review => wrapper.getInt(fReview);

  Map<String, Object> toJson() => untagMap(wrapper.fields);
}

class FirestoreService {
  final String project;
  final FirestoreApi firestore;
  final http.Client client;
  int documentsFetched = 0;
  int documentsWritten = 0;

  final Stopwatch _stopwatch;

  FirestoreService(this.firestore, this.client,
      {this.project = 'dart-ci-staging'})
      : _stopwatch = Stopwatch()..start();

  void log(String string) {
    final time = _stopwatch.elapsed.toString();
    final lines = LineSplitter().convert(string);
    for (final line in lines) {
      print('$time   $line');
    }
  }

  Future<RunQueryResponse> query(
      {String from,
      Filter where,
      Order orderBy,
      int limit,
      String parent}) async {
    final query = StructuredQuery();
    if (from != null) {
      query.from = inCollection(from);
    }
    if (where != null) {
      query.where = where;
    }
    if (orderBy != null) {
      query.orderBy = [orderBy];
    }
    if (limit != null) {
      query.limit = limit;
    }
    final responses = await runQuery(query, parent: parent);
    // The REST API will respond with a single `null` result in case the query
    // did not match any documents.
    if (responses.length == 1 && responses.single.document == null) {
      responses.length = 0;
    }
    documentsFetched += responses.length;
    return responses;
  }

  Future<Document> getDocument(String path,
      {bool throwOnNotFound = true}) async {
    try {
      final document = await firestore.projects.databases.documents.get(path);
      documentsFetched++;
      return document;
    } on DetailedApiRequestError catch (e) {
      if (!throwOnNotFound && e.status == 404) {
        return null;
      } else {
        log("Failed to get document '$path'");
        rethrow;
      }
    }
  }

  String get databaseUri {
    return 'https://firestore.googleapis.com/v1/$database';
  }

  String get database => 'projects/$project/databases/(default)';
  String get documents => '$database/documents';

  Future<RunQueryResponse> runQuery(StructuredQuery query, {String parent}) {
    final request = RunQueryRequest()..structuredQuery = query;
    final parentPath = parent == null ? documents : '$documents/$parent';
    return firestore.projects.databases.documents.runQuery(request, parentPath);
  }

  Future<void> writeDocument(Document document) async {
    documentsWritten++;
    final request = CommitRequest()..writes = [Write()..update = document];
    await firestore.projects.databases.documents.commit(request, database);
  }

  Future<bool> isStaging() => Future.value(project == 'dart-ci-staging');

  Future<bool> hasPatchset(String review, String patchset) {
    return documentExists('$documents/reviews/$review/patchsets/$patchset');
  }

  Commit _commit(Document document) {
    document.fields['hash'] = taggedValue(document.name.split('/').last);
    return Commit(document.name.split('/').last, document);
  }

  Future<Commit> getCommit(String hash) async {
    final document =
        await getDocument('$documents/commits/$hash', throwOnNotFound: false);
    return document != null ? Commit(hash, document) : null;
  }

  Future<Commit> getCommitByIndex(int index) async {
    final response =
        await query(from: 'commits', where: fieldEquals('index', index));
    return _commit(response.first.document);
  }

  Future<Commit> getLastCommit() async {
    final lastCommit =
        await query(from: 'commits', orderBy: orderBy('index', false));
    return _commit(lastCommit.first.document);
  }

  Future<void> addCommit(String id, Map<String, dynamic> data) async {
    try {
      final document = Document()..fields = taggedMap(data);
      await firestore.projects.databases.documents
          .createDocument(document, documents, 'commits', documentId: id);
      documentsWritten++;
      log("Added commit $id -> ${data['index']}");
    } on DetailedApiRequestError catch (e) {
      if (e.status != 409) {
        rethrow;
      }
      // The document exists, we can ignore this error as the data is already
      // correct.
    }
  }

  Future<void> updateConfiguration(String configuration, String builder) async {
    documentsWritten++;
    final record = await getDocument('$documents/configurations/$configuration',
        throwOnNotFound: false);
    if (record == null) {
      final newRecord = Document()..fields = taggedMap({'builder': builder});
      await firestore.projects.databases.documents.createDocument(
          newRecord, documents, 'configurations',
          documentId: configuration);
      log('Configuration document $configuration -> $builder created');
    } else {
      final originalBuilder = DataWrapper(record).getString('builder');
      if (originalBuilder != builder) {
        record.fields['builder'].stringValue = builder;
        await updateFields(record, ['builder']);
        log('Configuration document changed: $configuration -> $builder '
            '(was $originalBuilder)');
      }
    }
  }

  /// Ensures that a build record for this build exists.
  ///
  /// Returns `true` if and only if there is no completed record
  /// for this build.
  Future<bool> updateBuildInfo(
      String builder, int buildNumber, int index) async {
    final record = await getDocument('$documents/builds/$builder:$index',
        throwOnNotFound: false);
    if (record == null) {
      final newRecord = Document()
        ..fields = taggedMap(
            {'builder': builder, 'build_number': buildNumber, 'index': index});
      await firestore.projects.databases.documents.createDocument(
          newRecord, documents, 'builds',
          documentId: '$builder:$index');
      documentsWritten++;
      return true;
    } else {
      final data = DataWrapper(record);
      final existingIndex = data.getInt('index');
      if (existingIndex != index) {
        throw ('Build $buildNumber of $builder had commit index '
            '$existingIndex, should be $index.');
      }
      return data.getBool('completed') != true;
    }
  }

  /// Ensures that a build record for this build exists.
  ///
  /// Returns `true` if and only if there is no completed record
  /// for this build.
  Future<void> recordTryBuild(
      String builder,
      int buildNumber,
      String buildbucketID,
      int review,
      int patchset,
      bool success,
      bool truncated) async {
    final newRecord = Document()
      ..fields = taggedMap({
        'builder': builder,
        'build_number': buildNumber,
        if (buildbucketID != null) 'buildbucket_id': buildbucketID,
        'review': review,
        'patchset': patchset,
        'success': success,
        'completed': true,
        if (truncated) 'truncated': true,
      });
    log('creating try-build record for '
        '$builder $buildNumber $review $patchset');
    await firestore.projects.databases.documents
        .createDocument(newRecord, documents, 'try_builds');
    documentsWritten++;
    return true;
  }

  Future<String> findResult(
      Map<String, dynamic> change, int startIndex, int endIndex) async {
    final name = change['name'] as String;
    final result = change['result'] as String;
    final previousResult = change['previous_result'] as String;
    final expected = change['expected'] as String;
    final snapshot = await query(
        from: 'results',
        orderBy: orderBy('blamelist_end_index', false),
        where: compositeFilter([
          fieldEquals('name', name),
          fieldEquals('result', result),
          fieldEquals('previous_result', previousResult),
          fieldEquals('expected', expected)
        ]),
        limit: 5);

    bool blamelistIncludesChange(RunQueryResponseElement response) {
      final document = response.document;
      if (document == null) return false;
      final groupStart =
          int.parse(document.fields['blamelist_start_index'].integerValue);
      final groupEnd =
          int.parse(document.fields['blamelist_end_index'].integerValue);
      return startIndex <= groupEnd && endIndex >= groupStart;
    }

    return snapshot
        .firstWhere(blamelistIncludesChange, orElse: () => null)
        ?.document
        ?.name;
  }

  Future<Document> storeResult(Map<String, dynamic> result) async {
    final document = Document()..fields = taggedMap(result);
    final createdDocument = await firestore.projects.databases.documents
        .createDocument(document, documents, 'results');
    log('created document ${createdDocument.name}');
    documentsWritten++;
    return createdDocument;
  }

  Future<bool> updateResult(
      String result, String configuration, int startIndex, int endIndex,
      {bool failure}) async {
    bool approved;
    await retryCommit(() async {
      final document = await getDocument(result);
      final data = DataWrapper(document);
      // Allow missing 'approved' field during transition period.
      approved = data.getBool('approved') ?? false;
      // Add the new configuration and narrow the blamelist.
      final newStart = max(startIndex, data.getInt('blamelist_start_index'));
      final newEnd = min(endIndex, data.getInt('blamelist_end_index'));
      // TODO(karlklose): check for pinned, and remove the pin if the new range
      // doesn't include it?
      final updates = [
        'blamelist_start_index',
        'blamelist_end_index',
        if (failure) 'active'
      ];
      document.fields['blamelist_start_index'] = taggedValue(newStart);
      document.fields['blamelist_end_index'] = taggedValue(newEnd);
      if (failure) {
        document.fields['active'] = taggedValue(true);
      }
      final addConfiguration = ArrayValue()
        ..values = [taggedValue(configuration)];
      final write = Write()
        ..currentDocument = (Precondition()..updateTime = document.updateTime)
        ..update = document
        ..updateMask = (DocumentMask()..fieldPaths = updates)
        ..updateTransforms = [
          FieldTransform()
            ..fieldPath = 'configurations'
            ..appendMissingElements = addConfiguration,
          if (failure)
            FieldTransform()
              ..fieldPath = 'active_configurations'
              ..appendMissingElements = addConfiguration
        ];
      documentsWritten++;
      return write;
    });
    return approved;
  }

  Future retryCommit(Future<Write> Function() request) async {
    while (true) {
      final write = await request();
      try {
        // Use commit instead of write to check for the precondition on the
        // document
        final request = CommitRequest()..writes = [write];
        documentsWritten++;
        await firestore.projects.databases.documents.commit(request, database);
        return;
      } catch (e) {
        log('Error while writing data: $e, retrying...');
        sleep(Duration(milliseconds: 100));
      }
    }
  }

  /// Returns all results which are either pinned to or have a range that is
  /// this single index. // TODO: rename this function
  Future<List<Map<String, Value>>> findRevertedChanges(int index) async {
    final pinnedResults =
        await query(from: 'results', where: fieldEquals('pinned_index', index));
    final results =
        pinnedResults.map((response) => response.document.fields).toList();
    final unpinnedResults = await query(
        from: 'results', where: fieldEquals('blamelist_end_index', index));
    for (final unpinnedResult in unpinnedResults) {
      final data = DataWrapper(unpinnedResult.document);
      if (data.getInt('blamelist_start_index') == index &&
          data.isNull('pinned_index')) {
        results.add(unpinnedResult.document.fields);
      }
    }
    return results;
  }

  Future<bool> storeTryChange(
      Map<String, dynamic> change, int review, int patchset) async {
    final name = change['name'] as String;
    final result = change['result'] as String;
    final expected = change['expected'] as String;
    final previousResult = change['previous_result'] as String;
    final configuration = change['configuration'] as String;

    // Find an existing result record for this test on this patchset.
    final responses = await query(
        from: 'try_results',
        where: compositeFilter([
          fieldEquals('review', review),
          fieldEquals('patchset', patchset),
          fieldEquals('name', name),
          fieldEquals('result', result),
          fieldEquals('previous_result', previousResult),
          fieldEquals('expected', expected)
        ]),
        limit: 1);
    // TODO(karlklose): We could run only this query, and then see if the
    //                  patchset is equal or not. We don't need the separate
    //                  query with equal patchset.
    //                  The test for previous.isNotEmpty below can be replaced
    //                  with responses.patchset != patchset.  We need to hit
    //                  the createDocument both if there was a previous response,
    //                  or there is no response at all.
    if (responses.isEmpty) {
      // Is the previous result for this test on this review approved?
      final previous = await query(
          from: 'try_results',
          where: compositeFilter([
            fieldEquals('review', review),
            fieldEquals('name', name),
            fieldEquals('result', result),
            fieldEquals('previous_result', previousResult),
            fieldEquals('expected', expected),
          ]),
          orderBy: orderBy('patchset', false),
          limit: 1);
      final approved = previous.isNotEmpty &&
          DataWrapper(previous.first.document).getBool('approved') == true;

      final document = Document()
        ..fields = taggedMap({
          'name': name,
          'result': result,
          'previous_result': previousResult,
          'expected': expected,
          'review': review,
          'patchset': patchset,
          'configurations': <String>[configuration],
          'approved': approved
        });
      await firestore.projects.databases.documents.createDocument(
          document,
          'projects/dart-ci-staging/databases/(default)/documents',
          'try_results',
          mask_fieldPaths: [
            'name',
            'result',
            'previous_result',
            'expected',
            'review',
            'patchset',
            'configurations',
            'approved'
          ]);
      documentsWritten++;
      return approved;
    } else {
      final document = responses.first.document;
      // Update the TryResult for this test, adding this configuration.
      final values = ArrayValue()..values = [taggedValue(configuration)];
      final addConfiguration = FieldTransform()
        ..fieldPath = 'configurations'
        ..appendMissingElements = values;
      await _executeWrite([
        Write()
          ..update = document
          ..updateTransforms = [addConfiguration]
      ]);
      return DataWrapper(document).getBool('approved') == true;
    }
  }

  Future<void> approveResult(Document document) async {
    document.fields['approved'] = taggedValue(true);
    await _executeWrite([
      Write()
        ..update = document
        ..updateMask = (DocumentMask()..fieldPaths = ['approved'])
    ]);
  }

  /// Removes [configuration] from the active configurations and marks the
  /// active result inactive when we remove the last active config.
  Future<void> removeActiveConfiguration(
      Document activeResult, String configuration) async {
    final data = DataWrapper(activeResult);
    final configurations = data.getList('active_configurations');
    assert(configurations.contains(configuration));
    await removeArrayEntry(
        activeResult, 'active_configurations', taggedValue(configuration));
    activeResult = await getDocument(activeResult.name);
    if (DataWrapper(activeResult).getList('active_configurations').isEmpty) {
      activeResult.fields.remove('active_configurations');
      activeResult.fields.remove('active');
      final write = Write()
        ..update = activeResult
        ..updateMask =
            (DocumentMask()..fieldPaths = ['active', 'active_configurations']);
      await _executeWrite([write]);
    }
  }

  Future<void> removeArrayEntry(
      Document document, String fieldName, Value entry) async {
    await _executeWrite([
      Write()
        ..transform = (DocumentTransform()
          ..document = document.name
          ..fieldTransforms = [
            FieldTransform()
              ..fieldPath = fieldName
              ..removeAllFromArray = (ArrayValue()..values = [entry])
          ])
    ]);
  }

  Future<List<Document>> findActiveResults(
      String name, String configuration) async {
    final results = await query(
        from: 'results',
        where: compositeFilter([
          arrayContains('active_configurations', configuration),
          fieldEquals('active', true),
          fieldEquals('name', name)
        ]));
    if (results.length > 1) {
      log([
        'Multiple active results for the same configuration and test',
        ...results
      ].join('\n'));
    }
    return results
        .map((RunQueryResponseElement result) => result.document)
        .toList();
  }

  Future<bool> hasReview(String review) async {
    return documentExists('$documents/reviews/$review');
  }

  Future<void> storeReview(String review, Map<String, Value> data) async {
    final document = Document()..fields = data;
    documentsWritten++;
    await firestore.projects.databases.documents
        .createDocument(document, documents, 'reviews', documentId: review);
  }

  Future<void> deleteDocument(String name) async {
    return _executeWrite([Write()..delete = name]);
  }

  Future<bool> documentExists(String name) async {
    return (await getDocument(name, throwOnNotFound: false) != null);
  }

  Future _executeWrite(List<Write> writes) async {
    const debug = false;
    final request = BatchWriteRequest()..writes = writes;
    if (debug) {
      log('WriteRequest: ${request.toJson()}');
    }
    documentsWritten += writes.length;
    return firestore.projects.databases.documents.batchWrite(request, database);
  }

  Future<void> updateFields(Document document, List<String> fields) async {
    await _executeWrite([
      Write()
        ..update = document
        ..updateMask = (DocumentMask()..fieldPaths = fields)
    ]);
  }

  Future<void> storePatchset(String review, int patchset, String kind,
      String description, int patchsetGroup, int number) async {
    final document = Document()
      ..name = '$documents/reviews/$review/patchsets/$patchset'
      ..fields = taggedMap({
        'kind': kind,
        'description': description,
        'patchset_group': patchsetGroup,
        'number': number
      });
    await _executeWrite([Write()..update = document]);
    log('Stored patchset: $documents/reviews/$review/patchsets/$patchset\n'
        '${untagMap(document.fields)}');
    documentsWritten++;
  }

  /// Returns true if a review record in the database has a landed_index field,
  /// or if there is no record for the review in the database.  Reviews with no
  /// test failures have no record, and don't need to be linked when landing.
  Future<bool> reviewIsLanded(int review) async {
    final document =
        await getDocument('$documents/reviews/$review', throwOnNotFound: false);
    if (document == null) {
      return true;
    }
    return document.fields.containsKey('landed_index');
  }

  Future<void> linkReviewToCommit(int review, int index) async {
    final document = await getDocument('$documents/reviews/$review');
    document.fields['landed_index'] = taggedValue(index);
    await updateFields(document, ['landed_index']);
  }

  Future<void> linkCommentsToCommit(int review, int index) async {
    final comments =
        await query(from: 'comments', where: fieldEquals('review', review));
    if (comments.isEmpty) return;
    final writes = <Write>[];
    for (final comment in comments) {
      final document = comment.document;
      document.fields['blamelist_start_index'] = taggedValue(index);
      document.fields['blamelist_end_index'] = taggedValue(index);
      writes.add(Write()
        ..update = document
        ..updateMask = (DocumentMask()
          ..fieldPaths = ['blamelist_start_index', 'blamelist_end_index']));
    }
    await _executeWrite(writes);
  }

  Future<List<Map<String, Value>>> tryApprovals(int review) async {
    final patchsets = await query(
        from: 'patchsets',
        parent: 'reviews/$review',
        orderBy: orderBy('number', false),
        limit: 1);
    if (patchsets.isEmpty) {
      return [];
    }
    final lastPatchsetGroup =
        DataWrapper(patchsets.first.document).getInt('patchset_group');
    final approvals = await query(
        from: 'try_results',
        where: compositeFilter([
          fieldEquals('approved', true),
          fieldEquals('review', review),
          fieldGreaterThanOrEqual('patchset', lastPatchsetGroup)
        ]));

    return approvals.map((response) => response.document.fields).toList();
  }

  Future<List<Map<String, Value>>> tryResults(
      int review, String configuration) async {
    final patchsets = await query(
        from: 'patchsets',
        parent: 'reviews/$review',
        orderBy: orderBy('number', false),
        limit: 1);
    if (patchsets.isEmpty) {
      return [];
    }
    final lastPatchsetGroup =
        DataWrapper(patchsets.first.document).getInt('patchset_group');
    final approvals = await query(
        from: 'try_results',
        where: compositeFilter([
          fieldEquals('review', review),
          arrayContains('configurations', configuration),
          fieldGreaterThanOrEqual('patchset', lastPatchsetGroup)
        ]));
    return approvals.map((r) => r.document.fields).toList();
  }

  Future<void> completeBuilderRecord(
      String builder, int index, bool success) async {
    final path = '$documents/builds/$builder:$index';
    final document = await getDocument(path);
    await _completeBuilderRecord(document, success);
  }

  Future<void> _completeBuilderRecord(Document document, bool success) async {
    await retryCommit(() async {
      final data = DataWrapper(document);
      // TODO: Legacy support, remove if not needed anymore.
      document.fields['processed_chunks'] = taggedValue(1);
      document.fields['num_chunks'] = taggedValue(1);
      document.fields['success'] =
          taggedValue((data.getBool('success') ?? true) && success);
      document.fields['completed'] = taggedValue(true);

      final write = Write()
        ..update = document
        ..updateMask = (DocumentMask()
          ..fieldPaths = [
            'processed_chunks',
            'num_chunks',
            'success',
            'completed',
          ])
        ..currentDocument = (Precondition()..updateTime = document.updateTime);
      return write;
    });
  }
}

import 'package:firebase/src/firestore.dart';

import '../model/comment.dart';
import '../model/commit.dart';
import 'firestore_service.dart';

class TryDataService {
  final FirestoreService _firestoreService;

  TryDataService(this._firestoreService);

  Future logIn() => _firestoreService.logIn();

  bool get isLoggedIn => _firestoreService.isLoggedIn;

  Map<String, String> _builders;

  Future<Map<String, String>> builders() async {
    return _builders ??= await _getBuilders();
  }

  Future<List<Change>> changes(ReviewInfo reviewInfo, int patchset) async {
    final patchsets = reviewInfo.patchsets;
    if (patchsets.length < patchset) return [];
    // Patchset numbers start at 1, not 0.
    final patchsetGroup = patchsets[patchset - 1].patchsetGroup;
    // Workaround while [ ... await foo() ] does not work in dartdevc.
    // Issue https://github.com/dart-lang/sdk/issues/38896
    final docs = [];
    for (var identicalPatchset in patchsets) {
      if (identicalPatchset.patchsetGroup == patchsetGroup) {
        docs.addAll(await _firestoreService.fetchTryChanges(
            reviewInfo.review, identicalPatchset.number));
      }
    }
    return [for (final data in docs) Change.fromDocument(data)];
  }

  Future<ReviewInfo> fetchReviewInfo(int review) async {
    final doc = await _firestoreService.fetchReviewInfo(review);
    if (doc.exists) {
      return ReviewInfo.fromDocument(doc)
        ..setPatchsets(await _firestoreService.fetchPatchsetInfo(review))
        ..setBuilds(await _firestoreService.fetchTryBuilds(review));
    } else {
      return ReviewInfo(review, 'No results received yet for CL $review', [])
        ..setBuilds([]);
    }
  }

  Future<List<Comment>> comments(int review) async {
    final docs = await _firestoreService.fetchCommentsForReview(review);
    return [for (final doc in docs) Comment.fromDocument(doc)];
  }

  Future<Comment> saveApproval(bool approve, String comment, String baseComment,
      Iterable<String> resultIds, int review) async {
    await _firestoreService.saveApprovals(
        approve: approve, tryResultIds: resultIds);
    return Comment.fromDocument(await _firestoreService.saveComment(
        approve, comment, baseComment,
        tryResultIds: resultIds, review: review));
  }

  Future<Map<String, String>> _getBuilders() async {
    await _firestoreService.getFirebaseClient();
    final builderDocs = await _firestoreService.fetchBuilders();
    return {for (var doc in builderDocs) doc.id: '${doc.get('builder')}-try'};
  }
}

class ReviewInfo {
  int review;
  String title;
  List<Patchset> patchsets;
  List<TryBuild> builds;

  ReviewInfo(this.review, this.title, this.patchsets);

  ReviewInfo.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    review = int.parse(doc.id);
    title = data['subject'];
  }

  void setPatchsets(List<DocumentSnapshot> docs) {
    patchsets = [for (final doc in docs) Patchset.fromDocument(doc)];
  }

  void setBuilds(List<DocumentSnapshot> docs) {
    builds = [for (final doc in docs) TryBuild.fromDocument(doc)];
  }
}

class Patchset implements Comparable<Patchset> {
  int number;
  int patchsetGroup;
  String description;
  String kind;

  Patchset.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    number = data['number'];
    patchsetGroup = data['patchset_group'];
    description = data['description'];
    kind = data['kind'];
  }

  @override
  int compareTo(Patchset other) => number.compareTo(other.number);

  @override
  String toString() => 'Patchset($number, $patchsetGroup, $description, $kind)';
}

class TryBuild {
  String builder;
  int buildNumber;
  String buildbucketID;
  bool completed;
  bool success;
  int review;
  int patchset;

  TryBuild.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    builder = data['builder'];
    buildNumber = data['build_number'];
    buildbucketID = data['buildbucket_id'];
    completed = data['completed'];
    success = data['success'];
    review = data['review'];
    patchset = data['patchset'];
  }
}

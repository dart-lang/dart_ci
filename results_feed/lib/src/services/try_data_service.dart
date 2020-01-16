import 'package:firebase/src/firestore.dart';

import '../model/comment.dart';
import '../model/commit.dart';
import 'firestore_service.dart';

class TryDataService {
  final FirestoreService _firestoreService;

  TryDataService(this._firestoreService);

  Future logIn() => _firestoreService.logIn();

  bool get isLoggedIn => _firestoreService.isLoggedIn;

  Future<List<Change>> changes(ReviewInfo reviewInfo, int patchset) async {
    final patchsets = reviewInfo.patchsets;
    if (patchsets.length < patchset) return [];
    // Patchset numbers start at 1, not 0.
    int patchsetGroup = patchsets[patchset - 1].patchsetGroup;
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
        ..setPatchsets(await _firestoreService.fetchPatchsetInfo(review));
    } else {
      return ReviewInfo(review, "No results received yet for CL $review", []);
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
}

class ReviewInfo {
  int review;
  String title;
  List<Patchset> patchsets;

  ReviewInfo(this.review, this.title, this.patchsets);

  ReviewInfo.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    review = int.parse(doc.id);
    title = data['subject'];
  }

  void setPatchsets(List<DocumentSnapshot> docs) {
    patchsets = docs.map((doc) => Patchset.fromDocument(doc)).toList();
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

  int compareTo(Patchset other) => number.compareTo(other.number);

  String toString() => "Patchset($number, $patchsetGroup, $description, $kind)";
}

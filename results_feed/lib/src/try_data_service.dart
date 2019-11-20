import 'package:angular_components/angular_components.dart';
import 'package:firebase/src/firestore.dart';

import 'commit.dart';
import 'firestore_service.dart';

class TryDataService {
  final FirestoreService _firestoreService;
  TryDataService(this._firestoreService);

  Future<List<Change>> changes(ReviewInfo changeInfo, int patch) async {
    final patchsets = changeInfo.patchsets;
    if (patchsets.length < patch) return [];
    // Patchset numbers start at 1, not 0.
    int patchsetGroup = patchsets[patch - 1].patchsetGroup;
    // Workaround while [ ... await foo() ] does not work in dartdevc.
    // Issue https://github.com/dart-lang/sdk/issues/38896
    final docs = [];
    for (var patchset in patchsets) {
      if (patchset.patchsetGroup == patchsetGroup) {
        docs.addAll(await _firestoreService.fetchTryChanges(
            changeInfo.review, patchset.number));
      }
    }
    return [for (final data in docs) Change.fromDocument(data)];
  }

  Future<ReviewInfo> reviewInfo(int review) async {
    final doc = await _firestoreService.fetchReviewInfo(review);
    if (doc.exists) {
      return ReviewInfo.fromDocument(doc)
        ..setPatchsets(await _firestoreService.fetchPatchsetInfo(review));
    } else {
      return ReviewInfo(review, "No results received yet for CL $review", []);
    }
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

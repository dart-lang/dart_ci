import 'package:angular_components/angular_components.dart';
import 'package:firebase/src/firestore.dart';

import 'commit.dart';
import 'firestore_service.dart';

class TryDataService {
  final FirestoreService _firestoreService;
  TryDataService(this._firestoreService);

  Future<List<Change>> changes(ChangeInfo changeInfo, int patch) async {
    final patchsets = changeInfo.patchsets;
    // Patchset numbers start at 1, not 0.
    int patchsetGroup = patchsets[patch - 1].patchsetGroup;
    // Workaround while [ ... await foo() ] does not work in dartdevc.
    // Issue https://github.com/dart-lang/sdk/issues/38896
    final docs = [];
    for (var patchset in patchsets) {
      if (patchset.patchsetGroup == patchsetGroup) {
        docs.addAll(await _firestoreService.fetchTryChanges(
            changeInfo.change, patchset.number));
      }
    }
    return [for (final data in docs) Change.fromDocument(data)];
  }

  Future<ChangeInfo> changeInfo(int change) async {
    return ChangeInfo.fromDocument(
        await _firestoreService.fetchChangeInfo(change))
      ..setPatchsets(await _firestoreService.fetchChangePatchsetInfo(change));
  }
}

class ChangeInfo {
  int change;
  String authorName;
  String authorEmail;
  DateTime created;
  String message;
  String title;
  List<Patchset> patchsets;

  ChangeInfo.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    change = data['change'];
    authorName = data['owner_name'];
    authorEmail = data['owner_email'];
    created = data['created'];
    title = data['subject'];
    message = title;
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
    patchsetGroup =
        data['patchsetGroup']; // Todo: change database field to patchset_group.
    description = data['description'];
    kind = data['kind'];
  }

  int compareTo(Patchset other) => number.compareTo(other.number);

  String toString() => "Patchset($number, $patchsetGroup, $description, $kind)";
}

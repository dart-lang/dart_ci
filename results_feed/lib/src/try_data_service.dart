import 'package:angular_components/angular_components.dart';
import 'package:firebase/src/firestore.dart';

import 'commit.dart';
import 'firestore_service.dart';

class TryDataService {
  final FirestoreService _firestoreService;

  TryDataService(this._firestoreService);

  Future<List<Change>> changes(int change, int patch) async {
    final docs = _firestoreService.fetchTryChanges(change, patch);
    return [for (final data in await docs) Change.fromDocument(data)];
  }

  Future<ChangeInfo> changeInfo(int change) async {
    return ChangeInfo.fromDocument(
        await _firestoreService.fetchChangeInfo(change));
  }
}

class ChangeInfo {
  int change;
  String authorName;
  String authorEmail;
  DateTime created;
  String message;
  String title;

  ChangeInfo.fromDocument(DocumentSnapshot doc) {
    final data = doc.data();
    change = data['change'];
    authorName = data['owner_name'];
    authorEmail = data['owner_email'];
    created = data['created'];
    title = data['subject'];
    message = title;
  }
}

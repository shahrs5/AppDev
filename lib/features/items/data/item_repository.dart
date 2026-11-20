import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/item.dart';

class AlreadyClaimedException implements Exception {
  @override
  String toString() => 'This item was already marked as claimed';
}

class ItemRepository {
  ItemRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _items => _db.collection('items');

  Stream<List<Item>> watchAll() {
    return _items
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Item.fromDoc).toList());
  }

  Stream<Item?> watchOne(String id) {
    return _items.doc(id).snapshots().map((doc) => doc.exists ? Item.fromDoc(doc) : null);
  }

  Future<void> add(Item item) {
    return _items.add({
      ...item.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markClaimed(String id) async {
    final result = await _db.runTransaction((tx) async {
      final ref = _items.doc(id);
      final snap = await tx.get(ref);
      if (!snap.exists) return 'missing';
      if (snap.data()!['status'] == 'Claimed') return 'claimed';
      tx.update(ref, {
        'status': 'Claimed',
        'claimedAt': FieldValue.serverTimestamp(),
      });
      return 'ok';
    });
    if (result == 'missing') throw Exception('Item no longer exists');
    if (result == 'claimed') throw AlreadyClaimedException();
  }

  Future<void> remove(String id) {
    return _items.doc(id).delete();
  }
}

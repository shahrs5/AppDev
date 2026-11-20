import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

const seedItems = [
  ['Black Backpack', 'Bag', 'MCC Cafeteria', 'Found', 'Black backpack with a laptop sleeve, left on a chair', 'Shaheer'],
  ['Blue Water Bottle', 'Accessory', 'Library, 2nd Floor', 'Found', 'Steel bottle with a few stickers on it', 'Ahmed'],
  ['Student ID Card — M. Ali', 'ID Card', 'Main Gate', 'Found', 'Handed to the guard at the main gate', 'Sara'],
  ['Laptop Charger (Dell)', 'Electronics', 'Room 301', 'Lost', 'Dell 65W charger, forgot it after class', 'Hamza'],
  ['Umbrella (Black)', 'Accessory', 'Admin Block', 'Lost', 'Plain black folding umbrella', 'Ayesha'],
  ['Bunch of Keys', 'Keys', 'Parking Lot', 'Found', 'Three keys on a red keychain', 'Bilal'],
  ['Calculus Textbook', 'Book', 'Student Lounge', 'Lost', 'Thomas Calculus, name written inside the cover', 'Zainab'],
  ['Grey Jacket', 'Clothing', 'Auditorium', 'Found', 'Grey zip-up hoodie, size M', 'Usman'],
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final items = FirebaseFirestore.instance.collection('items');
  final existing = await items.limit(1).get();
  var message = 'items already has data, nothing added';

  if (existing.docs.isEmpty) {
    final batch = FirebaseFirestore.instance.batch();
    for (final s in seedItems) {
      batch.set(items.doc(), {
        'title': s[0],
        'category': s[1],
        'location': s[2],
        'status': s[3],
        'description': s[4],
        'postedBy': s[5],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    message = 'Added ${seedItems.length} items';
  }

  runApp(MaterialApp(home: Scaffold(body: Center(child: Text(message)))));
}

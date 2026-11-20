import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  const Item({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.status,
    required this.description,
    required this.postedBy,
  });

  final String id;
  final String title;
  final String category;
  final String location;
  final String status;
  final String description;
  final String postedBy;

  static const statuses = ['Lost', 'Found', 'Claimed'];

  factory Item.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Item(
      id: doc.id,
      title: data['title'] as String,
      category: data['category'] as String,
      location: data['location'] as String,
      status: data['status'] as String,
      description: data['description'] as String? ?? '',
      postedBy: data['postedBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'location': location,
      'status': status,
      'description': description,
      'postedBy': postedBy,
    };
  }
}

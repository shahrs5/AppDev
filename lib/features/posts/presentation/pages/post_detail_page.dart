import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post #${post.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('User ${post.userId}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Text(post.body, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

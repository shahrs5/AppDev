import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post_model.dart';

class PostRemoteDataSource {
  PostRemoteDataSource({http.Client? client}) : client = client ?? http.Client();

  final http.Client client;

  static const url = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<PostModel>> getPosts() async {
    final res = await client.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('Server returned ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as List;
    return data.map((e) => PostModel.fromJson(e)).toList();
  }
}

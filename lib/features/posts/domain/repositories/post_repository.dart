import '../entities/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts();
}

class PostFailure implements Exception {
  const PostFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

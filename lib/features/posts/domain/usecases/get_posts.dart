import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPosts {
  const GetPosts(this.repository);

  final PostRepository repository;

  Future<List<Post>> call() => repository.getPosts();
}

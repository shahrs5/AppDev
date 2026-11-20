import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this.remote);

  final PostRemoteDataSource remote;

  @override
  Future<List<Post>> getPosts() async {
    try {
      return await remote.getPosts();
    } on FormatException {
      throw const PostFailure('Got bad data from the server');
    } catch (e) {
      throw const PostFailure('Could not load posts. Check your internet and try again.');
    }
  }
}

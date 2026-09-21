import 'posts_api.dart';
import 'post.dart';

class UserViewModel {
  UserViewModel(this._api);

  final PostsApi _api;

  String searchQuery = '';
  Set<int> favoritePosts = {};
  late Future<ApiResponse<List<UserModel>>> postsFuture = _api.fetchUsers();

  // used by retry button and pull to refresh
  void loadUsers() {
    postsFuture = _api.fetchUsers();
  }

  void toggleFavorite(UserModel post) {
    favoritePosts.contains(post.id) ? favoritePosts.remove(post.id) : favoritePosts.add(post.id);
  }
}

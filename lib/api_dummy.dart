import 'package:flutter/material.dart';

import 'posts_api.dart';
import 'post.dart';
import 'userDetails.dart';
import 'user_viewmodel.dart';
import 'initials_avatar.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key, this.api});

  final PostsApi? api;
  static const List<Tab> tabs = <Tab>[
    Tab(text: 'Zeroth'),
    Tab(text: 'First'),
    Tab(text: 'Second'),
  ];

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late final PostsApi _api = widget.api ?? PostsApi();
  late final UserViewModel _vm = UserViewModel(_api);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const Text('Student Directory'),
              SearchBar(
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                leading: const Icon(Icons.search),
                onChanged: (value) {
                  setState(() {
                    _vm.searchQuery = value;
                  });
                },
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'All Users'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),

        body: FutureBuilder<ApiResponse<List<UserModel>>>(
          future: _vm.postsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final posts = snapshot.data!.data;
              final filteredPosts = posts.where((n) => n.name.toLowerCase().contains(_vm.searchQuery.toLowerCase())).toList();
              final favPosts = filteredPosts.where((n) => _vm.favoritePosts.contains(n.id)).toList();
              return TabBarView(
                children: [
                  _buildUserList(filteredPosts),
                  _buildUserList(favPosts),
                ],
              );
            } else if (snapshot.hasError && snapshot.connectionState != ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${snapshot.error}'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _vm.loadUsers();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // By default, show a loading spinner.
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {

  if (users.isEmpty) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off),
          Text('No users found'),
        ],
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () async {
      setState(() {
        _vm.loadUsers();
      });
      try {
        await _vm.postsFuture;
      } catch (e) {
        // error is shown by the FutureBuilder
      }
    },
    child: ListView.builder(
    itemCount: users.length,
    itemBuilder: (context, index) {
      final post = users[index];
      return Card(child: ListTile(
        leading: InitialsAvatar(name: post.name),
        title: Text(post.name),
        subtitle: Text(post.email),
        trailing: IconButton(
          icon: Icon(_vm.favoritePosts.contains(post.id) ? Icons.favorite : Icons.favorite_border),
          onPressed: () {
            // Your button action here
            setState(() {
              _vm.toggleFavorite(post);
            });
          },
        ),
        onTap: () {
          // 'context' is readily available here from the itemBuilder
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => detailsPage(
                data: users[index],
              ), // Pass data if needed
            ),
          );
        },
      ));
    },
  ),
  );
}
}
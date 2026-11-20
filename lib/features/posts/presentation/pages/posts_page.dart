import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';
import 'post_detail_page.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading || state is PostInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PostError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<PostBloc>().add(const FetchPosts()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final posts = (state as PostLoaded).posts;
          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<PostBloc>();
              bloc.add(const RefreshPosts());
              await bloc.stream.firstWhere((s) => s is PostLoaded || s is PostError);
            },
            child: ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

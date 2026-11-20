import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/posts/data/datasources/post_remote_data_source.dart';
import 'features/posts/data/repositories/post_repository_impl.dart';
import 'features/posts/domain/usecases/get_posts.dart';
import 'features/posts/presentation/bloc/post_bloc.dart';
import 'features/posts/presentation/bloc/post_event.dart';
import 'features/posts/presentation/pages/posts_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = PostRepositoryImpl(PostRemoteDataSource());
    return MaterialApp(
      title: 'Posts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: BlocProvider(
        create: (_) => PostBloc(GetPosts(repository))..add(const FetchPosts()),
        child: const PostsPage(),
      ),
    );
  }
}

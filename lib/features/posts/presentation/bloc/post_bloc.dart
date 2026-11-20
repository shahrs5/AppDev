import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/get_posts.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc(this.getPosts) : super(const PostInitial()) {
    on<FetchPosts>(_onFetch);
    on<RefreshPosts>(_onRefresh);
  }

  final GetPosts getPosts;

  Future<void> _onFetch(FetchPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());
    await _load(emit);
  }

  Future<void> _onRefresh(RefreshPosts event, Emitter<PostState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<PostState> emit) async {
    try {
      final posts = await getPosts();
      emit(PostLoaded(posts));
    } on PostFailure catch (e) {
      emit(PostError(e.message));
    }
  }
}

import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class FetchPosts extends PostEvent {
  const FetchPosts();
}

class RefreshPosts extends PostEvent {
  const RefreshPosts();
}

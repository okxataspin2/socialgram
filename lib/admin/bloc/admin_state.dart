import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

import 'admin_event.dart';

class AdminState extends Equatable {
  const AdminState({
    this.status = AdminStatus.initial,
    this.users = const [],
    this.searchResults = const [],
    this.messages = const [],
    this.messagesStatus = AdminStatus.initial,
    this.posts = const [],
    this.postsStatus = AdminStatus.initial,
    this.conversations = const [],
    this.conversationsStatus = AdminStatus.initial,
    this.postsStats = const {},
    this.pendingPosts = const [],
    this.pendingPostsStatus = AdminStatus.initial,
    this.autoApprove = false,
    this.isImpersonating = false,
    this.impersonatedUserId,
  });

  final AdminStatus status;
  final List<User> users;
  final List<User> searchResults;
  final List<Message> messages;
  final AdminStatus messagesStatus;
  final List<Post> posts;
  final AdminStatus postsStatus;
  final List<Map<String, dynamic>> conversations;
  final AdminStatus conversationsStatus;
  final Map<String, dynamic> postsStats;
  final List<Post> pendingPosts;
  final AdminStatus pendingPostsStatus;
  final bool autoApprove;
  final bool isImpersonating;
  final String? impersonatedUserId;

  AdminState copyWith({
    AdminStatus? status,
    List<User>? users,
    List<User>? searchResults,
    List<Message>? messages,
    AdminStatus? messagesStatus,
    List<Post>? posts,
    AdminStatus? postsStatus,
    List<Map<String, dynamic>>? conversations,
    AdminStatus? conversationsStatus,
    Map<String, dynamic>? postsStats,
    List<Post>? pendingPosts,
    AdminStatus? pendingPostsStatus,
    bool? autoApprove,
    bool? isImpersonating,
    String? impersonatedUserId,
    bool clearImpersonatedUserId = false,
  }) {
    return AdminState(
      status: status ?? this.status,
      users: users ?? this.users,
      searchResults: searchResults ?? this.searchResults,
      messages: messages ?? this.messages,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      posts: posts ?? this.posts,
      postsStatus: postsStatus ?? this.postsStatus,
      conversations: conversations ?? this.conversations,
      conversationsStatus: conversationsStatus ?? this.conversationsStatus,
      postsStats: postsStats ?? this.postsStats,
      pendingPosts: pendingPosts ?? this.pendingPosts,
      pendingPostsStatus: pendingPostsStatus ?? this.pendingPostsStatus,
      autoApprove: autoApprove ?? this.autoApprove,
      isImpersonating: isImpersonating ?? this.isImpersonating,
      impersonatedUserId: clearImpersonatedUserId
          ? null
          : impersonatedUserId ?? this.impersonatedUserId,
    );
  }

  @override
  List<Object> get props => [
        status,
        users,
        searchResults,
        messages,
        messagesStatus,
        posts,
        postsStatus,
        conversations,
        conversationsStatus,
        postsStats,
        pendingPosts,
        pendingPostsStatus,
        autoApprove,
        isImpersonating,
        impersonatedUserId ?? '',
      ];
}

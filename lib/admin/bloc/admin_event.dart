import 'package:equatable/equatable.dart';

enum AdminStatus { initial, loading, success, failure }

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class AdminUsersRequested extends AdminEvent {
  const AdminUsersRequested({this.limit = 50, this.offset = 0});

  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}

class AdminSearchUsers extends AdminEvent {
  const AdminSearchUsers(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

class AdminAddFollower extends AdminEvent {
  const AdminAddFollower({required this.userId, required this.followerId});

  final String userId;
  final String followerId;

  @override
  List<Object> get props => [userId, followerId];
}

class AdminRemoveFollower extends AdminEvent {
  const AdminRemoveFollower({required this.userId, required this.followerId});

  final String userId;
  final String followerId;

  @override
  List<Object> get props => [userId, followerId];
}

class AdminDeleteUser extends AdminEvent {
  const AdminDeleteUser(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class AdminMessagesRequested extends AdminEvent {
  const AdminMessagesRequested({this.limit = 50, this.offset = 0});

  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}

class AdminPostsRequested extends AdminEvent {
  const AdminPostsRequested({
    this.limit = 50,
    this.offset = 0,
    this.onlyReels = false,
  });

  final int limit;
  final int offset;
  final bool onlyReels;

  @override
  List<Object> get props => [limit, offset, onlyReels];
}

class AdminDeletePost extends AdminEvent {
  const AdminDeletePost(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class AdminDeleteMessage extends AdminEvent {
  const AdminDeleteMessage(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class AdminUpdateUserRole extends AdminEvent {
  const AdminUpdateUserRole({required this.userId, required this.role});

  final String userId;
  final String role;

  @override
  List<Object> get props => [userId, role];
}

class AdminSuspendUser extends AdminEvent {
  const AdminSuspendUser({
    required this.userId,
    required this.suspended,
    this.reason,
  });

  final String userId;
  final bool suspended;
  final String? reason;

  @override
  List<Object> get props => [userId, suspended, reason ?? ''];
}

class AdminConversationMessagesRequested extends AdminEvent {
  const AdminConversationMessagesRequested(this.conversationId);

  final String conversationId;

  @override
  List<Object> get props => [conversationId];
}

class AdminConversationsRequested extends AdminEvent {
  const AdminConversationsRequested({this.limit = 50, this.offset = 0});

  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}

class AdminPostsStatsRequested extends AdminEvent {
  const AdminPostsStatsRequested();

  @override
  List<Object> get props => [];
}

class AdminPendingPostsRequested extends AdminEvent {
  const AdminPendingPostsRequested({this.limit = 50, this.offset = 0});

  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}

class AdminApprovePost extends AdminEvent {
  const AdminApprovePost(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class AdminRejectPost extends AdminEvent {
  const AdminRejectPost({required this.id, this.reason});

  final String id;
  final String? reason;

  @override
  List<Object> get props => [id, reason ?? ''];
}

class AdminSetAutoApprove extends AdminEvent {
  const AdminSetAutoApprove(this.enabled);

  final bool enabled;

  @override
  List<Object> get props => [enabled];
}

class AdminCreateUser extends AdminEvent {
  const AdminCreateUser({
    required this.username,
    required this.password,
    required this.displayName,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  final String username;
  final String password;
  final String displayName;
  final int followerCount;
  final int followingCount;

  @override
  List<Object> get props => [
    username,
    password,
    displayName,
    followerCount,
    followingCount,
  ];
}

class AdminStartImpersonation extends AdminEvent {
  const AdminStartImpersonation(this.userId);

  final String userId;

  @override
  List<Object> get props => [userId];
}

class AdminStopImpersonation extends AdminEvent {
  const AdminStopImpersonation();
}

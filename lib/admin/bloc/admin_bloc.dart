import 'package:bloc/bloc.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc({
    required this.userRepository,
    required this.chatsRepository,
    required this.postsRepository,
  }) : super(const AdminState()) {
    on<AdminUsersRequested>(_onUsersRequested);
    on<AdminSearchUsers>(_onSearchUsers);
    on<AdminAddFollower>(_onAddFollower);
    on<AdminRemoveFollower>(_onRemoveFollower);
    on<AdminDeleteUser>(_onDeleteUser);
    on<AdminMessagesRequested>(_onMessagesRequested);
    on<AdminPostsRequested>(_onPostsRequested);
    on<AdminDeletePost>(_onDeletePost);
    on<AdminDeleteMessage>(_onDeleteMessage);
    on<AdminUpdateUserRole>(_onUpdateUserRole);
    on<AdminSuspendUser>(_onSuspendUser);
    on<AdminConversationsRequested>(_onConversationsRequested);
    on<AdminConversationMessagesRequested>(_onConversationMessagesRequested);
    on<AdminPostsStatsRequested>(_onPostsStatsRequested);
    on<AdminPendingPostsRequested>(_onPendingPostsRequested);
    on<AdminApprovePost>(_onApprovePost);
    on<AdminRejectPost>(_onRejectPost);
    on<AdminSetAutoApprove>(_onSetAutoApprove);
    on<AdminCreateUser>(_onCreateUser);
    on<AdminStartImpersonation>(_onStartImpersonation);
    on<AdminStopImpersonation>(_onStopImpersonation);
  }

  final UserRepository userRepository;
  final ChatsRepository chatsRepository;
  final PostsRepository postsRepository;

  Future<void> _onUsersRequested(
    AdminUsersRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final users = await userRepository.getAllUsers(
        limit: event.limit,
        offset: event.offset,
      );
      emit(state.copyWith(users: users, status: AdminStatus.success));
    } catch (error, stackTrace) {
      emit(state.copyWith(status: AdminStatus.failure));
      logE('Failed to fetch users', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onSearchUsers(
    AdminSearchUsers event,
    Emitter<AdminState> emit,
  ) async {
    final query = event.query.toLowerCase();
    final filtered = state.users.where((u) {
      final username = u.username?.toLowerCase() ?? '';
      final fullName = u.fullName?.toLowerCase() ?? '';
      return username.contains(query) || fullName.contains(query);
    }).toList();
    emit(state.copyWith(searchResults: filtered));
  }

  Future<void> _onAddFollower(
    AdminAddFollower event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await userRepository.follow(
        followToId: event.userId,
        followerId: event.followerId,
      );
      add(const AdminUsersRequested());
    } catch (error, stackTrace) {
      logE('Failed to add follower', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onRemoveFollower(
    AdminRemoveFollower event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await userRepository.unfollow(
        unfollowId: event.userId,
        unfollowerId: event.followerId,
      );
      add(const AdminUsersRequested());
    } catch (error, stackTrace) {
      logE('Failed to remove follower', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onDeleteUser(
    AdminDeleteUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await userRepository.deleteUser(id: event.id);
      add(const AdminUsersRequested());
    } catch (error, stackTrace) {
      logE('Failed to delete user', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onMessagesRequested(
    AdminMessagesRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(messagesStatus: AdminStatus.loading));
    try {
      final messages = await chatsRepository.getAllMessages(
        limit: event.limit,
        offset: event.offset,
      );
      emit(
        state.copyWith(
          messages: messages,
          messagesStatus: AdminStatus.success,
        ),
      );
    } catch (error, stackTrace) {
      emit(state.copyWith(messagesStatus: AdminStatus.failure));
      logE('Failed to fetch messages', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onDeleteMessage(
    AdminDeleteMessage event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await chatsRepository.deleteMessage(messageId: event.id);
      add(const AdminMessagesRequested());
    } catch (error, stackTrace) {
      logE('Failed to delete message', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onPostsRequested(
    AdminPostsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(postsStatus: AdminStatus.loading));
    try {
      final posts = await postsRepository.getAllPosts(
        limit: event.limit,
        offset: event.offset,
        onlyReels: event.onlyReels,
      );
      emit(state.copyWith(posts: posts, postsStatus: AdminStatus.success));
    } catch (error, stackTrace) {
      emit(state.copyWith(postsStatus: AdminStatus.failure));
      logE('Failed to fetch posts', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onDeletePost(
    AdminDeletePost event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await postsRepository.deletePost(id: event.id);
      add(const AdminPostsRequested());
    } catch (error, stackTrace) {
      logE('Failed to delete post', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onUpdateUserRole(
    AdminUpdateUserRole event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await userRepository.updateUserRole(
        userId: event.userId,
        role: event.role,
      );
      await chatsRepository.logAdminAction(
        adminId: userRepository.currentUserId ?? '',
        action: 'update_user_role',
        targetType: 'user',
        targetId: event.userId,
        details: event.role,
      );
      add(const AdminUsersRequested());
    } catch (error, stackTrace) {
      logE('Failed to update role', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onSuspendUser(
    AdminSuspendUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await userRepository.suspendUser(
        userId: event.userId,
        suspended: event.suspended,
        reason: event.reason,
      );
      await chatsRepository.logAdminAction(
        adminId: userRepository.currentUserId ?? '',
        action: 'suspend_user',
        targetType: 'user',
        targetId: event.userId,
        details: event.suspended ? 'suspended' : 'unsuspended',
      );
      add(const AdminUsersRequested());
    } catch (error, stackTrace) {
      logE('Failed to suspend user', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onConversationsRequested(
    AdminConversationsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(conversationsStatus: AdminStatus.loading));
    try {
      final conversations = await userRepository.getAllConversations(
        limit: event.limit,
        offset: event.offset,
      );
      emit(
        state.copyWith(
          conversations: conversations,
          conversationsStatus: AdminStatus.success,
        ),
      );
    } catch (error, stackTrace) {
      emit(state.copyWith(conversationsStatus: AdminStatus.failure));
      logE('Failed to fetch conversations',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onConversationMessagesRequested(
    AdminConversationMessagesRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(messagesStatus: AdminStatus.loading));
    try {
      final messages = await chatsRepository.getConversationMessages(
        conversationId: event.conversationId,
        limit: 100,
        offset: 0,
      );
      emit(
        state.copyWith(messages: messages, messagesStatus: AdminStatus.success),
      );
    } catch (error, stackTrace) {
      emit(state.copyWith(messagesStatus: AdminStatus.failure));
      logE('Failed to fetch conversation',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onPostsStatsRequested(
    AdminPostsStatsRequested event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final stats = await postsRepository.getPostsStats();
      emit(state.copyWith(postsStats: stats));
    } catch (error, stackTrace) {
      logE('Failed to fetch posts stats',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onPendingPostsRequested(
    AdminPendingPostsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(pendingPostsStatus: AdminStatus.loading));
    try {
      final posts = await postsRepository.getPendingPosts(
        limit: event.limit,
        offset: event.offset,
      );
      emit(
        state.copyWith(
          pendingPosts: posts,
          pendingPostsStatus: AdminStatus.success,
        ),
      );
    } catch (error, stackTrace) {
      emit(state.copyWith(pendingPostsStatus: AdminStatus.failure));
      logE('Failed to fetch pending posts',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onApprovePost(
    AdminApprovePost event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await postsRepository.approvePost(postId: event.id);
      emit(state.copyWith(
        pendingPosts: state.pendingPosts
            .where((p) => p.id != event.id)
            .toList(),
      ));
    } catch (error, stackTrace) {
      logE('Failed to approve post',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onRejectPost(
    AdminRejectPost event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await postsRepository.rejectPost(
        postId: event.id,
        reason: event.reason,
      );
      emit(state.copyWith(
        pendingPosts: state.pendingPosts
            .where((p) => p.id != event.id)
            .toList(),
      ));
    } catch (error, stackTrace) {
      logE('Failed to reject post',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onSetAutoApprove(
    AdminSetAutoApprove event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await postsRepository.setAutoApprove(enabled: event.enabled);
      emit(state.copyWith(autoApprove: event.enabled));
    } catch (error, stackTrace) {
      logE('Failed to set auto-approve',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onCreateUser(
    AdminCreateUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await userRepository.createCustomUser(
        username: event.username,
        password: event.password,
        displayName: event.displayName,
        followerCount: event.followerCount,
        followingCount: event.followingCount,
      );
      add(const AdminUsersRequested());
    } catch (error, stackTrace) {
      logE('Failed to create user',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onStartImpersonation(
    AdminStartImpersonation event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await userRepository.setImpersonatedUserId(event.userId);
      await chatsRepository.logAdminAction(
        adminId: userRepository.currentUserId ?? '',
        action: 'start_impersonation',
        targetType: 'user',
        targetId: event.userId,
      );
      emit(state.copyWith(
        isImpersonating: true,
        impersonatedUserId: event.userId,
      ));
    } catch (error, stackTrace) {
      logE('Failed to start impersonation',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onStopImpersonation(
    AdminStopImpersonation event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await userRepository.stopImpersonation();
      emit(state.copyWith(
        isImpersonating: false,
        clearImpersonatedUserId: true,
      ));
    } catch (error, stackTrace) {
      logE('Failed to stop impersonation',
          error: error, stackTrace: stackTrace);
    }
  }
}

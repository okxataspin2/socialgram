import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:powersync/sqlite3_common.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

/// User base repository.
abstract class UserBaseRepository {
  /// The id of the currently authenticated user.
  String? get currentUserId;

  /// Broadcasts the user profile identified by [id].
  Stream<User> profile({required String id});

  /// Updates currently authenticated database user's metadata.
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
    String? password,
  });

  /// Follows to the user by provided [followToId]. [followerId] is the id
  /// of currently authenticated user.
  Future<void> follow({
    required String followToId,
    String? followerId,
  });

  /// Unfollow from user profile, identified by [unfollowId].
  Future<void> unfollow({required String unfollowId, String? unfollowerId});

  /// Removes follower from followers of current users.
  Future<void> removeFollower({required String id});

  /// Check if the user identified by [followerId] is followed to
  /// the user identified by [userId].
  Future<bool> isFollowed({
    required String userId,
    String? followerId,
  });

  /// Returns realtime stream of followings status of the user identified by
  /// [followerId] to the user identified by [userId].
  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  });

  /// Returns followings count of the user identified by [userId].
  Stream<int> followersCountOf({required String userId});

  /// Returns count of followings of the user identified by [userId].
  Stream<int> followingsCountOf({required String userId});

  /// Returns a list of followers of the user identified by [userId].
  Future<List<User>> getFollowers({String? userId});

  /// Returns a list of followings of the user identified by [userId].
  Future<List<User>> getFollowings({String? userId});

  /// Broadcasts a list of followers of the user identified by [userId].
  Stream<List<User>> followers({required String userId});

  /// Looks up into a database a returns users associated with the provided
  /// [query].
  Future<List<User>> searchUsers({
    required int limit,
    required int offset,
    required String? query,
    String? userId,
    String? excludeUserIds,
  });

  /// Returns a paginated list of all users - admin only.
  Future<List<User>> getAllUsers({required int limit, required int offset});

  /// Adds a follower relationship - admin only.
  Future<void> addFollower({
    required String userId,
    required String followerId,
  });

  /// Deletes a user by id - admin only.
  Future<void> deleteUser({required String id});

  /// Updates user role (admin only).
  Future<void> updateUserRole({
    required String userId,
    required String role,
  });

  /// Suspends a user account - admin only.
  Future<void> suspendUser({
    required String userId,
    required bool suspended,
    String? reason,
  });

  /// Fetches all conversations for admin viewing.
  Future<List<Map<String, dynamic>>> getAllConversations({
    required int limit,
    required int offset,
  });

  /// Creates a custom user account (for admin-created accounts).
  Future<void> createCustomUser({
    required String username,
    required String password,
    required String displayName,
    int followerCount = 0,
    int followingCount = 0,
  });

  /// Sets the impersonated user ID (admin acts as that user).
  Future<void> setImpersonatedUserId(String userId);

  /// Stops impersonation and returns to admin context.
  Future<void> stopImpersonation();
}

/// Abstract base class for a posts repository.
abstract class PostsBaseRepository {
  /// Reads the associated post from the database by the [id].
  Future<Post?> getPostBy({required String id});

  /// Fetches the profiles of users who liked post, found by [postId].
  Future<List<User>> getPostLikers({
    required String postId,
    int limit = 30,
    int offset = 0,
  });

  /// Fetches the profiles of users who liked the post, identified by [postId]
  /// and who are in followings of the user identified by current user `id`.
  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  });

  /// Likes the post by provided either post or comment [id].
  Future<void> like({
    required String id,
    bool post = true,
  });

  /// Returns a real-time stream of likes count of post by provided [id].
  Stream<int> likesOf({
    required String id,
    bool post = true,
  });

  /// Returns a real-time stream of whether the post by [id] is liked by user
  /// identified by [userId].
  Stream<bool> isLiked({
    required String id,
    String? userId,
    bool post = true,
  });

  /// Returns the page of posts with provided [offset] and [limit].
  Future<List<Post>> getPage({
    required int offset,
    required int limit,
    bool onlyReels = false,
  });

  /// Create a new post with provided details.
  Future<Post?> createPost({
    required String id,
    required String caption,
    required String media,
  });

  /// Deletes the post with provided [id].
  /// Returns the optional `id` of the deleted post.
  Future<String?> deletePost({required String id});

  /// Updates the post with provided [id] and optional parameters to update.
  Future<Post?> updatePost({required String id, String? caption});

  /// Returns the stream of real-time posts of the current user.
  Stream<List<Post>> postsOf({String? userId});

  /// Returns a stream of amount of posts of the user identified by [userId].
  Stream<int> postsAmountOf({required String userId});

  /// Returns a stream of amount of comments of the post identified by [postId].
  Stream<int> commentsAmountOf({required String postId});

  /// Returns a stream of comments of the post identified by [postId].
  Stream<List<Comment>> commentsOf({required String postId});

  /// Returns a stream of replied comments of the comment identified by
  /// [commentId].
  Stream<List<Comment>> repliedCommentsOf({required String commentId});

  /// Created a comment with provided details.
  Future<void> createComment({
    required String content,
    required String postId,
    required String userId,
    String? repliedToCommentId,
  });

  /// Delete the comment by associated [id].
  Future<void> deleteComment({required String id});

  /// Shares the post with the user identified by [receiver].
  Future<void> sharePost({
    required String id,
    required User sender,
    required User receiver,
    required Message sharedPostMessage,
    Message? message,
    PostAuthor? postAuthor,
  });

  /// Returns a paginated list of all posts - admin only.
  Future<List<Post>> getAllPosts({
    required int limit,
    required int offset,
    bool onlyReels = false,
  });

  /// Returns analytics/stats about posts - admin only.
  Future<Map<String, dynamic>> getPostsStats();

  /// Approves a post - admin only.
  Future<void> approvePost({required String postId});

  /// Rejects a post - admin only.
  Future<void> rejectPost({required String postId, String? reason});

  /// Gets pending posts awaiting approval - admin only.
  Future<List<Post>> getPendingPosts({required int limit, required int offset});

  /// Toggles auto-approval setting - admin only.
  Future<void> setAutoApprove({required bool enabled});
}

/// Abstract base class for a chats repository.
abstract class ChatsBaseRepository {
  /// Returns a stream of real-time chats of the user identified by [userId].
  Stream<List<ChatInbox>> chatsOf({required String userId});

  /// Returns a stream of real-time messages of the chat identified by [chatId].
  Stream<List<Message>> messagesOf({required String chatId});

  /// Fetches a list of messages of the chat identified by [chatId].
  Future<List<Message>> getMessages({
    required String chatId,
    required int limit,
    required int offset,
  });

  /// Fetches a message with provided [messageId].
  Future<Message> getRepliedMessage({required String messageId});

  /// Creates and send message with provided data. After sending the message
  /// the notification is sent to the user, identified by [receiver]'s `id`.
  Future<void> sendMessage({
    required String chatId,
    required User sender,
    required User receiver,
    required Message message,
    PostAuthor? postAuthor,
  });

  /// Deletes the message with provided [messageId].
  Future<void> deleteMessage({required String messageId});

  /// Deletes the chat with provided [chatId] and participant from the chat,
  /// identified by [userId].
  Future<void> deleteChat({required String chatId, required String userId});

  /// Creates a new chat with provided [userId] and [participantId].
  Future<void> createChat({
    required String userId,
    required String participantId,
  });

  /// Marks the message as read by [messageId].
  Future<void> readMessage({
    required String messageId,
  });

  /// Edits the message with provided [oldMessage] and [newMessage].
  Future<void> editMessage({
    required Message oldMessage,
    required Message newMessage,
  });

  /// Returns a paginated list of all messages - admin only.
  Future<List<Message>> getAllMessages({required int limit, required int offset});

  /// Fetches messages for a specific conversation - admin only.
  Future<List<Message>> getConversationMessages({
    required String conversationId,
    required int limit,
    required int offset,
  });

  /// Logs an admin action for audit trail.
  Future<void> logAdminAction({
    required String adminId,
    required String action,
    required String targetType,
    required String targetId,
    String? details,
  });
}

/// The abstract base class for a stories repository.
abstract class StoriesBaseRepository {
  /// {@macro stories_base_repository}
  const StoriesBaseRepository();

  /// Broadcasts the stream of the stories from the database.
  Stream<List<Story>> getStories({
    required String userId,
    bool includeAuthor = true,
  });

  /// Creates the [Story] with the provided data.
  Future<void> createStory({
    required User author,
    required StoryContentType contentType,
    required String contentUrl,
    String? id,
    int? duration,
  });

  /// Deletes the [Story] identified by [id].
  Future<void> deleteStory({required String id});

  /// Uploads the story media into the Supabase storage.
  Future<String> uploadStoryMedia({
    required String storyId,
    required String fileName,
    required Uint8List imageBytes,
  });
}

/// {@template client}
/// Represents a client that interacts with various repositories.
///
/// ### Example usage:
/// ```dart
/// final powerSyncRepository = PowerSyncRepository();
/// final client = PowerSyncDatabaseClient(powerSyncRepository);
///
/// client.createPost(
///   id: 'post123',
///   userId: 'user123',
///   caption: 'Hello, world!',
///   media: 'https://example.com/image.jpg',
/// );
/// ```
/// {@endtemplate}
abstract class DatabaseClient
    implements
        UserBaseRepository,
        PostsBaseRepository,
        ChatsBaseRepository,
        StoriesBaseRepository {
  /// {@macro database_client}
  const DatabaseClient();

  /// Subscribed to the real time Supabase postgres messages changed.
  ///
  /// Each time a specific message is changed, the callback is called with
  /// the payload.
  ///
  /// It allows to update the UI in real time, without rebuilding the whole
  /// list of messages.
  RealtimeChannel onMessagesUpdates({
    required String conversationId,
    required ValueSetter<
      ({Map<String, dynamic> newRecord, Map<String, dynamic> oldRecord})
    >
    callback,
  });
}

/// {@template power_sync_database_client}
/// A class representing a PowerSyncDatabaseClient.
///
/// It allows users to perform various operations such as creating posts,
/// retrieving posts, liking posts, following users, and more.
/// {@endtemplate}
class PowerSyncDatabaseClient extends DatabaseClient {
  /// {@macro power_sync_database_client}
  PowerSyncDatabaseClient({required PowerSyncRepository powerSyncRepository})
    : _powerSyncRepository = powerSyncRepository;

  final PowerSyncRepository _powerSyncRepository;

  @override
  RealtimeChannel onMessagesUpdates({
    required String conversationId,
    required ValueSetter<
      ({Map<String, dynamic> newRecord, Map<String, dynamic> oldRecord})
    >
    callback,
  }) {
    return Supabase.instance.client
        .channel('public:messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            callback(
              (newRecord: payload.newRecord, oldRecord: payload.oldRecord),
            );
          },
        )
        .subscribe();
  }

  @override
  String? get currentUserId =>
      _powerSyncRepository.supabase.auth.currentSession?.user.id;

  @override
  Stream<User> profile({required String id}) => _powerSyncRepository
      .db()
      .watch(
        'SELECT * FROM profiles WHERE id = ?',
        parameters: [id],
      )
      .map(
        (event) => event.isEmpty ? User.anonymous : User.fromJson(event.first),
      );

  @override
  Future<Post?> createPost({
    required String id,
    required String caption,
    required String media,
  }) async {
    if (currentUserId == null) return null;
    final result = await Future.wait([
      _powerSyncRepository.db().execute(
        '''
    INSERT INTO posts(id, user_id, caption, media, created_at)
    VALUES(?, ?, ?, ?, ?)
    RETURNING *
    ''',
        [
          id,
          currentUserId,
          caption,
          media,
          DateTime.timestamp().toIso8601String(),
        ],
      ),
      _powerSyncRepository.db().get(
        '''
SELECT * FROM profiles WHERE id = ?
''',
        [currentUserId],
      ),
    ]);
    if (result.isEmpty) return null;
    final json = Map<String, dynamic>.from((result.first as ResultSet).first);
    final author = User.fromJson(result.last as Row);
    final jsonMedia = json['media'] as String;

    final rootToken = RootIsolateToken.instance!;
    final mediaResult = await compute(_computeJsonMedia, [
      rootToken,
      jsonMedia,
    ]);
    final postMedia = List<Media>.from(
      mediaResult.map(Media.fromJson).toList(),
    );
    return Post.fromJson(json, media: postMedia).copyWith(author: author);
  }

  @override
  Stream<int> postsAmountOf({required String userId}) => _powerSyncRepository
      .db()
      .watch(
        '''
    SELECT COUNT(*) as posts_count FROM posts where user_id = ?
    ''',
        parameters: [userId],
      )
      .map(
        (event) =>
            event.safeMap((element) => element['posts_count']).first as int,
      );

  @override
  Stream<List<Post>> postsOf({String? userId}) {
    if (currentUserId == null) return const Stream.empty();
    assert(
      userId != null && currentUserId != null,
      'Both given `userId` and `currentUserId` cannot be null',
    );
    return _powerSyncRepository
        .db()
        .watch(
          '''
SELECT
  posts.*,
  p.id as user_id,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  left join profiles p on posts.user_id = p.id 
WHERE user_id = ?
ORDER BY created_at DESC
      ''',
          parameters: [userId ?? currentUserId],
        )
        .asyncMap(
          (result) async {
            final jsonListMedia = result.map((row) {
              final json = Map<String, dynamic>.from(row);
              return json['media'] as String;
            }).toList();

            final rootToken = RootIsolateToken.instance!;
            final media =
                await compute<List<dynamic>, List<List<Map<String, dynamic>>>>(
                  _computeJsonListMedia,
                  [rootToken, jsonListMedia],
                );

            final posts = <Post>[];
            for (var i = 0; i < result.length; i++) {
              final json = Map<String, dynamic>.from(result[i]);
              final post = Post.fromJson(
                json,
                media: List<Media>.from(media[i].map(Media.fromJson).toList()),
              );
              posts.add(post);
            }
            return posts;
          },
        );
  }

  @override
  Future<String?> deletePost({required String id}) async {
    final result = await _powerSyncRepository.db().execute(
      'DELETE FROM posts WHERE id = ? RETURNING id',
      [id],
    );
    if (result.isEmpty) return null;
    return result.first['id'] as String;
  }

  static List<List<Map<String, dynamic>>> _computeJsonListMedia(
    List<dynamic> args,
  ) {
    final rootToken = args[0] as RootIsolateToken;
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
    final jsonListMedia = args[1] as List<String?>;
    final listMedia = jsonListMedia
        .map(
          (jsonMedia) =>
              (jsonMedia == null
                      ? <Map<String, dynamic>>[]
                      : jsonDecode(jsonMedia) as List<dynamic>)
                  .cast<Map<String, dynamic>>(),
        )
        .toList();

    return listMedia;
  }

  static List<Map<String, dynamic>> _computeJsonMedia(
    List<dynamic> args,
  ) {
    final rootToken = args[0] as RootIsolateToken;
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
    final jsonMedia = args[1] as String;
    final listMedia = (jsonDecode(jsonMedia) as List<dynamic>)
        .cast<Map<String, dynamic>>();

    return listMedia;
  }

  @override
  Future<List<Post>> getPage({
    required int offset,
    required int limit,
    bool onlyReels = false,
  }) async {
    //     if (onlyReels) {
    //       final result = await _powerSyncRepository.db().execute(
    //         '''
    // SELECT
    //   posts.*,
    //   p.id as user_id,
    //   p.avatar_url as avatar_url,
    //   p.username as username
    // FROM
    //   posts
    //   inner join profiles p on posts.user_id = p.id
    // WHERE array_length(array(posts.media), 1) = 1
    //   AND posts.media.type = '__video_media__'
    // LIMIT ?1 OFFSET ?2
    //     ''',
    //         [limit, offset],
    //       );

    //       final posts = <Post>[];

    //       for (final row in result) {
    //         final json = Map<String, dynamic>.from(row);
    //         final post = Post.fromJson(json);
    //         posts.add(post);
    //       }
    //       return posts;
    //     }
    final result = await _powerSyncRepository.db().execute(
      '''
SELECT
  posts.id,
  posts.created_at,
  posts.caption,
  posts.media,
  posts.updated_at,
  p.id as user_id,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  left join profiles p on posts.user_id = p.id 
ORDER BY created_at DESC LIMIT ?1 OFFSET ?2
    ''',
      [limit, offset],
    );
    final jsonListMedia = result.map((row) {
      final json = Map<String, dynamic>.from(row);
      return json['media'] as String;
    }).toList();

    final rootToken = RootIsolateToken.instance!;
    final media = await compute(
      _computeJsonListMedia,
      [rootToken, jsonListMedia],
    );

    final posts = <Post>[];
    for (var i = 0; i < result.length; i++) {
      final json = Map<String, dynamic>.from(result[i]);
      final post = Post.fromJson(
        json,
        media: List<Media>.from(media[i].map(Media.fromJson).toList()),
      );
      posts.add(post);
    }
    return posts;
    // final result = await _powerSyncRepository.db().execute(
    //           '''
    // SELECT
    //   posts.*,
    //   p.id as user_id,
    //   p.avatar_url as avatar_url,
    //   p.username as username,
    //   p.full_name as full_name
    // FROM
    //   posts
    //   inner join profiles p on posts.user_id = p.id
    // ORDER BY created_at DESC LIMIT ?1 OFFSET ?2
    //     ''',
    //           [limit, offset],
    //         );

    //     final instaBlocks = result.map((row) {
    //       final json = Map<String, dynamic>.from(row);
    //       return Post.fromJson(json);
    //     }).toList();
    // return result;
  }

  @override
  Future<Post?> updatePost({required String id, String? caption}) async {
    final row = await _powerSyncRepository.db().execute(
      '''
UPDATE posts
SET
  caption = ?2,
  updated_at = ?3
WHERE id = ?1
RETURNING *
''',
      [id, caption, DateTime.timestamp().toIso8601String()],
    );
    if (row.isEmpty) return null;
    final json = Map<String, dynamic>.from(row.first);
    final jsonMedia = json['media'] as String;

    final rootToken = RootIsolateToken.instance!;
    final result = await compute(_computeJsonMedia, [rootToken, jsonMedia]);
    final media = List<Media>.from(result.map(Media.fromJson).toList());
    return Post.fromJson(json, media: media);
  }

  @override
  Stream<int> likesOf({required String id, bool post = true}) {
    final statement = post ? 'post_id' : 'comment_id';
    return _powerSyncRepository
        .db()
        .watch(
          '''
SELECT COUNT(*) AS total_likes
FROM likes
WHERE $statement = ? AND $statement IS NOT NULL
''',
          parameters: [id],
        )
        .map(
          (result) => result.safeMap((row) => row['total_likes']).first as int,
        );
  }

  @override
  Stream<bool> isLiked({
    required String id,
    String? userId,
    bool post = true,
  }) {
    final statement = post ? 'post_id' : 'comment_id';
    return _powerSyncRepository
        .db()
        .watch(
          '''
      SELECT EXISTS (
        SELECT 1 
        FROM likes
        WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL
      )
''',
          parameters: [userId ?? currentUserId, id],
        )
        .map((event) => (event.first.values.first! as int).isTrue);
  }

  @override
  Future<Post?> getPostBy({required String id}) async {
    final row = await _powerSyncRepository.db().getOptional(
      '''
SELECT
  posts.*,
  p.id as user_id,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  join profiles p on posts.user_id = p.id 
WHERE posts.id = ?
  ''',
      [id],
    );
    if (row == null) return null;
    final json = Map<String, dynamic>.from(row);
    final jsonMedia = json['media'] as String;

    final rootToken = RootIsolateToken.instance!;
    final mediaResult = await compute(_computeJsonMedia, [
      rootToken,
      jsonMedia,
    ]);
    final postMedia = List<Media>.from(
      mediaResult.map(Media.fromJson).toList(),
    );
    return Post.fromJson(json, media: postMedia);
  }

  @override
  Future<void> like({
    required String id,
    bool post = true,
  }) async {
    if (currentUserId == null) return;
    final statement = post ? 'post_id' : 'comment_id';
    final exists = await _powerSyncRepository.db().execute(
      'SELECT 1 FROM likes '
      'WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL',
      [currentUserId, id],
    );
    if (exists.isEmpty) {
      await _powerSyncRepository.db().execute(
        '''
          INSERT INTO likes(user_id, $statement, id)
            VALUES(?, ?, uuid())
      ''',
        [currentUserId, id],
      );
      return;
    }
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM likes 
          WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL
      ''',
      [currentUserId, id],
    );
  }

  @override
  Stream<int> followersCountOf({required String userId}) => _powerSyncRepository
      .db()
      .watch(
        'SELECT COUNT(*) AS subscription_count FROM subscriptions '
        'WHERE subscribed_to_id = ?',
        parameters: [userId],
      )
      .map(
        (event) =>
            event.safeMap((element) => element['subscription_count']).first
                as int,
      );

  @override
  Future<void> follow({
    required String followToId,
    String? followerId,
  }) async {
    if (currentUserId == null) return;
    if (followToId == currentUserId) return;
    final exists = await isFollowed(
      followerId: followerId ?? currentUserId!,
      userId: followToId,
    );
    if (!exists) {
      await _powerSyncRepository.db().execute(
        '''
          INSERT INTO subscriptions(id, subscriber_id, subscribed_to_id)
            VALUES(uuid(), ?, ?)
      ''',
        [followerId ?? currentUserId!, followToId],
      );
      return;
    }
    await unfollow(
      unfollowId: followToId,
      unfollowerId: followerId ?? currentUserId!,
    );
  }

  @override
  Future<void> unfollow({
    required String unfollowId,
    String? unfollowerId,
  }) async {
    if (currentUserId == null) return;
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
      ''',
      [unfollowerId ?? currentUserId, unfollowId],
    );
  }

  @override
  Future<void> removeFollower({required String id}) async {
    if (currentUserId == null) return;
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
      ''',
      [id, currentUserId],
    );
  }

  @override
  Stream<int> followingsCountOf({required String userId}) =>
      _powerSyncRepository
          .db()
          .watch(
            'SELECT COUNT(*) AS subscription_count FROM subscriptions '
            'WHERE subscriber_id = ?',
            parameters: [userId],
          )
          .map(
            (event) =>
                event.safeMap((element) => element['subscription_count']).first
                    as int,
          );

  @override
  Future<List<User>> getFollowers({String? userId}) async {
    final followersId = await _powerSyncRepository.db().getAll(
      'SELECT subscriber_id FROM subscriptions WHERE subscribed_to_id = ? ',
      [userId ?? currentUserId],
    );
    if (followersId.isEmpty) return [];

    final followers = <User>[];
    for (final followerId in followersId) {
      final result = await _powerSyncRepository.db().execute(
        'SELECT * FROM profiles WHERE id = ?',
        [followerId['subscriber_id']],
      );
      if (result.isEmpty) continue;
      final follower = User.fromJson(result.first);
      followers.add(follower);
    }
    return followers;
  }

  @override
  Stream<List<User>> followers({required String userId}) async* {
    final streamResult = _powerSyncRepository.db().watch(
      'SELECT subscriber_id FROM subscriptions WHERE subscribed_to_id = ? ',
      parameters: [userId],
    );
    await for (final result in streamResult) {
      final followers = <User>[];
      final followersFutures = await Future.wait(
        result
            .where((row) => row.isNotEmpty)
            .safeMap(
              (row) => _powerSyncRepository.db().getOptional(
                'SELECT * FROM profiles WHERE id = ?',
                [row['subscriber_id']],
              ),
            ),
      );
      for (final user in followersFutures) {
        if (user == null) continue;
        final follower = User.fromJson(user);
        followers.add(follower);
      }
      yield followers;
    }
  }

  @override
  Future<List<User>> getFollowings({String? userId}) async {
    final followingsUserId = await _powerSyncRepository.db().getAll(
      'SELECT subscribed_to_id FROM subscriptions WHERE subscriber_id = ? ',
      [userId ?? currentUserId],
    );
    if (followingsUserId.isEmpty) return [];

    final followings = <User>[];
    for (final followingsUserId in followingsUserId) {
      final result = await _powerSyncRepository.db().execute(
        'SELECT * FROM profiles WHERE id = ?',
        [followingsUserId['subscribed_to_id']],
      );
      if (result.isEmpty) continue;
      final following = User.fromJson(result.first);
      followings.add(following);
    }
    return followings;
  }

  @override
  Future<bool> isFollowed({
    required String userId,
    String? followerId,
  }) async {
    final result = await _powerSyncRepository.db().execute(
      '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
      [followerId ?? currentUserId, userId],
    );
    return result.isNotEmpty;
  }

  @override
  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  }) {
    if (followerId == null && currentUserId == null) {
      return const Stream.empty();
    }
    return _powerSyncRepository
        .db()
        .watch(
          '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
          parameters: [followerId ?? currentUserId, userId],
        )
        .map((event) => event.isNotEmpty);
  }

  @override
  Stream<int> commentsAmountOf({required String postId}) => _powerSyncRepository
      .db()
      .watch(
        '''
SELECT COUNT(*) AS comments_count FROM comments
WHERE post_id = ? 
''',
        parameters: [postId],
      )
      .map(
        (result) => result.map((row) => row['comments_count']).first as int,
      );

  @override
  Stream<List<Comment>> commentsOf({required String postId}) =>
      _powerSyncRepository
          .db()
          .watch(
            '''
SELECT 
  c1.*,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name,
  COUNT(c2.id) AS replies
FROM 
  comments c1
  INNER JOIN
    profiles p ON p.id = c1.user_id
  LEFT JOIN
    comments c2 ON c1.id = c2.replied_to_comment_id
WHERE
  c1.post_id = ? AND c1.replied_to_comment_id IS NULL
GROUP BY
    c1.id, p.avatar_url, p.username, p.full_name
ORDER BY created_at ASC
''',
            parameters: [postId],
          )
          .map(
            (result) => result.safeMap(Comment.fromRow).toList(growable: false),
          );

  @override
  Future<void> createComment({
    required String postId,
    required String userId,
    required String content,
    String? repliedToCommentId,
  }) => _powerSyncRepository.db().execute(
    '''
INSERT INTO
  comments(id, post_id, user_id, content, created_at, replied_to_comment_id)
VALUES(uuid(), ?, ?, ?, ?, ?)
''',
    [
      postId,
      userId,
      content,
      DateTime.timestamp().toIso8601String(),
      repliedToCommentId,
    ],
  );

  @override
  Future<void> deleteComment({required String id}) =>
      _powerSyncRepository.db().execute(
        '''
DELETE FROM comments
WHERE id = ?
''',
        [id],
      );

  @override
  Future<void> sharePost({
    required String id,
    required User sender,
    required User receiver,
    required Message sharedPostMessage,
    Message? message,
    PostAuthor? postAuthor,
  }) async {
    final exists = await _powerSyncRepository.db().execute(
      '''
SELECT 1 FROM posts WHERE id = ?
''',
      [id],
    );
    if (exists.isEmpty) return;
    final conversation = await _powerSyncRepository.db().execute(
      '''
SELECT conversation_id
  FROM participants
WHERE user_id = ?
  AND conversation_id IN (
      SELECT conversation_id
      FROM participants
      WHERE user_id = ?
    );
''',
      [sender.id, receiver.id],
    );
    if (conversation.isNotEmpty) {
      final chatId = conversation.first['conversation_id'] as String;
      await Future.wait([
        sendMessage(
          chatId: chatId,
          sender: sender,
          receiver: receiver,
          message: sharedPostMessage,
          postAuthor: postAuthor,
        ),
        if (message != null)
          sendMessage(
            chatId: chatId,
            sender: sender,
            receiver: receiver,
            message: message,
          ),
      ]);
      return;
    }
    final newChatId = uuid.v4();
    final createdConversation = _powerSyncRepository.db().execute(
      '''
insert into
  conversations (id, type, name, created_at, updated_at)
values
  (?, ?, '', ?, ?)
''',
      [newChatId, ChatType.oneOnOne.value, JiffyX.now(), JiffyX.now()],
    );
    final addParticipant1 = _powerSyncRepository.db().execute(
      '''
insert into
  participants (id, user_id, conversation_id)
  values
  (?, ?, ?)
  ''',
      [uuid.v4(), sender.id, newChatId],
    );
    final addParticipant2 = _powerSyncRepository.db().execute(
      '''
insert into
  participants (id, user_id, conversation_id)
  values
  (?, ?, ?)
  ''',
      [uuid.v4(), receiver.id, newChatId],
    );
    await createdConversation.whenComplete(
      () => Future.wait([addParticipant1, addParticipant2]),
    );

    await Future.wait([
      sendMessage(
        chatId: newChatId,
        sender: sender,
        receiver: receiver,
        message: sharedPostMessage,
        postAuthor: postAuthor,
      ),
      if (message != null)
        sendMessage(
          chatId: newChatId,
          sender: sender,
          receiver: receiver,
          message: message,
        ),
    ]);
  }

  @override
  Stream<List<Comment>> repliedCommentsOf({required String commentId}) =>
      _powerSyncRepository
          .db()
          .watch(
            '''
SELECT 
  c1.*,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM 
  comments c1
  INNER JOIN
    profiles p ON p.id = c1.user_id
WHERE
  c1.replied_to_comment_id = ? 
GROUP BY
    c1.id, p.avatar_url, p.username, p.full_name
ORDER BY created_at ASC
''',
            parameters: [commentId],
          )
          .map(
            (result) => result.safeMap(Comment.fromRow).toList(growable: false),
          );

  @override
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
    String? password,
  }) => _powerSyncRepository.updateUser(
    email: email,
    password: password,
    data: {
      if (fullName != null) 'full_name': fullName,
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (pushToken != null) 'push_token': pushToken,
    },
  );

  @override
  Stream<List<ChatInbox>> chatsOf({required String userId}) =>
      _powerSyncRepository
          .db()
          .watch(
            '''
select
  c.id,
  c.type,
  c.name,
  p2.id as participant_id,
  p2.full_name as participant_name,
  p2.email as participant_email,
  p2.username as participant_username,
  p2.avatar_url as participant_avatar_url,
  p2.push_token as participant_push_token
from
  conversations c
  join participants pt on c.id = pt.conversation_id
  join profiles p on pt.user_id = p.id
  join participants pt2 on c.id = pt2.conversation_id
  join profiles p2 on pt2.user_id = p2.id
where
  pt.user_id = ?1
  and pt2.user_id != ?1
''',
            parameters: [userId],
          )
          .map(
            (event) => event.safeMap(ChatInbox.fromRow).toList(growable: false),
          );

  @override
  Stream<List<Message>> messagesOf({required String chatId}) =>
      _powerSyncRepository
          .db()
          .watch(
            '''
SELECT
  m.*,
  m_sender.full_name as full_name,
  m_sender.username as username,
  m_sender.avatar_url as avatar_url,
  a.id as attachment_id,
  a.title as attachment_title,
  a.text as attachment_text,
  a.title_link as attachment_title_link,
  a.image_url as attachment_image_url,
  a.thumb_url as attachment_thumb_url,
  a.author_name as attachment_author_name,
  a.author_link as attachment_author_link,
  a.asset_url as attachment_asset_url,
  a.og_scrape_url as attachment_og_scrape_url,
  a.type as attachment_type,
  r.message as replied_message_message,
  p.caption as shared_post_caption,
  p.created_at as shared_post_created_at,
  p.media as shared_post_media,
  p_author.id as shared_post_author_id,
  p_author.username as shared_post_author_username,
  p_author.full_name as shared_post_author_full_name,
  p_author.avatar_url as shared_post_author_avatar_url
FROm
  messages m
  left join attachments a on m.id = a.message_id
  left join messages r on m.reply_message_id = r.id
  left join posts p on m.shared_post_id = p.id
  join profiles m_sender on m.from_id = m_sender.id
  left join profiles p_author on p.user_id = p_author.id
where
  m.conversation_id = ?   
order by created_at asc
''',
            parameters: [chatId],
          )
          .asyncMap(
            (result) async {
              final messages = <Message>[];
              if (result.isEmpty) return messages;
              final listMediaJson = result
                  .map((e) => e['shared_post_media'] as String?)
                  .toList();
              final resultMedia = await compute(
                _computeJsonListMedia,
                [RootIsolateToken.instance!, listMediaJson],
              );
              for (var i = 0; i < result.length; i++) {
                final json = Map<String, dynamic>.from(result[i]);
                final indexedMedia = resultMedia[i];
                Message message;
                if (indexedMedia.isEmpty) {
                  message = Message.fromRow(json);
                } else {
                  final media = indexedMedia.map(Media.fromJson).toList();
                  message = Message.fromRow(json, media: media);
                }
                messages.add(message);
              }
              return messages;
            },
          );

  @override
  Future<void> createChat({
    required String userId,
    required String participantId,
  }) async {
    final alreadyExists = await _powerSyncRepository.db().getOptional(
      '''
      SELECT 1
      FROM conversations c
      JOIN participants p1 ON c.id = p1.conversation_id
      JOIN participants p2 ON c.id = p2.conversation_id
      WHERE p1.user_id = ? AND p2.user_id = ?
  ''',
      [userId, participantId],
    );
    if (alreadyExists != null) return;
    final conversationId = uuid.v4();
    final createdConversation = _powerSyncRepository.db().execute(
      '''
insert into
  conversations (id, type, name, created_at, updated_at)
values
  (?, ?, '', ?, ?)
''',
      [conversationId, ChatType.oneOnOne.value, JiffyX.now(), JiffyX.now()],
    );
    final addParticipant1 = _powerSyncRepository.db().execute(
      '''
insert into
  participants (id, user_id, conversation_id)
  values
  (?, ?, ?)
  ''',
      [uuid.v4(), userId, conversationId],
    );
    final addParticipant2 = _powerSyncRepository.db().execute(
      '''
insert into
  participants (id, user_id, conversation_id)
  values
  (?, ?, ?)
  ''',
      [uuid.v4(), participantId, conversationId],
    );
    await createdConversation.whenComplete(
      () => Future.wait([addParticipant1, addParticipant2]),
    );
  }

  @override
  Future<void> deleteChat({
    required String chatId,
    required String userId,
  }) async {
    //     final participants = (await _powerSyncRepository.db().get(
    //       '''
    // select
    //   count(*) as participants_count
    // from
    //   participants
    // where conversation_id = ?
    // ''',
    //       [chatId],
    //     ))['participants_count'] as int;
    //     if (participants >= 1) {
    //       final isParticipantInConversation = await _powerSyncRepository.db()
    // .get(
    //         '''
    // select
    //   *
    // from
    //   participants
    // where
    //   user_id = ?
    //   and conversation_id = ?
    //   ''',
    //         [userId, chatId],
    //       );
    //       if (isParticipantInConversation.isEmpty) return;
    //       await _powerSyncRepository.db().execute(
    //         '''
    // delete from participants
    // where
    //   user_id = ?
    //   and conversation_id = ?
    // ''',
    //         [userId, chatId],
    //       );
    //       return;
    //     }
    await _powerSyncRepository.db().execute(
      '''
delete from conversations
where
  id = ?
''',
      [chatId],
    );
  }

  @override
  Future<void> deleteMessage({required String messageId}) =>
      _powerSyncRepository.db().execute(
        '''
delete from messages
where
  id = ?
''',
        [messageId],
      );

  @override
  Future<void> readMessage({
    required String messageId,
  }) async {
    await _powerSyncRepository.db().execute(
      '''
UPDATE messages
SET
  is_read = 1
WHERE
  id = ?
''',
      [messageId],
    );
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required User sender,
    required User receiver,
    required Message message,
    PostAuthor? postAuthor,
  }) => _powerSyncRepository.db().writeTransaction((sqlContext) async {
    await sqlContext.execute(
      '''
insert into
  messages (
    id, conversation_id, from_id, type, message, reply_message_id, created_at, 
    updated_at, is_read, is_deleted, is_edited, reply_message_username,
    reply_message_attachment_url, shared_post_id, reply_message_message, from_username
    )
values
  (?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, ?, ?, ?, ?, ?)
''',
      [
        message.id,
        chatId,
        sender.id,
        message.type.value,
        message.message,
        message.replyMessageId,
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
        message.replyMessageUsername,
        message.replyMessageAttachmentUrl,
        message.sharedPostId,
        message.replyMessageMessage,
        sender.username,
      ],
    );

    if (message.attachments.isNotEmpty) {
      await sqlContext.executeBatch(
        '''
insert into
  attachments (
    id, message_id, title, text, title_link, image_url,
    thumb_url, author_name, author_link, asset_url, og_scrape_url, type
  )
values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
        message.attachments
            .map(
              (a) => [
                a.id,
                message.id,
                a.title,
                a.text,
                a.titleLink,
                a.imageUrl,
                a.thumbUrl,
                a.authorName,
                a.authorLink,
                a.assetUrl,
                a.ogScrapeUrl,
                a.type,
              ],
            )
            .toList(),
      );
    }
  });

  @override
  Future<void> editMessage({
    required Message oldMessage,
    required Message newMessage,
  }) async {
    late final newMessageHasAttachments = newMessage.attachments.isNotEmpty;
    late final oldMessageHasAttachments = oldMessage.attachments.isNotEmpty;
    late final updateOldMessageAttachments =
        newMessageHasAttachments && oldMessageHasAttachments;
    late final insertNewMessageAttachments =
        newMessageHasAttachments && !oldMessageHasAttachments;

    await _powerSyncRepository.db().execute(
      '''
update messages
set
  message = ?1,
  updated_at = ?2,
  is_edited = 1
where
  id = ?3
''',
      [
        newMessage.message,
        DateTime.timestamp().toIso8601String(),
        newMessage.id,
      ],
    );
    if (!newMessageHasAttachments && oldMessageHasAttachments) {
      await _powerSyncRepository.db().execute(
        '''
delete from attachments
where message_id = ?
        ''',
        [newMessage.id],
      );
      return;
    }
    if (updateOldMessageAttachments) {
      final oldAttachmentId = oldMessage.attachments.first.id;
      await _powerSyncRepository.db().executeBatch(
        '''
update attachments
set
  title = ?,
  text = ?,
  title_link = ?,
  image_url = ?,
  thumb_url = ?,
  author_name = ?,
  author_link = ?,
  asset_url = ?,
  og_scrape_url = ?
where
  id = ?
  and message_id = ?
''',
        newMessage.attachments
            .map(
              (a) => [
                a.title,
                a.text,
                a.titleLink,
                a.imageUrl,
                a.thumbUrl,
                a.authorName,
                a.authorLink,
                a.assetUrl,
                a.ogScrapeUrl,
                oldAttachmentId,
                oldMessage.id,
              ],
            )
            .toList(),
      );
      return;
    }
    if (insertNewMessageAttachments) {
      await _powerSyncRepository.db().executeBatch(
        '''
insert into
  attachments (
    id, message_id, title, text, title_link, image_url,
    thumb_url, author_name, author_link, asset_url, og_scrape_url, type
  )
values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
        newMessage.attachments
            .map(
              (a) => [
                a.id,
                newMessage.id,
                a.title,
                a.text,
                a.titleLink,
                a.imageUrl,
                a.thumbUrl,
                a.authorName,
                a.authorLink,
                a.assetUrl,
                a.ogScrapeUrl,
                a.type,
              ],
            )
            .toList(),
      );
    }
  }

  @override
  Future<List<User>> searchUsers({
    required int limit,
    required int offset,
    required String? query,
    String? userId,
    String? excludeUserIds,
  }) async {
    if (query == null || query.trim().isEmpty) return <User>[];
    query = query.removeSpecialCharacters();
    final sanitizedExcludeIds = excludeUserIds == null
        ? ''
        : 'AND id NOT IN (${excludeUserIds.replaceAll(RegExp(r'[^0-9a-fA-F,-]'), '')})';

    final result = await _powerSyncRepository.db().getAll(
      '''
SELECT id, avatar_url, full_name, username
  FROM profiles
WHERE (LOWER(username) LIKE LOWER('%$query%') OR LOWER(full_name) LIKE LOWER('%$query%'))
  AND id <> ?1 $sanitizedExcludeIds 
LIMIT ?2 OFFSET ?3
''',
      [currentUserId, limit, offset],
    );

    return result.safeMap(User.fromJson).toList(growable: false);
  }

  @override
  Future<void> createStory({
    required User author,
    required StoryContentType contentType,
    required String contentUrl,
    String? id,
    int? duration,
  }) => _powerSyncRepository.db().execute(
    '''
insert into stories (id, user_id, content_type, content_url, duration, created_at, expires_at)
values (?, ?, ?, ?, ?, ?, ?)
''',
    [
      id ?? uuid.v4(),
      author.id,
      contentType.toJson(),
      contentUrl,
      duration,
      DateTime.timestamp().toIso8601String(),
      DateTime.timestamp().add(1.days).toIso8601String(),
    ],
  );

  @override
  Future<void> deleteStory({required String id}) =>
      _powerSyncRepository.db().execute(
        '''
DELETE FROM stories WHERE id = ?
''',
        [id],
      );

  @override
  Stream<List<Story>> getStories({
    required String userId,
    bool includeAuthor = true,
  }) => _powerSyncRepository
      .db()
      .watch(
        '''
SELECT 
  s.*${includeAuthor ? ', p.id as user_id, p.username, p.full_name, p.avatar_url' : ''}
FROM stories s
  ${includeAuthor ? 'LEFT JOIN profiles p ON s.user_id = p.id' : ''}
WHERE user_id = ? AND expires_at > current_timestamp
''',
        parameters: [userId],
      )
      .map((event) => event.safeMap(Story.fromJson).toList(growable: false));

  @override
  Future<String> uploadStoryMedia({
    required String storyId,
    required String fileName,
    required Uint8List imageBytes,
  }) async {
    final stories = _powerSyncRepository.supabase.storage.from('stories');
    final imageExtension = fileName.split('.').last.toLowerCase();
    final imagePath = '$storyId/image';

    await stories.uploadBinary(
      imagePath,
      imageBytes,
      fileOptions: FileOptions(
        contentType: 'image/$imageExtension',
        cacheControl: '9000000',
      ),
    );
    return stories.getPublicUrl(imagePath);
  }

  @override
  Future<List<User>> getPostLikers({
    required String postId,
    int limit = 30,
    int offset = 0,
  }) async {
    final result = await _powerSyncRepository.db().getAll(
      '''
SELECT up.id, up.username, up.full_name, up.avatar_url
FROM profiles up
INNER JOIN likes l ON up.id = l.user_id
INNER JOIN posts p ON l.post_id = p.id
WHERE p.post_id = ?1
LIMIT ? OFFSET ?
''',
      [postId, limit, offset],
    );
    if (result.isEmpty) return [];
    return result.safeMap(User.fromJson).toList(growable: false);
  }

  @override
  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  }) async {
    final result = await _powerSyncRepository.db().getAll(
      '''
SELECT id, avatar_url, username, full_name
FROM profiles
WHERE id IN (
    SELECT l.user_id
    FROM likes l
    WHERE l.post_id = ?1
    AND EXISTS (
        SELECT *
        FROM subscriptions f
        WHERE f.subscribed_to_id = l.user_Id
        AND f.subscriber_id = ?2
    ) AND id <> ?2
)
LIMIT ?3 OFFSET ?4
''',
      [postId, currentUserId, limit, offset],
    );
    if (result.isEmpty) return [];
    return result.safeMap(User.fromJson).toList(growable: false);
  }

  @override
  Future<List<Message>> getMessages({
    required String chatId,
    required int limit,
    required int offset,
  }) async {
    final result = await _powerSyncRepository.db().getAll(
      '''
SELECT
  m.*,
  m_sender.full_name as full_name,
  m_sender.username as username,
  m_sender.avatar_url as avatar_url,
  a.id as attachment_id,
  a.title as attachment_title,
  a.text as attachment_text,
  a.title_link as attachment_title_link,
  a.image_url as attachment_image_url,
  a.thumb_url as attachment_thumb_url,
  a.author_name as attachment_author_name,
  a.author_link as attachment_author_link,
  a.asset_url as attachment_asset_url,
  a.og_scrape_url as attachment_og_scrape_url,
  a.type as attachment_type,
  p.caption as shared_post_caption,
  p.created_at as shared_post_created_at,
  p.media as shared_post_media,
  p_author.id as shared_post_author_id,
  p_author.username as shared_post_author_username,
  p_author.full_name as shared_post_author_full_name,
  p_author.avatar_url as shared_post_author_avatar_url
FROM
  messages m
  left join attachments a on m.id = a.message_id
  left join posts p on m.shared_post_id = p.id
  join profiles m_sender on m.from_id = m_sender.id
  left join profiles p_author on p.user_id = p_author.id
WHERE m.conversation_id = ?1   
ORDER BY created_at DESC
LIMIT ?2 OFFSET ?3
''',
      [chatId, limit, offset],
    );
    final messages = <Message>[];
    if (result.isEmpty) return messages;
    final listMediaJson = result
        .map((e) => e['shared_post_media'] as String?)
        .toList();
    if (listMediaJson.isEmpty ||
        !listMediaJson.any((element) => element != null)) {
      return result.safeMap(Message.fromRow).toList(growable: false);
    }
    final resultMedia = await compute(
      _computeJsonListMedia,
      [RootIsolateToken.instance!, listMediaJson],
    );
    for (var i = 0; i < result.length; i++) {
      final json = Map<String, dynamic>.from(result[i]);
      final indexedMedia = resultMedia[i];

      Message message;
      if (indexedMedia == <Map<String, dynamic>>[]) {
        message = Message.fromRow(json);
      } else {
        final media = indexedMedia.map(Media.fromJson).toList();
        message = Message.fromRow(json, media: media);
      }
      messages.add(message);
    }
    return messages;
  }

  @override
  Future<Message> getRepliedMessage({required String messageId}) async {
    final result = await _powerSyncRepository.db().get(
      '''
SELECT message from messages
WHERE id = ?
''',
      [messageId],
    );
    return Message(message: result['message'] as String);
  }

  @override
  Future<List<User>> getAllUsers({
    required int limit,
    required int offset,
  }) async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response.safeMap(User.fromJson).toList(growable: false);
  }

  @override
  Future<void> addFollower({
    required String userId,
    required String followerId,
  }) async {
    final exists = await Supabase.instance.client
        .from('subscriptions')
        .select()
        .eq('subscriber_id', followerId)
        .eq('subscribed_to_id', userId)
        .maybeSingle();

    if (exists == null) {
      await Supabase.instance.client.from('subscriptions').insert({
        'id': uuid.v4(),
        'subscriber_id': followerId,
        'subscribed_to_id': userId,
        'created_at': DateTime.timestamp().toIso8601String(),
      });
    }
  }

  @override
  Future<List<Post>> getAllPosts({
    required int limit,
    required int offset,
    bool onlyReels = false,
  }) async {
    final query = Supabase.instance.client.from('posts').select();

    if (onlyReels) {
      query.eq('is_reel', true);
    }

    final response = await query.order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response.safeMap((row) => Post.fromJson(
      row as Map<String, dynamic>,
      media: [],
    )).toList(growable: false);
  }

  @override
  Future<List<Message>> getAllMessages({
    required int limit,
    required int offset,
  }) async {
    final response = await Supabase.instance.client
        .from('messages')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response.safeMap(Message.fromJson).toList(growable: false);
  }

  @override
  Future<void> deleteUser({required String id}) async {
    await Supabase.instance.client.auth.admin.deleteUser(id);
    await Supabase.instance.client.from('profiles').delete().eq('id', id);
  }

  @override
  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      await Supabase.instance.client.auth.admin.updateUserById(
        userId,
        attributes: AdminUserAttributes(appMetadata: {'role': role}),
      );
    } catch (e) {
      // Fallback: update via Supabase tables for environments without admin API
      await Supabase.instance.client
          .from('user_roles')
          .upsert({'user_id': userId, 'role': role});
      await Supabase.instance.client
          .from('profiles')
          .update({'role': role})
          .eq('id', userId);
    }
  }

  @override
  Future<void> suspendUser({
    required String userId,
    required bool suspended,
    String? reason,
  }) async {
    await Supabase.instance.client
        .from('profiles')
        .update({'suspended': suspended, 'suspension_reason': reason})
        .eq('id', userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllConversations({
    required int limit,
    required int offset,
  }) async {
    final response = await Supabase.instance.client
        .from('conversations')
        .select('*, participants!inner(*)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response as List<Map<String, dynamic>>;
  }

  @override
  Future<void> createCustomUser({
    required String username,
    required String password,
    required String displayName,
    int followerCount = 0,
    int followingCount = 0,
  }) async {
    final auth = Supabase.instance.client.auth;

    // Save admin session before creating the new user
    final adminSession = auth.currentSession;

    try {
      // Create auth user
      final signUpRes = await auth.signUp(
        email: '$username@custom.admin',
        password: password,
        data: {'username': username, 'full_name': displayName},
      );

      final userId = signUpRes.user?.id;
      if (userId == null) throw Exception('Failed to create auth user');

      // Insert profile with faker follower/following counts
      await Supabase.instance.client.from('profiles').insert({
        'id': userId,
        'username': username,
        'full_name': displayName,
        'fake_follower_count': followerCount,
        'fake_following_count': followingCount,
      });
    } finally {
      // Restore admin session
      if (adminSession != null) {
        await auth.setSession(adminSession.accessToken);
      }
    }
  }

  @override
  Future<void> setImpersonatedUserId(String userId) async {
    _impersonatedUserId = userId;
    // Persist to SharedPreferences or in-memory
    // The auth client will use this ID for queries instead of the real admin ID
  }

  @override
  Future<void> stopImpersonation() async {
    _impersonatedUserId = null;
  }

  String? _impersonatedUserId;

  @override
  Future<List<Message>> getConversationMessages({
    required String conversationId,
    required int limit,
    required int offset,
  }) async {
    final response = await Supabase.instance.client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .range(offset, offset + limit - 1);

    return response.safeMap(Message.fromJson).toList(growable: false);
  }

  @override
  Future<void> logAdminAction({
    required String adminId,
    required String action,
    required String targetType,
    required String targetId,
    String? details,
  }) async {
    await Supabase.instance.client.from('admin_audit_logs').insert({
      'admin_id': adminId,
      'action': action,
      'target_type': targetType,
      'target_id': targetId,
      'details': details,
      'created_at': DateTime.timestamp().toIso8601String(),
    });
  }

  @override
  Future<Map<String, dynamic>> getPostsStats() async {
    final result = <String, dynamic>{};

    final postCount = await Supabase.instance.client
        .from('posts')
        .count();
    result['total_posts'] = postCount;

    final reelsCount = await Supabase.instance.client
        .from('posts')
        .select()
        .eq('is_reel', true)
        .count();
    result['reels_count'] = reelsCount;

    final avgLikesSnapshot = await Supabase.instance.client
        .rpc('get_average_likes');
    result['average_likes'] = avgLikesSnapshot.first['avg_likes'] ?? 0;

    return result;
  }

  @override
  Future<void> approvePost({required String postId}) async {
    await Supabase.instance.client
        .from('posts')
        .update({'is_approved': true})
        .eq('id', postId);
  }

  @override
  Future<void> rejectPost({required String postId, String? reason}) async {
    await Supabase.instance.client
        .from('posts')
        .update({
          'is_approved': false,
          'rejection_reason': reason,
        })
        .eq('id', postId);
  }

  @override
  Future<List<Post>> getPendingPosts({required int limit, required int offset}) async {
    final rows = await Supabase.instance.client
        .from('posts')
        .select()
        .eq('is_approved', false)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final posts = <Post>[];
    for (final row in rows) {
      final mediaRows = await Supabase.instance.client
          .from('post_media')
          .select()
          .eq('post_id', row['id'] as String);
      final mediaList =
          (mediaRows as List).map((m) => Media.fromJson(m as Map<String, dynamic>)).toList();
      posts.add(Post.fromJson(row as Map<String, dynamic>, media: mediaList));
    }
    return posts;
  }

  @override
  Future<void> setAutoApprove({required bool enabled}) async {
    await Supabase.instance.client
        .from('admin_settings')
        .upsert({'key': 'auto_approve_posts', 'value': enabled.toString()})
        .select();
  }
}

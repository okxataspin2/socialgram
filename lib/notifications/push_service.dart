import 'package:shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:user_repository/user_repository.dart';

/// Sends push notifications through the `send-notification` Supabase Edge
/// Function. The FCM service account private key lives only server-side.
/// All sends are best-effort and must never block the caller.
class PushService {
  /// Notifies [receiver] that [sender] sent [message] in [chatId].
  static Future<void> notifyNewMessage({
    required User receiver,
    required User sender,
    required String chatId,
    required Message message,
  }) async {
    final token = receiver.pushToken;
    if (token == null || token.isEmpty) return;

    final body = switch (message.type) {
      MessageType.image => '📷 Photo',
      MessageType.video => '🎥 Video',
      MessageType.voice => '🎤 Voice message',
      MessageType.text =>
        message.message.isEmpty ? 'Sent you a message' : message.message,
    };

    try {
      await Supabase.instance.client.functions.invoke(
        'send-notification',
        body: {
          'token': token,
          'title': sender.displayUsername,
          'body': body,
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'chat_id': chatId,
          },
        },
      );
    } catch (_) {
      // Push is best-effort; a failed notification must not break messaging.
    }
  }
}

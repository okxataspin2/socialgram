import 'dart:typed_data';

import 'package:cross_file/cross_file.dart' show XFile;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// {@template voice_message_service}
/// Service for recording and managing voice messages.
/// {@endtemplate}
class VoiceMessageService {
  /// {@macro voice_message_service}
  VoiceMessageService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _recordingPath;

  /// Checks and requests microphone permission.
  Future<bool> requestPermission() => _recorder.hasPermission();

  /// Starts recording an audio message.
  Future<void> startRecording() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _recordingPath = '${directory.path}/voice_$timestamp.m4a';

    await _recorder.start(
      const RecordConfig(),
      path: _recordingPath!,
    );
  }

  /// Stops recording and returns the file path.
  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    _recordingPath = null;
    return path;
  }

  /// Uploads a voice message file to Supabase Storage and returns its storage
  /// **path** (not a public URL). The path is what gets stored in the
  /// `messages` table; a short-lived signed URL is generated only at playback.
  Future<String> uploadVoiceMessage({
    required String chatId,
    required String fileName,
    required String path,
  }) async {
    final storage = Supabase.instance.client.storage.from('messages');
    final storagePath = '$chatId/$fileName';

    final Uint8List bytes;
    if (kIsWeb) {
      final response = await http.get(Uri.parse(path));
      bytes = response.bodyBytes;
    } else {
      bytes = await XFile(path).readAsBytes();
    }
    await storage.uploadBinary(
      storagePath,
      bytes,
      fileOptions: const FileOptions(
        contentType: 'audio/mp4',
        cacheControl: '9000000',
        upsert: true,
      ),
    );

    return storagePath;
  }

  /// Resolves a stored voice message reference to a short-lived URL suitable
  /// for playback.
  ///
  /// Accepts:
  ///  * a storage path (e.g. `chatId/voice_xxx.m4a`) - the new format,
  ///  * a legacy public URL (e.g. `.../object/public/messages/chatId/...`) -
  ///    auto-migrated to a signed URL.
  ///
  /// Returns null if the reference cannot be resolved.
  static Future<String?> getSignedUrl(
    String pathOrUrl, {
    int expiresIn = 600,
  }) async {
    final path = _toStoragePath(pathOrUrl);
    if (path == null) return null;

    final storage = Supabase.instance.client.storage.from('messages');
    return storage.createSignedUrl(path, expiresIn);
  }

  /// Normalizes a stored reference into a storage-relative path (no leading
  /// slash, no base URL). Returns null when it is not a `messages` object.
  static String? _toStoragePath(String pathOrUrl) {
    if (pathOrUrl.contains('/object/public/messages/')) {
      return pathOrUrl
          .split('/object/public/messages/')
          .last
          .replaceFirst(RegExp('^/'), '');
    }

    final noLeadingSlash = pathOrUrl.replaceFirst(RegExp('^/'), '');

    if (noLeadingSlash.startsWith('messages/')) {
      return noLeadingSlash.replaceFirst('messages/', '');
    }

    // Plain path like `chatId/voice_xxx.m4a`.
    if (!noLeadingSlash.contains('://')) {
      return noLeadingSlash;
    }

    return null;
  }

  /// Disposes the recorder.
  Future<void> dispose() async {
    await _recorder.dispose();
  }
}

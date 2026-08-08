import 'dart:async';
import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/bloc/chat_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/services/voice_message_service.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

/// {@template voice_recorder_widget}
/// A widget that provides voice recording functionality for chat.
/// {@endtemplate}
class VoiceRecorderWidget extends StatefulWidget {
  /// {@macro voice_recorder_widget}
  const VoiceRecorderWidget({
    required this.chatId,
    required this.receiver,
    super.key,
  });

  /// The ID of the chat conversation.
  final String chatId;

  /// The receiver of the voice message.
  final User receiver;

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  late VoiceMessageService _voiceService;
  late AnimationController _recordAnimation;
  bool _isRecording = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceMessageService();
    _recordAnimation = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _voiceService.dispose();
    _recordAnimation.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      await _voiceService.startRecording();
      setState(() => _isRecording = true);
      unawaited(_recordAnimation.repeat(reverse: true));
    } catch (error, stackTrace) {
      logE(
        'Failed to start recording',
        error: error,
        stackTrace: stackTrace,
      );

      if (!mounted) return;
      openSnackbar(
        const SnackbarMessage.error(
          title: 'Recording failed',
          description: 'Please check microphone permissions',
        ),
      );
    }
  }

  Future<void> _stopAndSend() async {
    if (!_isRecording) return;

    setState(() {
      _isRecording = false;
      _isSending = true;
    });
    _recordAnimation.stop();

    try {
      final path = await _voiceService.stopRecording();
      if (path == null) {
        throw Exception('No recording found');
      }

      final file = File(path);
      final fileName = 'voice_${uuid.v4()}.m4a';

      toggleLoadingIndeterminate();

      final voiceUrl = await _voiceService.uploadVoiceMessage(
        chatId: widget.chatId,
        fileName: fileName,
        file: file,
      );

      if (!mounted) return;
      final user = context.read<AppBloc>().state.user;
      final message = Message(
        type: MessageType.voice,
        message: voiceUrl,
        sender: PostAuthor(
          id: user.id,
          username: user.username ?? '',
          avatarUrl: user.avatarUrl ?? '',
        ),
      );

      if (!mounted) return;
      context.read<ChatBloc>().add(
            ChatSendMessageRequested(
              message: message,
              receiver: widget.receiver,
              sender: user,
            ),
          );

      toggleLoadingIndeterminate(enable: false);
      if (!mounted) return;
      openSnackbar(
        const SnackbarMessage.success(
          title: 'Voice message sent',
        ),
      );
    } catch (error, stackTrace) {
      logE(
        'Failed to send voice message',
        error: error,
        stackTrace: stackTrace,
      );
      toggleLoadingIndeterminate(enable: false);
      if (!mounted) return;
      openSnackbar(
        SnackbarMessage.error(
          title: 'Failed to send message',
          description: error.toString(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isSending
        ? const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.blue,
            ),
          )
        : Tappable.faded(
            onTap: _isRecording ? _stopAndSend : _startRecording,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _isRecording ? AppColors.red : AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: AnimatedBuilder(
                animation: _recordAnimation,
                builder: (context, child) {
                  final scale =
                      _isRecording ? 1 + (_recordAnimation.value * 0.2) : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: AppColors.white,
                      size: AppSize.iconSize,
                    ),
                  );
                },
              ),
            ),
          );
  }
}

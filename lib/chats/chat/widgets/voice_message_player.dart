import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/services/voice_message_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared/shared.dart';

/// {@template voice_message_player}
/// A widget that displays and plays voice messages.
/// {@endtemplate}
class VoiceMessagePlayer extends StatefulWidget {
  /// {@macro voice_message_player}
  const VoiceMessagePlayer({
    required this.voiceUrl,
    required this.isMine,
    this.duration,
    super.key,
  });

  /// The URL of the voice message.
  final String voiceUrl;

  /// Whether this message belongs to the current user.
  final bool isMine;

  /// The duration of the voice message in seconds (optional, for display).
  final int? duration;

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  late AudioPlayer _audioPlayer;
  int _position = 0;
  int _duration = 1;
  bool _isPlaying = false;
  bool _isLoading = true;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _subscriptions
      ..add(
        _audioPlayer.processingStateStream.listen((state) {
          if (!mounted) return;
          if (state == ProcessingState.loading ||
              state == ProcessingState.buffering) {
            setState(() => _isLoading = true);
          } else if (state == ProcessingState.idle ||
              state == ProcessingState.completed) {
            setState(() {
              _isLoading = false;
              _isPlaying = false;
            });
            if (state == ProcessingState.completed) {
              _audioPlayer.seek(Duration.zero);
            }
          } else {
            setState(() => _isLoading = false);
          }
        }),
      )
      ..add(
        _audioPlayer.positionStream.listen((position) {
          if (!mounted) return;
          setState(() {
            _position = position.inMicroseconds;
            _duration = _audioPlayer.duration?.inMicroseconds ?? 1;
            if (_duration <= 0) _duration = 1;
          });
        }),
      )
      ..add(
        _audioPlayer.playerStateStream.listen((playerState) {
          if (mounted) {
            setState(() => _isPlaying = playerState.playing);
          }
        }),
      );

    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // Voice messages are stored as private storage paths; resolve a
      // short-lived signed URL right before playback.
      final url =
          await VoiceMessageService.getSignedUrl(widget.voiceUrl) ??
          widget.voiceUrl;

      await _audioPlayer.setUrl(url);
      setState(() {});
    } catch (error, stackTrace) {
      logE(
        'Failed to load voice message',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_audioPlayer.processingState == ProcessingState.idle ||
          _audioPlayer.processingState == ProcessingState.completed) {
        await _initAudio();
      }
      await _audioPlayer.play();
    }
  }

  String _formatDuration() {
    final duration =
        _audioPlayer.duration ?? Duration(seconds: widget.duration ?? 0);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration > 0 ? _position / _duration : 0.0;
    final effectiveTextColor = widget.isMine
        ? AppColors.white
        : AppColors.black;

    return Row(
      children: [
        Tappable.faded(
          onTap: _isLoading ? null : _togglePlayPause,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isMine
                  ? AppColors.white.withValues(alpha: 0.2)
                  : AppColors.black.withValues(alpha: 0.1),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Icon(
                    _isPlaying ? Icons.stop : Icons.play_arrow,
                    color: effectiveTextColor,
                    size: 24,
                  ),
          ),
        ),
        const Gap.h(AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: widget.isMine
                    ? AppColors.white.withValues(alpha: 0.2)
                    : AppColors.grey.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.isMine ? AppColors.white : AppColors.blue,
                ),
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
              ),
              const Gap.v(AppSpacing.xxs),
              Text(
                _formatDuration(),
                style: context.bodySmall?.apply(
                  color: widget.isMine ? AppColors.white : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

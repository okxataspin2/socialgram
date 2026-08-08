import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/call/services/zego_service.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

/// Call screen backed by the ZEGOCLOUD prebuilt call UI kit. Handles the full
/// 1-on-1 voice/video call lifecycle (ringing, connected, hang up).
class CallScreen extends StatefulWidget {
  const CallScreen({
    required this.chatId,
    required this.currentUserId,
    required this.currentUserName,
    required this.isVideo,
    super.key,
  });

  /// Used as the ZEGOCLOUD call ID so both users join the same call room.
  final String chatId;
  final String currentUserId;
  final String currentUserName;
  final bool isVideo;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  ZegoUIKitPrebuiltCall? _call;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() {
    if (!ZegoVideoService.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Video calls are not configured. Please add your ZEGOCLOUD '
            'credentials in the .env files.',
          ),
        ),
      );
      return;
    }

    _call = ZegoVideoService.createCallPage(
      callId: widget.chatId,
      userId: widget.currentUserId,
      userName: widget.currentUserName,
      isVideoCall: widget.isVideo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final call = _call;
    if (call == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            call,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_instagram_offline_first_clone/app/routes/app_router.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

/// Wraps the ZEGOCLOUD prebuilt call UI kit for 1-on-1 voice/video calls.
class ZegoVideoService {
  static int _appId = 0;
  static String _appSign = '';

  /// Stores the ZEGOCLOUD credentials. Call once during app bootstrap with
  /// values resolved from the ZEGO_APP_ID / ZEGO_APP_SIGN env variables.
  static void configure({required int appId, required String appSign}) {
    _appId = appId;
    _appSign = appSign;
  }

  /// Initializes the call invitation service so the current user can receive
  /// incoming call invitations. Must be called after the user logs in.
  static Future<void> init({
    required String userId,
    required String userName,
  }) async {
    if (_appId == 0 || _appSign.isEmpty) return;

    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(rootNavigatorKey);

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: _appId,
      appSign: _appSign,
      userID: userId,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
    );
  }

  /// De-initializes the call invitation service. Call on user logout.
  static Future<void> uninit() async {
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
  }

  /// Whether the ZEGOCLOUD credentials have been configured.
  static bool get isConfigured => _appId != 0 && _appSign.isNotEmpty;

  /// Builds the prebuilt call page for a 1-on-1 voice or video call.
  static ZegoUIKitPrebuiltCall createCallPage({
    required String callId,
    required String userId,
    required String userName,
    required bool isVideoCall,
  }) {
    final config = ZegoUIKitPrebuiltCallConfigExtension.generate(
      isGroup: false,
      isVideo: isVideoCall,
    );

    return ZegoUIKitPrebuiltCall(
      appID: _appId,
      appSign: _appSign,
      callID: callId,
      userID: userId,
      userName: userName,
      config: config,
    );
  }
}

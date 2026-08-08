import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:video_player/video_player.dart';

/// Native (Android/iOS) local video playback.
Future<VideoPlayerController> controllerForVideoFile(
  dynamic file, {
  dynamic videoPlayerOptions,
}) =>
    Future.value(
      VideoPlayerController.file(
        File((file as XFile).path),
        videoPlayerOptions: videoPlayerOptions as VideoPlayerOptions?,
      ),
    );

import 'package:cross_file/cross_file.dart';
import 'package:video_player/video_player.dart';

/// Web local video playback via an object URL.
Future<VideoPlayerController> controllerForVideoFile(
  dynamic file, {
  dynamic videoPlayerOptions,
}) async {
  final url = await (file as XFile).createObjectUrl();
  return VideoPlayerController.networkUrl(
    Uri.parse(url),
    videoPlayerOptions: videoPlayerOptions as VideoPlayerOptions?,
  );
}

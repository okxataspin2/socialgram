import 'dart:js_interop';

import 'package:cross_file/cross_file.dart';
import 'package:video_player/video_player.dart';
import 'package:web/web.dart' as web;

/// Web local video playback via a blob object URL.
Future<VideoPlayerController> controllerForVideoFile(
  dynamic file, {
  dynamic videoPlayerOptions,
}) async {
  final bytes = await (file as XFile).readAsBytes();
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'video/mp4'),
  );
  final url = web.URL.createObjectURL(blob);
  return VideoPlayerController.networkUrl(
    Uri.parse(url),
    videoPlayerOptions: videoPlayerOptions as VideoPlayerOptions?,
  );
}

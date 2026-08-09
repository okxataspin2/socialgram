/// Platform-neutral facade for video helpers (compress + thumbnail).
///
/// Native implementation lives in `video_plus_io.dart`; web runs real FFmpeg
/// (`video_plus_web.dart`) compressed with [VideoCompress.compressVideo] and
/// captures first frames via canvas.
library;

import 'dart:typed_data';

import 'video_plus_io.dart' if (dart.library.html) 'video_plus_web.dart'
    as impl;

export 'video_plus_io.dart' if (dart.library.html) 'video_plus_web.dart';

/// Video processing helpers.
class VideoPlus {
  const VideoPlus._();

  static Future<Uint8List?> getVideoThumbnail(Object file) =>
      impl.VideoPlus.getVideoThumbnail(file);

  static Future<Uint8List?> compressVideo(Object file) =>
      impl.VideoPlus.compressVideo(file);
}

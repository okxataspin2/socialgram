/// Platform-neutral facade for video helpers (compress + thumbnail).
///
/// Native implementation lives in `video_plus_io.dart`; web is a no-op stub
/// (`video_plus_web.dart`). Official video editing is not supported in the
/// browser build yet.
library;

import 'video_plus_io.dart' if (dart.library.html) 'video_plus_web.dart'
    as impl;

export 'video_plus_io.dart' if (dart.library.html) 'video_plus_web.dart';

/// Video processing helpers.
class VideoPlus {
  const VideoPlus._();

  static Future<Uint8List?> getVideoThumbnail(dynamic file) =>
      impl.getVideoThumbnail(file);

  static Future<dynamic> compressVideo(dynamic file) => impl.compressVideo(file);
}

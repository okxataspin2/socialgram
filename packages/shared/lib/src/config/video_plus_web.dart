// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

/// Web stub for [VideoPlus] - video compression/thumbnails are not supported
/// in the browser (they require native codecs).
class VideoPlus {
  const VideoPlus._();

  static Future<Uint8List?> getVideoThumbnail(Object file) async => null;

  static Future<Object?> compressVideo(Object file) async => null;
}

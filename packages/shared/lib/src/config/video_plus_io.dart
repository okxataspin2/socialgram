import 'dart:io';
import 'dart:typed_data';

import 'package:video_compress/video_compress.dart';

/// {@template video_thumbnail_plus}
/// A package that manages video thumbnail.
/// {@endtemplate}
class VideoPlus {
  const VideoPlus._();

  /// Returns a [Uint8List] containing the thumbnail of the video.
  static Future<Uint8List?> getVideoThumbnail(Object video) =>
      VideoCompress.getByteThumbnail((video as File).path);

  /// Compresses the video and returns the compressed bytes.
  static Future<Uint8List?> compressVideo(Object video) async {
    await VideoCompress.setLogLevel(0);

    final compressed = await VideoCompress.compressVideo(
      (video as File).path,
      includeAudio: true,
    );
    return compressed?.file?.readAsBytes();
  }
}

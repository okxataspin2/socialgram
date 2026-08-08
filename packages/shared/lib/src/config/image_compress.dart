// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cross_file/cross_file.dart';

import 'picked_media.dart';

/// Platform-neutral image compression.
///
/// IMPORTANT: this file never imports `dart:io`, so it compiles for web.
/// The native compression path uses [XFile.path], the web path compresses
/// in-memory bytes.
class ImageCompress {
  const ImageCompress._();

  /// Compresses image bytes (web-safe).
  static Future<Uint8List> compressByte(Uint8List file) async {
    if (file.lengthInBytes > 200000) {
      final result = await FlutterImageCompress.compressWithList(
        file,
        quality: file.lengthInBytes > 4000000 ? 90 : 72,
      );
      return result;
    } else {
      return file;
    }
  }

  /// Compresses an image file. Works both on native and web.
  static Future<XFile?> compressFile(XFile file) async {
    final filePath = file.path;
    final lastIndex = filePath.lastIndexOf(RegExp('.png|.jp'));

    if (kIsWeb) {
      final bytes = await compressByte(await file.readAsBytes());
      return XFile.fromData(bytes, name: file.name);
    }

    if (lastIndex == -1) return null;
    final splitted = filePath.substring(0, lastIndex);
    final outPath = '${splitted}_out${filePath.substring(lastIndex)}';

    if (filePath.endsWith('.png')) {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        minWidth: 1000,
        minHeight: 1000,
        quality: 50,
        format: CompressFormat.png,
      );
      return compressedImage;
    } else {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        minWidth: 1000,
        minHeight: 1000,
        quality: 50,
      );
      return compressedImage;
    }
  }

  /// Applies default compression to picked media when possible.
  static Future<PickedMedia> compressMedia(PickedMedia media) async {
    final compressed = await compressFile(media.file);
    if (compressed == null) return media;
    return PickedMedia(
      file: compressed,
      bytes: kIsWeb ? await compressed.readAsBytes() : null,
    );
  }
}
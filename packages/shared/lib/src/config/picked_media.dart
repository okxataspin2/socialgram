// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

/// A media file picked by the user, together with its bytes when the
/// platform provides them eagerly (e.g. web uploads).
///
/// Platform-neutral contract used by [PickImage]. Native implementations wrap
/// the device gallery/camera pickers; the web implementation uses file_picker.
class PickedMedia {
  const PickedMedia({required this.file, this.bytes});

  final XFile file;
  final Uint8List? bytes;

  String get fileName => file.name;

  bool get isVideo {
    final name = file.name.toLowerCase();
    return name.endsWith('.mp4') ||
        name.endsWith('.m4v') ||
        name.endsWith('.mov') ||
        name.endsWith('.webm');
  }

  bool get isImage => !isVideo;

  /// The best available byte content for this media.
  Future<Uint8List> readBytes() async => bytes ?? await file.readAsBytes();
}

/// Platform-neutral picker source.
enum PickedMediaSource { both, gallery, camera }

/// Platform-neutral picker configuration.
class PickedMediaFilter {
  const PickedMediaFilter({
    this.allowVideo = true,
    this.maxDurationSeconds = 180,
  });

  final bool allowVideo;
  final int maxDurationSeconds;
}
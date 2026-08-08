// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';

import 'image_picker_io.dart' if (dart.library.html) 'image_picker_web.dart'
    as impl;
import 'picked_media.dart';

export 'picked_media.dart';

/// Unified media picker.
///
/// On native platforms this wraps the device gallery/camera picker
/// (`image_picker_plus`); on web it uses `file_picker`. Returns platform
/// neutral [PickedMedia] results so the rest of the app is platform agnostic.
class PickImage {
  factory PickImage() => _internal;

  PickImage._();

  static final PickImage _internal = PickImage._();

  final impl.PickerPlatform _platform = impl.buildPickerPlatform();

  Future<void> init() => _platform.init();

  /// Picks a single media file.
  Future<PickedMedia?> pickMedia({
    required BuildContext context,
    PickedMediaSource source = PickedMediaSource.gallery,
    bool pickAvatar = false,
  }) => _platform.pickMedia(
    context: context,
    source: source,
    pickAvatar: pickAvatar,
  );

  /// Picks one or more media files.
  Future<List<PickedMedia>?> pickMedias({
    required BuildContext context,
    bool multiSelection = true,
    PickedMediaSource source = PickedMediaSource.both,
    int maxSelection = 10,
  }) => _platform.pickMedias(
    context: context,
    multiSelection: multiSelection,
    source: source,
    maxSelection: maxSelection,
  );

  /// A widget that embeds the media picker (used by the post composer).
  Widget mediaPicker({
    required BuildContext context,
    required ValueSetter<List<PickedMedia>> onMediaPicked,
    bool multiSelection = true,
    PickedMediaSource source = PickedMediaSource.both,
    Key? key,
  }) => _platform.mediaPicker(
    context: context,
    onMediaPicked: onMediaPicked,
    multiSelection: multiSelection,
    source: source,
    key: key,
  );
}
// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'picked_media.dart';

/// Web media picker backed by `file_picker` (which has a web implementation).
///
/// Used only when compiling for browsers (see `image_picker.dart`).
PickerPlatform buildPickerPlatform() => PickerPlatform();

class PickerPlatform {
  PickerPlatform();

  Future<void> init() async {}

  Future<PickedMedia?> pickMedia({
    required BuildContext context,
    PickedMediaSource source = PickedMediaSource.gallery,
    bool pickAvatar = false,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: false,
      withData: true,
    );
    return _toMedia(result);
  }

  Future<List<PickedMedia>?> pickMedias({
    required BuildContext context,
    bool multiSelection = true,
    PickedMediaSource source = PickedMediaSource.both,
    int maxSelection = 10,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: multiSelection,
      withData: true,
    );
    return _toMedias(result);
  }

  Widget mediaPicker({
    required BuildContext context,
    required ValueSetter<List<PickedMedia>> onMediaPicked,
    bool multiSelection = true,
    PickedMediaSource source = PickedMediaSource.both,
    Key? key,
  }) => _WebMediaPickerPage(
    key: key,
    multiSelection: multiSelection,
    onMediaPicked: onMediaPicked,
  );

  PickedMedia? _toMedia(FilePickerResult? result) {
    if (result == null || result.files.isEmpty) return null;
    return _toPicked(result.files.first);
  }

  List<PickedMedia>? _toMedias(FilePickerResult? result) {
    if (result == null || result.files.isEmpty) return null;
    return result.files.map(_toPicked).toList(growable: false);
  }

  PickedMedia _toPicked(PlatformFile file) {
    final xfile = XFile.fromData(
      Uint8List.fromList(file.bytes ?? const []),
      name: file.name,
    );
    return PickedMedia(file: xfile, bytes: file.bytes);
  }
}

class _WebMediaPickerPage extends StatelessWidget {
  const _WebMediaPickerPage({
    required this.onMediaPicked,
    this.multiSelection = true,
    super.key,
  });

  final ValueSetter<List<PickedMedia>> onMediaPicked;
  final bool multiSelection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Pick media')),
      body: Center(
        child: FilledButton.icon(
          onPressed: () async {
            final picked = await FilePicker.platform.pickFiles(
              type: FileType.media,
              allowMultiple: multiSelection,
              withData: true,
            );
            if (picked == null) return;
            final medias = picked.files
                .map(
                  (f) => PickedMedia(
                    file: XFile.fromData(
                      Uint8List.fromList(f.bytes ?? const []),
                      name: f.name,
                    ),
                    bytes: f.bytes,
                  ),
                )
                .toList(growable: false);
            onMediaPicked(medias);
          },
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Choose files'),
        ),
      ),
    );
  }
}
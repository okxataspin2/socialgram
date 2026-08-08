// ignore_for_file: public_member_api_docs

import 'package:app_ui/app_ui.dart' hide AppTheme;
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_plus/image_picker_plus.dart';

import 'picked_media.dart';

PickerPlatform buildPickerPlatform() => PickerPlatform();

/// Native (Android/iOS) media picker backed by `image_picker_plus`.
///
/// NOTE: this file pulls in `dart:io` via image_picker_plus and is therefore
/// excluded from web builds by the conditional import in `image_picker.dart`.
class PickerPlatform {
  static final _defaultFilterOption = FilterOptionGroup(
    videoOption: FilterOption(
      durationConstraint: DurationConstraint(max: 3.minutes),
    ),
  );

  late TabsTexts _tabsTexts;

  Future<void> init() async {
    _tabsTexts = const TabsTexts();
  }

  AppTheme _appTheme(BuildContext context) => AppTheme(
    primaryColor: AppColors.blue,
    surfaceColor: context.customAdaptiveColor(
      light: AppColors.white,
      dark: AppColors.black,
    ),
    onSurfaceColor: context.customAdaptiveColor(
      light: AppColors.black,
      dark: AppColors.white,
    ),
    primaryContainerColor: AppColors.deepBlue,
    shimmerBaseColor: const Color(0xff2d2f2f),
    shimmerHighlightColor: const Color(0xff13151b),
  );

  SliverGridDelegateWithFixedCrossAxisCount _sliverGridDelegate() =>
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 1.7,
        mainAxisSpacing: 1.5,
      );

  List<PickedMedia> _map(List<SelectedFile> files) => files
      .map(
        (e) => PickedMedia(
          file: XFile(e.filePath, name: e.fileName),
          bytes: e.selectedByte,
        ),
      )
      .toList(growable: false);

  PickedMediaSource? _webSource(ImageSource source) => switch (source) {
    ImageSource.both => PickedMediaSource.both,
    ImageSource.gallery => PickedMediaSource.gallery,
    ImageSource.camera => PickedMediaSource.camera,
  };

  ImageSource _nativeSource(PickedMediaSource source) => switch (source) {
    PickedMediaSource.both => ImageSource.both,
    PickedMediaSource.gallery => ImageSource.gallery,
    PickedMediaSource.camera => ImageSource.camera,
  };

  Future<void> initPlatform() async {}

  Future<PickedMedia?> pickMedia({
    required BuildContext context,
    PickedMediaSource source = PickedMediaSource.gallery,
    bool pickAvatar = false,
  }) async {
    final media = await context.pickImage(
      source: _nativeSource(source),
      multiImages: false,
      pickAvatar: pickAvatar,
      filterOption: _defaultFilterOption,
      galleryDisplaySettings: GalleryDisplaySettings(
        pickAvatar: pickAvatar,
        tabsTexts: _tabsTexts,
        appTheme: _appTheme(context),
      ),
    );
    if (media == null) return null;
    return _map(media.selectedFiles).firstOrNull;
  }

  Future<List<PickedMedia>?> pickMedias({
    required BuildContext context,
    bool multiSelection = true,
    PickedMediaSource source = PickedMediaSource.both,
    int maxSelection = 10,
  }) async {
    final media = await context.pickBoth(
      source: _nativeSource(source),
      multiSelection: multiSelection,
      filterOption: _defaultFilterOption,
      galleryDisplaySettings: GalleryDisplaySettings(
        maximumSelection: maxSelection,
        showImagePreview: true,
        cropImage: true,
        tabsTexts: _tabsTexts,
        appTheme: _appTheme(context),
      ),
    );
    if (media == null) return null;
    return _map(media.selectedFiles);
  }

  Widget mediaPicker({
    required BuildContext context,
    required ValueSetter<List<PickedMedia>> onMediaPicked,
    bool multiSelection = true,
    PickedMediaSource source = PickedMediaSource.both,
  }) => CustomImagePicker(
    galleryDisplaySettings: GalleryDisplaySettings(
      showImagePreview: true,
      cropImage: true,
      tabsTexts: _tabsTexts,
      appTheme: _appTheme(context),
      callbackFunction: (details) =>
          onMediaPicked.call(_map(details.selectedFiles)),
    ),
    multiSelection: multiSelection,
    pickerSource: PickerSource.both,
    source: _nativeSource(source),
    filterOption: _defaultFilterOption,
    wantKeepAlive: true,
  );
}
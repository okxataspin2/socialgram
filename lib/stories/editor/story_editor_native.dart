import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:stories_editor/stories_editor.dart';

/// Native (Android/iOS) story editor backed by the `stories_editor` package.
Widget storyEditorScreen({
  required BuildContext context,
  required dynamic Function(String?)? onDone,
}) {
  final l10n = context.l10n;
  return StoriesEditor(
    onDone: onDone,
    storiesEditorLocalizationDelegate: StoriesEditorLocalizationDelegate(
      cancelText: l10n.cancelText,
      discardEditsText: l10n.discardEditsText,
      discardText: l10n.discardText,
      doneText: l10n.doneText,
      draftEmpty: l10n.draftEmpty,
      errorText: l10n.errorText,
      loseAllEditsText: l10n.loseAllEditsText,
      saveDraft: l10n.saveDraft,
      successfullySavedText: l10n.successfullySavedText,
      tapToTypeText: l10n.tapToTypeText,
      uploadText: l10n.uploadText,
    ),
    galleryThumbnailQuality: 900,
  );
}
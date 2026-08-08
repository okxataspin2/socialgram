import 'package:flutter/widgets.dart';

import 'story_editor_native.dart' if (dart.library.html) 'story_editor_web.dart'
    as impl;

/// Returns the story editor screen for the current platform.
///
/// On Android/iOS this is the full `stories_editor` drawing/sticker editor;
/// on web a lightweight compose flow is used (pick photo -> upload).
///
/// [onDone] receives the local file path of the composed story image on
/// mobile. It is unused by the web flow.
Widget storyEditorScreen({
  required BuildContext context,
  required dynamic Function(String)? onDone,
}) =>
    impl.storyEditorScreen(context: context, onDone: onDone);
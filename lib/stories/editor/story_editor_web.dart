import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

/// Web story composer.
///
/// The full `stories_editor` package (drawing, stickers, audio) depends on
/// native file APIs that are not available in browsers. This lightweight
/// composer lets web users pick a photo and upload it as a story.
class WebStoryComposer extends StatefulWidget {
  const WebStoryComposer({super.key});

  @override
  State<WebStoryComposer> createState() => _WebStoryComposerState();
}

class _WebStoryComposerState extends State<WebStoryComposer> {
  PickedMedia? _picked;
  bool _uploading = false;

  Future<void> _pick() async {
    final picked = await PickImage().pickMedia(
      context: context,
      source: PickedMediaSource.gallery,
    );
    if (picked == null || !mounted) return;
    setState(() => _picked = picked);
  }

  Future<void> _upload() async {
    final picked = _picked;
    if (picked == null || _uploading) return;

    final user = context.select((AppBloc bloc) => bloc.state.user);
    setState(() => _uploading = true);
    context.read<CreateStoriesBloc>().add(
      CreateStoriesStoryCreateRequested(
        author: user,
        contentType: StoryContentType.image,
        filePath: picked.fileName,
        storyMedia: picked,
        onLoading: () => toggleLoadingIndeterminate(),
        onStoryCreated: () {
          toggleLoadingIndeterminate(enable: false);
          openSnackbar(
            SnackbarMessage.success(
              title: context.l10n.successfullyCreatedStoryText,
            ),
          );
          context.pop();
        },
        onError: (_, _) {
          toggleLoadingIndeterminate(enable: false);
          openSnackbar(
            SnackbarMessage.error(
              title: context.l10n.somethingWentWrongText,
              description: context.l10n.failedToCreateStoryText,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.addStoryText),
        centerTitle: false,
      ),
      body: Center(
        child: picked == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.uploadText,
                    style: context.titleMedium,
                  ),
                  gapH24,
                  Tappable.faded(
                    onTap: _pick,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.lg,
                    ),
                    child: Text(
                      context.l10n.uploadText,
                      style: context.labelLarge,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 360,
                    child: Image.memory(
                      picked.bytes ?? Uint8List(0),
                      fit: BoxFit.cover,
                    ),
                  ),
                  gapH24,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Tappable.faded(
                        onTap: _pick,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                          horizontal: AppSpacing.lg,
                        ),
                        child: Text(context.l10n.editText),
                      ),
                      gapW24,
                      Tappable.faded(
                        onTap: _upload,
                        borderRadius: BorderRadius.circular(6),
                        backgroundColor: AppColors.blue,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                          horizontal: AppSpacing.lg,
                        ),
                        child: Text(
                          _uploading
                              ? context.l10n.uploadText
                              : context.l10n.sharePostText,
                          style: context.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
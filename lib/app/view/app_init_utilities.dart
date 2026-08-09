import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';
import 'package:styled_text/styled_text.dart';

void initUtilities(BuildContext context, Locale locale) {
  final isSameLocal = Localizations.localeOf(context) == locale;
  if (isSameLocal) return;

  final l10n = context.l10n;
  final theme = context.theme;
  final textTheme = theme.textTheme;
  final titleMedium = textTheme.titleMedium;

  PickImage().init();
  BlockSettings().init(
    postDelegate: PostTextDelegate(
      cancelText: l10n.cancelText,
      editText: l10n.editText,
      deleteText: l10n.deleteText,
      deletePostText: l10n.deletePostText,
      deletePostConfirmationText: l10n.deletePostConfirmationText,
      notShowAgainText: l10n.notShowAgainText,
      blockAuthorConfirmationText: l10n.blockAuthorConfirmationText,
      blockAuthorText: l10n.blockAuthorText,
      blockPostAuthorText: l10n.blockPostAuthorText,
      blockText: l10n.blockText,
      noPostsText: l10n.noPostsText,
      visitSponsoredProfileText: l10n.visitSponsoredProfile,
      likedByText: (count, name, onUsernameTap) => StyledText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: titleMedium,
        text: l10n.likedByLabel(
          name,
          count < 1 ? '' : ' ${l10n.andText} ',
          l10n.othersText(count),
        ),
        tags: {
          'username': StyledTextActionTag((text, attrs) {
            return onUsernameTap?.call();
          }, style: titleMedium?.copyWith(fontWeight: AppFontWeight.bold)),
          'count': StyledTextTag(
            style: titleMedium?.copyWith(fontWeight: AppFontWeight.bold),
          ),
        },
      ),
      sponsoredPostText: l10n.sponsoredPostText,
      likesCountText: l10n.likesCountText,
      likesCountShortText: l10n.likesCountTextShort,
    ),
    commentDelegate: CommentTextDelegate(
      seeAllCommentsText: l10n.seeAllComments,
      replyText: l10n.replyText,
    ),
    followDelegate: FollowTextDelegate(
      followText: l10n.followUser,
      followingText: l10n.followingUser,
    ),
  );
}

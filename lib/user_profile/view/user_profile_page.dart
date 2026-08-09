// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/admin/admin.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/selector/selector.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:user_repository/user_repository.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    required this.userId,
    this.props = const UserProfileProps.build(),
    super.key,
  });

  final String userId;
  final UserProfileProps props;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              UserProfileBloc(
                  userId: userId,
                  postsRepository: context.read<PostsRepository>(),
                  userRepository: context.read<UserRepository>(),
                )
                ..add(const UserProfileSubscriptionRequested())
                ..add(const UserProfilePostsCountSubscriptionRequested())
                ..add(const UserProfileFollowingsCountSubscriptionRequested())
                ..add(const UserProfileFollowersCountSubscriptionRequested()),
        ),
      ],
      child: UserProfileView(userId: userId, props: props),
    );
  }
}

class UserProfileView extends StatefulWidget {
  const UserProfileView({required this.props, required this.userId, super.key});

  final String userId;
  final UserProfileProps props;

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView>
    with SingleTickerProviderStateMixin {
  late ScrollController _controller;

  UserProfileProps get props => widget.props;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final promoAction =
        props.promoBlockAction as NavigateToSponsoredPostAuthorProfileAction?;
    final user = context.select((UserProfileBloc bloc) => bloc.state.user);

    return AppScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !props.isSponsored
          ? null
          : PromoFloatingAction(
              url: promoAction!.promoUrl,
              promoImageUrl: promoAction.promoPreviewImageUrl,
              title: context.l10n.learnMoreAboutUserPromoText,
              subtitle: context.l10n.visitUserPromoWebsiteText,
            ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          floatHeaderSlivers: true,
          controller: _controller,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: MultiSliver(
                  children: [
                    UserProfileAppBar(sponsoredPost: props.sponsoredPost),
                    if (!user.isAnonymous || props.sponsoredPost != null) ...[
                      UserProfileHeader(
                        userId: widget.userId,
                        sponsoredPost: props.sponsoredPost,
                      ),
                      SliverPersistentHeader(
                        pinned: !ModalRoute.of(context)!.isFirst,
                        delegate: _SliverAppBarDelegate(
                          const TabBar(
                            indicatorSize: TabBarIndicatorSize.tab,
                            padding: EdgeInsets.zero,
                            labelPadding: EdgeInsets.zero,
                            indicatorWeight: 1,
                            tabs: [
                              Tab(
                                icon: Icon(Icons.grid_on),
                                iconMargin: EdgeInsets.zero,
                              ),
                              Tab(
                                icon: Icon(Icons.person_outline),
                                iconMargin: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              PostsPage(sponsoredPost: props.sponsoredPost),
              const UserProfileMentionedPostsPage(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.black.withOpacity(0.8)
            : AppColors.white.withOpacity(0.8),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class PostsPage extends StatefulWidget {
  const PostsPage({this.sponsoredPost, super.key});

  final PostSponsoredBlock? sponsoredPost;

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserProfileBloc>();

    super.build(context);
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        BetterStreamBuilder<List<PostBlock>>(
          initialData: const <PostBlock>[],
          stream: bloc.userPosts(),
          comparator: const ListEquality<PostBlock>().equals,
          builder: (context, blocks) {
            if (blocks.isEmpty && widget.sponsoredPost == null) {
              return const EmptyPosts();
            }
            return SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: widget.sponsoredPost != null ? 1 : blocks.length,
              itemBuilder: (context, index) {
                final block = widget.sponsoredPost ?? blocks[index];
                final multiMedia = block.media.length > 1;

                return PostPopup(
                  block: block,
                  index: index,
                  builder: (_) => PostSmall(
                    key: ValueKey(block.id),
                    pinned: false,
                    isReel: block.isReel,
                    multiMedia: multiMedia,
                    mediaUrl: block.firstMediaUrl!,
                    imageThumbnailBuilder: (_, url) =>
                        PostSmallImage(post: block),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class PostSmallImage extends StatelessWidget {
  const PostSmallImage({required this.post, super.key});

  final PostBlock post;

  @override
  Widget build(BuildContext context) {
    /// AppSpacing.xxs is the padding of the image.
    final screenWidth = (context.screenWidth - AppSpacing.xxs) / 3;
    final pixelRatio = context.devicePixelRatio;

    final size = min((screenWidth * pixelRatio) ~/ 1, 1920);
    return BlurHashImageThumbnail(
      id: post.id,
      height: size,
      width: size,
      url: post.firstMediaUrl!,
      blurHash: post.firstMedia?.blurHash,
    );
  }
}

class UserProfileMentionedPostsPage extends StatelessWidget {
  const UserProfileMentionedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        const EmptyPosts(icon: Icons.person_pin_outlined),
      ],
    );
  }
}

class UserProfileAppBar extends StatelessWidget {
  const UserProfileAppBar({this.sponsoredPost, super.key});

  final PostSponsoredBlock? sponsoredPost;

  @override
  Widget build(BuildContext context) {
    final isOwner = context.select((UserProfileBloc bloc) => bloc.isOwner);
    final user$ = context.select((UserProfileBloc b) => b.state.user);
    final user = sponsoredPost == null
        ? user$
        : user$.isAnonymous
        ? sponsoredPost!.author.toUser
        : user$;

    return SliverPadding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      sliver: SliverAppBar(
        centerTitle: false,
        pinned: !ModalRoute.of(context)!.isFirst,
        floating: ModalRoute.of(context)!.isFirst,
        title: Row(
          children: [
            Flexible(
              flex: 12,
              child: Text(
                '${user.displayUsername} ',
                style: context.titleLarge?.copyWith(
                  fontWeight: AppFontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Assets.icons.verifiedUser.svg(
                width: AppSize.iconSizeSmall,
                height: AppSize.iconSizeSmall,
              ),
            ),
          ],
        ),
        actions: [
          if (!isOwner)
            const UserProfileActions()
          else ...[
            const UserProfileAddMediaButton(),
            if (ModalRoute.of(context)?.isFirst ?? false) ...const [
              gapW12,
              UserProfileSettingsButton(),
            ],
          ],
        ],
      ),
    );
  }
}

class UserProfileActions extends StatelessWidget {
  const UserProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () {},
      child: Icon(Icons.adaptive.more_outlined, size: AppSize.iconSize),
    );
  }
}

class UserProfileSettingsButton extends StatelessWidget {
  const UserProfileSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () => context
          .showListOptionsModal(
            options: [
              ModalOption(child: const LocaleModalOption()),
              ModalOption(child: const ThemeSelectorModalOption()),
              ModalOption(child: const ChangePasswordModalOption()),
              if (AdminGuard.isAdmin(context))
                ModalOption(child: const AdminModalOption()),
              ModalOption(child: const LogoutModalOption()),
              ModalOption(child: const RWAgencyBrandingModalOption()),
            ],
          )
          .then((option) {
            if (option == null) return;
            void onTap() => option.onTap(context);
            onTap.call();
          }),
      child: Assets.icons.setting.svg(
        height: AppSize.iconSize,
        width: AppSize.iconSize,
        colorFilter: ColorFilter.mode(context.adaptiveColor, BlendMode.srcIn),
      ),
    );
  }
}

class LogoutModalOption extends StatelessWidget {
  const LogoutModalOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () => context.confirmAction(
        fn: () {
          context.pop();
          context.read<AppBloc>().add(const AppLogoutRequested());
        },
        title: context.l10n.logOutText,
        content: context.l10n.logOutConfirmationText,
        noText: context.l10n.cancelText,
        yesText: context.l10n.logOutText,
      ),
      child: ListTile(
        title: Text(
          context.l10n.logOutText,
          style: context.bodyLarge?.apply(color: AppColors.red),
        ),
        leading: const Icon(Icons.logout, color: AppColors.red),
      ),
    );
  }
}

class AdminModalOption extends StatelessWidget {
  const AdminModalOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () => context.go('/admin'),
      child: const ListTile(
        title: Text('Admin Panel'),
        leading: Icon(Icons.admin_panel_settings, color: AppColors.blue),
      ),
    );
  }
}

class ChangePasswordModalOption extends StatelessWidget {
  const ChangePasswordModalOption({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tappable.faded(
      onTap: () => _showChangePasswordDialog(context),
      child: ListTile(
        title: Text(
          'Change Password',
          style: TextStyle(color: isDark ? AppColors.white : AppColors.black),
        ),
        leading: Icon(
          Icons.lock_outline,
          color: isDark
              ? AppColors.white.withValues(alpha: 0.7)
              : AppColors.black.withValues(alpha: 0.54),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: const Text('Change Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: oldPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Enter current password'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v != newPasswordController.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setState(() => isLoading = true);
                          try {
                            await context.read<AppBloc>().updateUser(
                              password: newPasswordController.text,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password changed successfully'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to change password: ${e.toString()}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (dialogContext.mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class RWAgencyBrandingModalOption extends StatelessWidget {
  const RWAgencyBrandingModalOption({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      title: Text(
        'Made by RWAGENCY',
        style: TextStyle(
          fontSize: 13,
          color: isDark
              ? AppColors.white.withValues(alpha: 0.5)
              : AppColors.black.withValues(alpha: 0.5),
        ),
      ),
      leading: Icon(
        Icons.copyright,
        size: 18,
        color: isDark
            ? AppColors.white.withValues(alpha: 0.4)
            : AppColors.black.withValues(alpha: 0.4),
      ),
    );
  }
}

class UserProfileAddMediaButton extends StatelessWidget {
  const UserProfileAddMediaButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final enableStory = context.select(
      (CreateStoriesBloc bloc) => bloc.state.isAvailable,
    );

    return Tappable.faded(
      onTap: () => context
          .showListOptionsModal(
            title: l10n.createText,
            options: createMediaModalOptions(
              context: context,
              reelLabel: l10n.reelText,
              postLabel: l10n.postText,
              storyLabel: l10n.storyText,
              enableStory: enableStory,
              goTo: (route, {extra}) => context.pushNamed(route, extra: extra),
              onStoryCreated: (path) {
                context.read<CreateStoriesBloc>().add(
                  CreateStoriesStoryCreateRequested(
                    author: user,
                    contentType: StoryContentType.image,
                    filePath: path,
                    onError: (_, _) {
                      toggleLoadingIndeterminate(enable: false);
                      openSnackbar(
                        SnackbarMessage.error(
                          title: l10n.somethingWentWrongText,
                          description: l10n.failedToCreateStoryText,
                        ),
                      );
                    },
                    onLoading: toggleLoadingIndeterminate,
                    onStoryCreated: () {
                      toggleLoadingIndeterminate(enable: false);
                      openSnackbar(
                        SnackbarMessage.success(
                          title: l10n.successfullyCreatedStoryText,
                        ),
                        clearIfQueue: true,
                      );
                    },
                  ),
                );
                context.pop();
              },
            ),
          )
          .then((option) {
            if (option == null) return;
            void onTap() => option.onTap(context);
            onTap.call();
          }),
      child: const Icon(Icons.add_box_outlined, size: AppSize.iconSize),
    );
  }
}

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';

class FeedAppBar extends StatelessWidget {
  const FeedAppBar({required this.innerBoxIsScrolled, super.key});

  final bool innerBoxIsScrolled;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      sliver: SliverAppBar(
        centerTitle: false,
        forceElevated: innerBoxIsScrolled,
        title: Row(
          children: [
            const AppLogo(),
            const SizedBox(width: 4),
            Text(
              'by RWAGENCY',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                    fontSize: 11,
                  ),
            ),
          ],
        ),
        floating: true,
        snap: true,
        actions: [
          Tappable.scaled(
            onTap: () => HomeProvider().animateToPage(2),
            child: Assets.icons.chatCircle.svg(
              height: AppSize.iconSize,
              width: AppSize.iconSize,
              colorFilter: ColorFilter.mode(
                context.adaptiveColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

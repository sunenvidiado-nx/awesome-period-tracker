import 'package:awesome_period_tracker/app/theme/app_assets.dart';
import 'package:awesome_period_tracker/ui/common_widgets/app_loader/app_shimmer.dart';
import 'package:awesome_period_tracker/ui/common_widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/ui/features/home/home_state_manager.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/exception_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CycleInsights extends StatelessWidget {
  const CycleInsights(this.homeStateManager, {super.key});

  final HomeStateManager homeStateManager;

  static const _insightsPlaceholder = '''
- Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod.

- Ut enim ad minim veniam quis nostrud exercitation ullamco.

- Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.'
''';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeState>(
      valueListenable: homeStateManager.notifier,
      builder: (context, state, _) {
        return AppCard(
          child: AppShimmer(
            isLoading: state.isLoading,
            child: AnimatedContainer(
              padding: const EdgeInsets.only(bottom: 10),
              key: ValueKey(state),
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton.keep(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.googleGeminiIcon,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              context.colorScheme.tertiary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.cycleInsights,
                            style: context.primaryTextTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.error != null)
                      Text(
                        state.error!.errorMessage,
                      )
                    else
                      Markdown(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        data: state.insight?.insights ?? _insightsPlaceholder,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

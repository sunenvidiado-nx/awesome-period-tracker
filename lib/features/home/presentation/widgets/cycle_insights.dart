import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_shimmer.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/features/home/application/insights_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:table_calendar/table_calendar.dart';

class CycleInsights extends ConsumerWidget {
  const CycleInsights({
    required this.date,
    super.key,
  });

  final DateTime date;

  get _stateParams => InsightsProviderParams(
        date: date,
        isPast: isSameDay(date, DateTime.now()),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insightsProvider(_stateParams));

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
                Markdown(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  data: state.maybeWhen(
                    data: (insight) => insight.insights,
                    orElse: () => _insightsPlaceholder,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _insightsPlaceholder = '''
- Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod.

- Ut enim ad minim veniam quis nostrud exercitation ullamco.

- Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.'
''';
}

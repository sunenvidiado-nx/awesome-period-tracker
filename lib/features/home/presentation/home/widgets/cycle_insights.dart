import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_shimmer.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/features/home/application/insights_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CycleInsights extends ConsumerWidget {
  const CycleInsights({
    required this.date,
    super.key,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateParams = InsightsProviderParams(date: date);
    final state = ref.watch(insightsProvider(stateParams));

    return AppCard(
      child: AppShimmer(
        isLoading: state.isLoading,
        child: SizedBox(
          width: double.infinity,
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.cycleInsights,
                  style: context.primaryTextTheme.titleMedium,
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

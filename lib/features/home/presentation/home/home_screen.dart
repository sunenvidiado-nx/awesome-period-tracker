import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/core/widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/features/home/data/cycle_events_repository.dart';
import 'package:awesome_period_tracker/features/home/data/cycle_predictions_repository.dart';
import 'package:awesome_period_tracker/features/home/presentation/home/widgets/calendar.dart';
import 'package:awesome_period_tracker/features/home/presentation/home/widgets/insights.dart';
import 'package:awesome_period_tracker/features/home/presentation/log_cycle_event/log_cycle_event_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

final cyclePredictionsProvider = FutureProvider.autoDispose((ref) async {
  final events = await ref.read(cycleEventsRepositoryProvider).get();

  return ref
      .read(cyclePredictionsRepositoryProvider)
      .generateFullCyclePredictions(events);
});

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildCalendarSection(context),
          _buildInsightsSection(context),
        ],
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 40,
      automaticallyImplyLeading: false,
      // TODO - Uncomment this code to add a theme switcher to the app bar
      // leading: Consumer(
      //   builder: (context, ref, child) {
      //     final themeMode = ref.watch(themeModeProvider);

      //     return AnimatedSwitcher(
      //       duration: const Duration(milliseconds: 450),
      //       child: Padding(
      //         padding: const EdgeInsets.only(top: 4),
      //         child: IconButton(
      //           icon: Icon(
      //             themeMode == ThemeMode.dark
      //                 ? Icons.brightness_7_rounded
      //                 : Icons.brightness_4_rounded,
      //             color: context.colorScheme.onSurface.withOpacity(0.6),
      //           ),
      //           onPressed: ref.read(themeModeProvider.notifier).toggleTheme,
      //         ),
      //       ),
      //     );
      //   },
      // ),
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SvgPicture.asset(AppAssets.mainIconNoBackground, height: 25),
      ),
    );
  }

  Widget _buildCalendarSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
        child: AppCard(
          child: Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(cyclePredictionsProvider);

              return Calendar(
                cycleEvents: state.maybeWhen(
                  data: (predictions) => predictions.events,
                  orElse: () => [],
                ),
                onDaySelected: (selectedDay, _) {},
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Insights(),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return AppShadow(
      child: FloatingActionButton.extended(
        elevation: 0,
        onPressed: () async => _showCycleEventTypeBottomSheet(context),
        label: Text(
          context.l10n.logCycleEvent,
          style: context.primaryTextTheme.titleMedium
              ?.copyWith(color: context.colorScheme.surface),
        ),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> _showCycleEventTypeBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.9,
      isScrollControlled: true,
      barrierColor: context.colorScheme.shadow.withOpacity(0.3),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: const LogCycleEventBottomSheet(),
      ),
    );
  }
}

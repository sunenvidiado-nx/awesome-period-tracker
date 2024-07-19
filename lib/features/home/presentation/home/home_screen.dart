import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/core/widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/features/home/presentation/home/home_state_provider.dart';
import 'package:awesome_period_tracker/features/home/presentation/home/widgets/calendar.dart';
import 'package:awesome_period_tracker/features/home/presentation/home/widgets/insights.dart';
import 'package:awesome_period_tracker/features/home/presentation/home/widgets/log_cycle_events.dart';
import 'package:awesome_period_tracker/features/home/presentation/log_cycle_event/log_cycle_event_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildCalendarSection(context),
          _buildLogCycleEventTypesSection(context),
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
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SvgPicture.asset(AppAssets.mainIconNoBackground, height: 25),
      ),
    );
  }

  Widget _buildCalendarSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: AppCard(
          child: Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(cycleEventsProvider);

              return Calendar(
                cycleEvents: state.maybeWhen(
                  data: (cycleEvents) => cycleEvents,
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

  Widget _buildLogCycleEventTypesSection(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: LogCycleEventTypes(),
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

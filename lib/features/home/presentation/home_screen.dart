import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/calendar/calendar.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/core/widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/features/app/router.dart';
import 'package:awesome_period_tracker/features/home/presentation/home_state_notifier.dart';
import 'package:awesome_period_tracker/features/home/presentation/widgets/insights.dart';
import 'package:awesome_period_tracker/features/home/presentation/widgets/log_cycle_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

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
      toolbarHeight: 25,
      automaticallyImplyLeading: false,
      title: SvgPicture.asset(AppAssets.mainIconNoBackground, height: 25),
    );
  }

  Widget _buildCalendarSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: AppCard(
          child: Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(homeStateProvider);

              return Calendar(
                cycleEvents: state.asData?.value.cycleEvents ?? [],
                selectedDate:
                    state.asData?.value.selectedDate ?? DateTime.now(),
                onDaySelected: (selectedDay, _) {
                  ref
                      .read(homeStateProvider.notifier)
                      .onDateSelected(selectedDay);
                },
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(homeStateProvider);

            return Insights(state.asData?.value.selectedDate ?? DateTime.now());
          },
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(homeStateProvider);

        return AppShadow(
          child: FloatingActionButton.extended(
            elevation: 0,
            onPressed: () =>
                context.push(Routes.logEvent(state.asData?.value.selectedDate)),
            label: Text(
              context.l10n.logSymptoms,
              style: context.primaryTextTheme.titleMedium
                  ?.copyWith(color: context.colorScheme.surface),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }
}

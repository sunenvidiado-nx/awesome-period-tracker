import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/core/widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/features/home/domain/period_flow.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/domain/fertile_type.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/domain/intimacy_type.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/presentation/widgets/week_calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LogCycleEventScreen extends StatelessWidget {
  const LogCycleEventScreen({
    this.date,
    super.key,
  });

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: ListView(
        children: [
          const WeekCalendar(),
          const SizedBox(height: 16),
          _buildFlowSection(context),
          const SizedBox(height: 28),
          _buildIntimacySection(context),
          const SizedBox(height: 28),
          _buildFertilitySection(context),
          const SizedBox(height: 28),
          _buildSymptomsFieldSection(context),
        ],
      ),
      bottomNavigationBar: _buildSubmitButton(context),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: context.colorScheme.surfaceContainer,
      title: Text(context.l10n.logSymptoms),
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: context.pop,
      ),
    );
  }

  Widget _buildFlowSection(BuildContext context) {
    return _buildSelectionGroup(
      context,
      context.l10n.period,
      PeriodFlow.values.map((flow) => flow.title).toList(),
    );
  }

  Widget _buildIntimacySection(BuildContext context) {
    return _buildSelectionGroup(
      context,
      context.l10n.intimacy,
      IntimacyType.values.map((type) => type.title).toList(),
    );
  }

  Widget _buildFertilitySection(BuildContext context) {
    return _buildSelectionGroup(
      context,
      context.l10n.fertility,
      Fertility.values.map((type) => type.title).toList(),
    );
  }

  Widget _buildSymptomsFieldSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.symptoms,
            style: context.primaryTextTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: context.l10n.symptomsExample,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionGroup(
    BuildContext context,
    String title,
    List<String> options,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.primaryTextTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              for (final option in options)
                _buildSelectionCard(context, option),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context,
    String title,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          title,
          style: context.primaryTextTheme.titleSmall,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppShadow(
          child: ElevatedButton(
            onPressed: () {},
            child: Text(context.l10n.logSymptoms),
          ),
        ),
      ),
    );
  }
}

import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/core/widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/core/widgets/snackbars/app_snackbar.dart';
import 'package:awesome_period_tracker/features/home/domain/period_flow.dart';
import 'package:awesome_period_tracker/features/home/presentation/home/home_state_provider.dart';
import 'package:awesome_period_tracker/features/home/presentation/log_cycle_event/log_cycle_event_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PeriodFlowStep extends StatefulWidget {
  const PeriodFlowStep({super.key});

  @override
  State<PeriodFlowStep> createState() => _PeriodFlowStepState();
}

class _PeriodFlowStepState extends State<PeriodFlowStep> {
  var _selectedFlow = PeriodFlow.light;
  var _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.49;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          for (final flow in PeriodFlow.values)
            _buildPeriodFlowTile(context, flow),
          const Spacer(),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Consumer(
          builder: (context, ref, child) => InkWell(
            child: const Icon(Icons.arrow_back_rounded, size: 22),
            onTap: () {
              ref
                  .read(logCycleEventStateProvider.notifier)
                  .changeCycleEventType(null);
            },
          ),
        ),
        const SizedBox(width: 16),
        Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(logCycleEventStateProvider);
            final date = state.selectedDate.isToday
                ? context.l10n.today.toLowerCase()
                : state.selectedDate.toReadableString();

            return Text(
              context.l10n.logPeriodForDate(date),
              style: context.primaryTextTheme.titleMedium,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPeriodFlowTile(BuildContext context, PeriodFlow flow) {
    // Some UI adjustments for the different cycle event types
    // have been applied by eye so it looks a little better.

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              flow.title,
              style: context.primaryTextTheme.titleMedium,
            ),
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedFlow == flow
                  ? Icon(
                      Icons.check_rounded,
                      color: context.colorScheme.primary,
                      size: 24,
                      key: const Key('selected'),
                    )
                  : const SizedBox.shrink(),
            ),
            onTap: () => setState(() => _selectedFlow = flow),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return AppShadow(
      child: Consumer(
        builder: (context, ref, child) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: _isSubmitting ? null : () => _onSubmit(context, ref),
            child: _isSubmitting
                ? AppLoader(color: context.colorScheme.surface, size: 30)
                : Text(context.l10n.logCycleEvent),
          );
        },
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context, WidgetRef ref) async {
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(logCycleEventStateProvider.notifier)
          .logPeriod(_selectedFlow)
          .then(
        (_) {
          ref.invalidate(cycleEventsProvider);
          context.showSnackbar(context.l10n.cycleEventLoggedSuccessfully);
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      // TODO
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

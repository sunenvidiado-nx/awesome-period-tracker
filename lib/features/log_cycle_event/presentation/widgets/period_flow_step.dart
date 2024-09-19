import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/core/widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/core/widgets/snackbars/app_snackbar.dart';
import 'package:awesome_period_tracker/features/home/application/cycle_forecast_provider.dart';
import 'package:awesome_period_tracker/features/home/application/insights_provider.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/application/log_cycle_event_state_provider.dart';
import 'package:awesome_period_tracker/features/home/data/insights_repository.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/domain/log_event_step.dart';
import 'package:awesome_period_tracker/features/home/domain/period_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PeriodFlowStep extends StatefulWidget {
  const PeriodFlowStep({
    this.periodEvent,
    super.key,
  });

  final CycleEvent? periodEvent;

  @override
  State<PeriodFlowStep> createState() => _PeriodFlowStepState();
}

class _PeriodFlowStepState extends State<PeriodFlowStep> {
  var _selectedFlow = PeriodFlow.light;
  var _isSubmitting = false;

  static const _selectionList = [
    PeriodFlow.light,
    PeriodFlow.medium,
    PeriodFlow.heavy,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.selectPeriodFlowLevel,
              style: context.primaryTextTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final flow in _selectionList) _buildPeriodFlowTile(flow),
            const Spacer(),
            _buildSubmitButton(),
            if (widget.periodEvent != null) ...[
              const SizedBox(height: 4),
              _buildRemoveLogButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFlowTile(PeriodFlow flow) {
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
              style: context.primaryTextTheme.titleSmall,
            ),
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedFlow == flow
                  ? Icon(
                      Icons.check_rounded,
                      color: context.colorScheme.primary,
                      size: 24,
                    )
                  : const SizedBox.shrink(),
            ),
            onTap: () => setState(() => _selectedFlow = flow),
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveLogButton() {
    return Consumer(
      builder: (context, ref, child) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: Colors.transparent,
          foregroundColor: context.colorScheme.error,
        ),
        onPressed: _isSubmitting
            ? null
            : () {
                setState(() => _selectedFlow = PeriodFlow.noFlow);
                _onSubmit(context, ref);
              },
        child: _isSubmitting
            ? AppLoader(color: context.colorScheme.surface, size: 30)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_rounded,
                    color: context.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(context.l10n.removeLog),
                ],
              ),
      ),
    );
  }

  Widget _buildSubmitButton() {
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
                : Text(context.l10n.logPeriod),
          );
        },
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context, WidgetRef ref) async {
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(logCycleEventStateProvider(LogEventStep.periodFlow).notifier)
          .logPeriod(_selectedFlow)
          .then(
        (_) {
          ref.read(insightsRepositoryProvider).clearCache();
          ref.invalidate(cycleForecastProvider);
          ref.invalidate(insightsProvider);
          context.showSnackbar(context.l10n.cycleEventLoggedSuccessfully);
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.showErrorSnackbar();
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/core/widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/core/widgets/snackbars/app_snackbar.dart';
import 'package:awesome_period_tracker/features/home/application/cycle_forecast_provider.dart';
import 'package:awesome_period_tracker/features/home/application/insights_provider.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/application/log_cycle_event_state_provider.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/application/symptoms_state_provider.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/domain/log_event_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SymptomsStep extends StatefulWidget {
  const SymptomsStep({this.symptomEvent, super.key});

  final CycleEvent? symptomEvent;

  @override
  State<SymptomsStep> createState() => _SymptomsStepState();
}

class _SymptomsStepState extends State<SymptomsStep> {
  late final _symptomStateArgs = widget.symptomEvent?.additionalData ?? '';

  var _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.logSymptomsExperiencedToday,
              style: context.primaryTextTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSymptoms(),
            const Spacer(),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptoms() {
    return Consumer(
      builder: (context, ref, child) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: ref.watch(symptomsStateProvider(_symptomStateArgs)).when(
              loading: () => const Center(child: AppLoader()),
              error: (_, __) => Center(child: Text(context.l10n.genericError)),
              data: (e) => _buildChips(context, ref, e.symptoms, e.selected),
            ),
      ),
    );
  }

  Widget _buildChips(
    BuildContext context,
    WidgetRef ref,
    List<String> symptoms,
    List<String> selected,
  ) {
    final symptomsNotifier =
        ref.read(symptomsStateProvider(_symptomStateArgs).notifier);
    final logSymptomNotifier =
        ref.read(logCycleEventStateProvider(LogEventStep.symptoms).notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        children: [
          for (final symptom in symptoms)
            _buildChip(
              symptom,
              selected.contains(symptom),
              () => symptomsNotifier.toggleSymptom(symptom),
            ),
          InkWell(
            onTap: () =>
                logSymptomNotifier.goToStep(LogEventStep.addNewSymptom),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.colorScheme.onSurface.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(14),
                color: context.colorScheme.onTertiary,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 18,
                    color: context.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    context.l10n.addSymptom,
                    style: TextStyle(color: context.colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    String symptom,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? context.colorScheme.secondary
                : context.colorScheme.onSurface.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? context.colorScheme.secondary
              : context.colorScheme.onTertiary,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check,
                size: 18,
                color: context.colorScheme.onTertiary,
              ),
            const SizedBox(width: 2),
            Text(
              symptom.toTitleCase(),
              style: TextStyle(
                color: isSelected
                    ? context.colorScheme.onTertiary
                    : context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AppShadow(
      child: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(symptomsStateProvider(_symptomStateArgs));
          final noSymptomsSelected =
              state.asData?.value.selected.isEmpty ?? true;

          return ElevatedButton(
            onPressed: _isSubmitting && noSymptomsSelected
                ? null
                : () => _onSubmit(context, ref),
            child: _isSubmitting
                ? AppLoader(color: context.colorScheme.surface, size: 30)
                : Text(context.l10n.logSymptoms),
          );
        },
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context, WidgetRef ref) async {
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(logCycleEventStateProvider(LogEventStep.symptoms).notifier)
          .logSymptoms(
            ref.watch(symptomsStateProvider(_symptomStateArgs)).value!.selected,
          )
          .then(
        (_) {
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

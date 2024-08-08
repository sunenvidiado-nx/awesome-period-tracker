import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/core/widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/core/widgets/snackbars/app_snackbar.dart';
import 'package:awesome_period_tracker/features/home/application/cycle_forecast_provider.dart';
import 'package:awesome_period_tracker/features/home/application/log_cycle_event_state_provider.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event_type.dart';
import 'package:awesome_period_tracker/features/home/domain/symptoms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SymptomsStep extends StatefulWidget {
  const SymptomsStep({
    this.symptomEvent,
    super.key,
  });

  final CycleEvent? symptomEvent;

  @override
  State<SymptomsStep> createState() => _SymptomsStepState();
}

class _SymptomsStepState extends State<SymptomsStep> {
  final _additionalInfoController = TextEditingController();

  var _isSubmitting = false;
  var _selectedSymptoms = <Symptoms>[Symptoms.pain];

  @override
  void initState() {
    super.initState();

    if (widget.symptomEvent != null) {
      final defaultSymptoms = widget.symptomEvent!.additionalData!
          .split(Symptoms.separator)
          .map((e) => e.trim())
          .map(Symptoms.fromString)
          .toList();

      final otherSymptoms = widget.symptomEvent?.additionalData
          ?.split(Symptoms.separator)
          .where((e) => !Symptoms.values.map((e) => e.title).contains(e))
          .firstOrNull;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _selectedSymptoms = defaultSymptoms);

        if (otherSymptoms != null) {
          _additionalInfoController.text = otherSymptoms;
        }
      });
    }
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

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
            ListView.builder(
              shrinkWrap: true,
              itemCount: Symptoms.values.length,
              itemBuilder: (context, index) =>
                  _buildSymptomsTiles(Symptoms.values[index]),
            ),
            const SizedBox(height: 8),
            _buildAddtionalInfoTextField(),
            const Spacer(),
            _buildSubmitButton(),
            if (widget.symptomEvent != null) ...[
              const SizedBox(height: 4),
              _buildRemoveLogButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsTiles(Symptoms symptom) {
    // Some UI adjustments for the different cycle event types
    // have been applied by eye so it looks a little better.

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              symptom.title,
              style: context.primaryTextTheme.titleSmall,
            ),
            subtitle: Text(
              _getSymptomDescription(symptom),
              style: context.textTheme.bodyMedium,
            ),
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.check_rounded,
                color: _selectedSymptoms.contains(symptom)
                    ? context.colorScheme.primary
                    : Colors.transparent,
                size: 24,
              ),
            ),
            onTap: () => setState(() {
              if (_selectedSymptoms.contains(symptom)) {
                if (_selectedSymptoms.length == 1) {
                  return; // If only one symptom is selected, it should not be removed
                }

                _selectedSymptoms.remove(symptom);
              } else {
                _selectedSymptoms.add(symptom);
              }
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildAddtionalInfoTextField() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: !_selectedSymptoms.contains(Symptoms.other)
          ? const SizedBox.shrink()
          : TextField(
              controller: _additionalInfoController,
              decoration: InputDecoration(
                hintText: context.l10n.describeOtherSymptomsOptional,
              ),
              style: context.textTheme.bodyMedium,
              maxLines: 2,
            ),
    );
  }

  String _getSymptomDescription(Symptoms symptom) {
    return switch (symptom) {
      Symptoms.pain => context.l10n.crampsHeadachesSorenessEtc,
      Symptoms.physical => context.l10n.insomniaFatigueAcneNauseaEtc,
      Symptoms.emotional => context.l10n.moodSwingsIrritabilityAnxietyEtc,
      Symptoms.other => context.l10n.anySymptomNotListedOrCategorized,
    };
  }

  Widget _buildSubmitButton() {
    return AppShadow(
      child: Consumer(
        builder: (context, ref, child) => ElevatedButton(
          onPressed: _isSubmitting && _selectedSymptoms.isEmpty
              ? null
              : () => _onSubmit(context, ref),
          child: _isSubmitting
              ? AppLoader(color: context.colorScheme.surface, size: 30)
              : Text(context.l10n.logSymptoms),
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
                // setState(() => _selectedFlow = PeriodFlow.noFlow);
                // _onSubmit(context, ref);
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

  Future<void> _onSubmit(
    BuildContext context,
    WidgetRef ref,
  ) async {
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(logCycleEventStateProvider(CycleEventType.symptoms).notifier)
          .logSymptoms(
            _selectedSymptoms,
            _selectedSymptoms.contains(Symptoms.other)
                ? _additionalInfoController.text
                : null,
          )
          .then(
        (_) {
          ref.invalidate(cycleForecastProvider);
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

  Future<void> onDelete(
    BuildContext context,
    WidgetRef ref,
  ) async {
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(logCycleEventStateProvider(CycleEventType.symptoms).notifier)
          .removeSymptomsEvent(widget.symptomEvent!)
          .then((_) {
        ref.invalidate(cycleForecastProvider);
        context.showSnackbar(context.l10n.cycleEventsHaveBeenUpdated);
        Navigator.of(context).pop();
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.showErrorSnackbar();
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

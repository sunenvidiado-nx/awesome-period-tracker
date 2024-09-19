import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/core/widgets/buttons/app_back_button.dart';
import 'package:awesome_period_tracker/core/widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/application/log_cycle_event_state_provider.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/data/symptoms_repository.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/domain/log_event_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNewSymptomStep extends StatefulWidget {
  const AddNewSymptomStep({super.key});

  @override
  State<AddNewSymptomStep> createState() => _AddNewSymptomStepState();
}

class _AddNewSymptomStepState extends State<AddNewSymptomStep> {
  final _formKey = GlobalKey<FormState>();
  final _symptomController = TextEditingController();

  var _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildBackButton(),
                  Text(
                    context.l10n.addNewSymptom,
                    style: context.primaryTextTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSymptomTextField(),
              const Spacer(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Consumer(
      builder: (context, ref, child) => AppBackButton(
        onPressed: () => _onBack(ref),
      ),
    );
  }

  void _onBack(WidgetRef ref) {
    ref
        .read(logCycleEventStateProvider(LogEventStep.symptoms).notifier)
        .goToStep(LogEventStep.symptoms);
  }

  Widget _buildSymptomTextField() {
    return TextFormField(
      controller: _symptomController,
      autofocus: true,
      decoration: InputDecoration(hintText: context.l10n.symptom),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.l10n.fieldCantBeEmpty;
        }

        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return AppShadow(
      child: Consumer(
        builder: (context, ref, child) {
          return ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    setState(() => _isSubmitting = true);

                    try {
                      await ref
                          .read(symptomsRepositoryProvider)
                          .create(_symptomController.text);

                      _onBack(ref);
                    } catch (e) {
                      // TODO Implement
                    } finally {
                      setState(() => _isSubmitting = false);
                    }
                  },
            child: _isSubmitting
                ? AppLoader(color: context.colorScheme.surface, size: 30)
                : Text(context.l10n.addSymptom),
          );
        },
      ),
    );
  }
}

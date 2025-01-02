import 'package:awesome_period_tracker/domain/models/log_event_step.dart';
import 'package:awesome_period_tracker/ui/common_widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/ui/common_widgets/buttons/app_back_button.dart';
import 'package:awesome_period_tracker/ui/common_widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/ui/features/log_cycle_event/log_cycle_event_state_manager.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';

class AddNewSymptomStep extends StatefulWidget {
  const AddNewSymptomStep({
    required this.stateManager,
    super.key,
  });

  final LogCycleEventStateManager stateManager;

  @override
  State<AddNewSymptomStep> createState() => _AddNewSymptomStepState();
}

class _AddNewSymptomStepState extends State<AddNewSymptomStep> {
  final _formKey = GlobalKey<FormState>();
  final _symptomController = TextEditingController();

  var _isSubmitting = false;

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

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
    return AppBackButton(
      onPressed: () => widget.stateManager.setStep(LogEventStep.symptoms),
    );
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
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _onSubmit,
        child: _isSubmitting
            ? AppLoader(color: context.colorScheme.surface, size: 30)
            : Text(context.l10n.addSymptom),
      ),
    );
  }

  Future<void> _onSubmit() async {
    try {
      setState(() => _isSubmitting = true);
      await widget.stateManager.createSymptom(_symptomController.text);
      widget.stateManager.setStep(LogEventStep.symptoms);
    } catch (e) {
      // TODO Implement
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

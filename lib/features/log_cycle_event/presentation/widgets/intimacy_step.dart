import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/core/widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/core/widgets/snackbars/app_snackbar.dart';
import 'package:awesome_period_tracker/features/home/domain/cycle_event.dart';
import 'package:awesome_period_tracker/features/log_cycle_event/application/log_cycle_event_state_manager.dart';
import 'package:flutter/material.dart';

class IntimacyStep extends StatefulWidget {
  const IntimacyStep({
    required this.stateManager,
    this.intimacyEvent,
    super.key,
  });

  final LogCycleEventStateManager stateManager;
  final CycleEvent? intimacyEvent;

  @override
  State<IntimacyStep> createState() => _IntimacyStepState();
}

class _IntimacyStepState extends State<IntimacyStep> {
  var _didUseProtection = true;
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
              context.l10n.logIntimateActivityForToday,
              style: context.primaryTextTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final value in [true, false]) _buildSelectionTile(value),
            const Spacer(),
            _buildSubmitButton(),
            if (widget.intimacyEvent != null) ...[
              const SizedBox(height: 4),
              _buildRemoveLogButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionTile(bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              value
                  ? context.l10n.usedProtection
                  : context.l10n.didNotUseProtection,
              style: context.primaryTextTheme.titleSmall,
            ),
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: value == _didUseProtection
                  ? Icon(
                      Icons.check_rounded,
                      color: context.colorScheme.primary,
                      size: 24,
                    )
                  : const SizedBox.shrink(),
            ),
            onTap: () => setState(() => _didUseProtection = value),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AppShadow(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
        onPressed: _isSubmitting ? null : () => _onSubmit(),
        child: _isSubmitting
            ? AppLoader(color: context.colorScheme.surface, size: 30)
            : Text(context.l10n.logIntimacy),
      ),
    );
  }

  Widget _buildRemoveLogButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: Colors.transparent,
        foregroundColor: context.colorScheme.error,
      ),
      onPressed: () {
        if (!_isSubmitting) _removeIntimacy();
      },
      child: Row(
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
    );
  }

  Future<void> _onSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      await widget.stateManager.logIntimacy(_didUseProtection).then(
        (_) {
          widget.stateManager.clearCachedInsights();

          context
            ..showSnackbar(context.l10n.cycleEventLoggedSuccessfully)
            ..popNavigator(true);
        },
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.showErrorSnackbar();
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _removeIntimacy() async {
    assert(widget.intimacyEvent != null);

    try {
      setState(() => _isSubmitting = true);
      await widget.stateManager.removeEvent(widget.intimacyEvent!);
      widget.stateManager.clearCachedInsights();
      context
        ..showSnackbar(context.l10n.cycleEventLoggedSuccessfully)
        ..popNavigator(true);
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.showErrorSnackbar();
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

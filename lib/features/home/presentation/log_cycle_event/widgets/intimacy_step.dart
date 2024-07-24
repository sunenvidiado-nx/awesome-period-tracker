import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/core/widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/core/widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/core/widgets/snackbars/app_snackbar.dart';
import 'package:awesome_period_tracker/features/home/data/insights_repository.dart';
import 'package:awesome_period_tracker/features/home/presentation/home/home_screen.dart';
import 'package:awesome_period_tracker/features/home/presentation/log_cycle_event/log_cycle_event_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IntimacyStep extends StatefulWidget {
  const IntimacyStep({super.key});

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
            _buildHeader(),
            const SizedBox(height: 16),
            for (final value in [true, false]) _buildSelectionTile(value),
            const Spacer(),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Consumer(
          builder: (context, ref, child) {
            return InkWell(
              child: const Icon(Icons.arrow_back_rounded, size: 22),
              onTap: () {
                ref
                    .read(logCycleEventStateProvider.notifier)
                    .changeCycleEventType(null);
              },
            );
          },
        ),
        const SizedBox(width: 16),
        Text(
          context.l10n.logIntimateActivityForToday,
          style: context.primaryTextTheme.titleMedium,
        ),
      ],
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
      child: Consumer(
        builder: (context, ref, child) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: _isSubmitting ? null : () => _onSubmit(context, ref),
            child: _isSubmitting
                ? AppLoader(color: context.colorScheme.surface, size: 30)
                : Text(context.l10n.logIntimacy),
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
          .logIntimacy(_didUseProtection)
          .then(
        (_) {
          ref.read(insightsRepositoryProvider).clearCache();
          ref.invalidate(cyclePredictionsProvider);
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

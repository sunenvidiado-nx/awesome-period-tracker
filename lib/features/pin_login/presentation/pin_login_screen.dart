import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/extensions/exception_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_loader_dialog.dart';
import 'package:awesome_period_tracker/features/app/application/router_provider.dart';
import 'package:awesome_period_tracker/features/pin_login/domain/auth_repository.dart';
import 'package:awesome_period_tracker/features/pin_login/presentation/widgets/pin_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();

  String? _validationError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SvgPicture.asset(
                  AppAssets.mainIconNoBackground,
                  height: 60,
                ),
                const SizedBox(height: 18),
                Text(
                  context.l10n.pinVerification,
                  style: context.primaryTextTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    context.l10n.toGetStartedEnterTheDesignatedPin,
                    style: context.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PinInputField(
                    controller: _pinController,
                    validator: _validator,
                    onCompleted: _onCompleted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onCompleted(String pin) async {
    if (_formKey.currentState!.validate()) {
      try {
        AppLoaderDialog.show(context);

        await ref.read(authRepositoryProvider).pinLogin(pin);

        // ignore: use_build_context_synchronously
        context.go(Routes.home);
      } on Exception catch (e) {
        _validationError = e.errorMessage;
        _formKey.currentState!.validate();
        _validationError = null;
      } finally {
        // ignore: use_build_context_synchronously
        AppLoaderDialog.hide(context);
      }
    }
  }

  String? _validator(String? value) {
    if (_validationError != null) {
      return _validationError;
    }

    return null;
  }
}

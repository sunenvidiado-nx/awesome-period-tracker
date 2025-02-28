import 'package:awesome_period_tracker/app/routing/routes.dart';
import 'package:awesome_period_tracker/app/theme/app_assets.dart';
import 'package:awesome_period_tracker/config/constants/ui_constants.dart';
import 'package:awesome_period_tracker/data/repositories/auth_repository.dart';
import 'package:awesome_period_tracker/ui/common_widgets/app_loader/app_loader_dialog.dart';
import 'package:awesome_period_tracker/ui/features/pin_login/widgets/pin_input_field.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/exception_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();

  String? _validationError;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: UiConstants.mobileWidth),
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SvgPicture.asset(AppAssets.mainIcon, height: 60),
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
        ),
      ),
    );
  }

  Future<void> _onCompleted(String pin) async {
    if (_formKey.currentState!.validate()) {
      try {
        AppLoaderDialog.show(context);

        await GetIt.I<AuthRepository>().pinLogin(pin);

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
    if (_validationError != null) return _validationError;
    return null;
  }
}

import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/core/widgets/snackbars/app_snackbar.dart';
import 'package:awesome_period_tracker/features/app/application/router.dart';
import 'package:awesome_period_tracker/features/login/application/login_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _stateManager = GetIt.I<LoginStateManager>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32, top: 38),
                    child: SvgPicture.asset(AppAssets.mainIcon, height: 100),
                  ),
                ),
                Text(
                  context.l10n.gladYoureHere,
                  style: context.primaryTextTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    context.l10n.loginToTrackYourCycleAndStayInSync,
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                _buildEmailField(),
                const SizedBox(height: 12),
                _buildPasswordField(),
                const SizedBox(height: 32),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Text(
            context.l10n.forgotAccountPleaseContactTheDeveloper,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(hintText: context.l10n.email),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.l10n.fieldCantBeEmpty;
        }

        if (!value.contains('@')) {
          return context.l10n.enterAValidEmail;
        }

        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(hintText: context.l10n.password),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.l10n.fieldCantBeEmpty;
        }

        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ValueListenableBuilder(
      valueListenable: _stateManager.notifier,
      builder: (context, state, _) {
        return ElevatedButton(
          onPressed: state.isLoading ? null : _onSubmit,
          child: state.isLoading
              ? AppLoader(color: context.colorScheme.surface, size: 30)
              : Text(context.l10n.logIn),
        );
      },
    );
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _stateManager.login(
          _emailController.text,
          _passwordController.text,
        );

        context.go(Routes.root);
      } catch (e) {
        context.showErrorSnackbar();
      }
    }
  }
}

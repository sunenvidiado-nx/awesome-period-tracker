import 'package:awesome_period_tracker/ui/app_assets.dart';
import 'package:awesome_period_tracker/ui/features/login/login_state_manager.dart';
import 'package:awesome_period_tracker/ui/router.dart';
import 'package:awesome_period_tracker/ui/widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/ui/widgets/snackbars/app_snackbar.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
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
    _stateManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 32,
                      top: MediaQuery.of(context).size.height * 0.08,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppAssets.wavingHand, height: 40),
                        const SizedBox(width: 10),
                        Image.asset(AppAssets.cowboyHatFace, height: 40),
                      ],
                    ),
                  ),
                  Text(
                    context.l10n.loginScreenTitle,
                    style: context.primaryTextTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.l10n.loginScreenSubtitle,
                    style: context.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildEmailField(),
                  const SizedBox(height: 12),
                  _buildPasswordField(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.forgotAccountPleaseContactTheDeveloper,
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildLoginButton(),
            ],
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
          onPressed: state is LoadingLoginState ? null : _onSubmit,
          child: state is LoadingLoginState
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

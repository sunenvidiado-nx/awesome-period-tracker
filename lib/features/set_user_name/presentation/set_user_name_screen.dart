import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/core/widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/core/widgets/snackbars/app_snackbar.dart';
import 'package:awesome_period_tracker/features/app/application/router.dart';
import 'package:awesome_period_tracker/features/set_user_name/application/set_user_name_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class SetUserNameScreen extends StatefulWidget {
  const SetUserNameScreen({super.key});

  @override
  State<SetUserNameScreen> createState() => _SetUserNameScreenState();
}

class _SetUserNameScreenState extends State<SetUserNameScreen> {
  final _stateManager = GetIt.I<SetUserNameStateManager>();
  final _userName = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _userName.dispose();
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
                    context.l10n.setUserNameScreenTitle,
                    style: context.primaryTextTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.l10n.setUserNameScreenSubtitle,
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildUserNameField(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: _buildSubmitButton(),
        ),
      ),
    );
  }

  Widget _buildUserNameField() {
    return ValueListenableBuilder(
      valueListenable: _stateManager.notifier,
      builder: (context, state, _) {
        return TextFormField(
          controller: _userName,
          decoration: InputDecoration(
            hintText: context.l10n.username,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.fieldCantBeEmpty;
            }

            if (value.split(' ').length > 1) {
              return context.l10n.userNameShouldBeOneWord;
            }

            return null;
          },
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder(
      valueListenable: _stateManager.notifier,
      builder: (context, state, _) {
        return ElevatedButton(
          onPressed: state.isLoading ? null : _onSubmit,
          child: state.isLoading
              ? AppLoader(color: context.colorScheme.surface, size: 30)
              : Text(context.l10n.setUserName),
        );
      },
    );
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _stateManager.setUserName(_userName.text.trim());
        context.go(Routes.root);
      } catch (e) {
        context.showErrorSnackbar();
      }
    }
  }
}

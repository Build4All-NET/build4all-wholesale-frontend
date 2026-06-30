import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

import '../../../../common/widgets/language_selector.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_text_field.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../../data/services/auth_service.dart';

class RetailerCompleteProfileScreen extends StatefulWidget {
  final int pendingId;
  final String email;
  final String password;

  const RetailerCompleteProfileScreen({
    super.key,
    required this.pendingId,
    required this.email,
    required this.password,
  });

  @override
  State<RetailerCompleteProfileScreen> createState() =>
      _RetailerCompleteProfileScreenState();
}

class _RetailerCompleteProfileScreenState
    extends State<RetailerCompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  bool _isPublicProfile = true;
  bool _isSaving = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_isSaving || _completed) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await sl<AuthService>().completeBuild4AllProfile(
        pendingId: widget.pendingId,
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        isPublicProfile: _isPublicProfile,
      );

      _completed = true;

      if (!mounted) return;

      AppToast.success(context, context.l10n.retailerAccountCreatedPleaseLogin);

      context.go('/login');
      return;
    } catch (e) {
      if (!mounted) return;

      final message = AppErrorMapper.toMessage(e);

      if (message.toLowerCase().contains('username already in use')) {
        AppToast.info(context, context.l10n.accountAlreadyCreatedPleaseLogin);

        context.go('/login');
        return;
      }

      AppToast.error(context, message);
    } finally {
      if (mounted && !_completed) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        title: Text(context.l10n.completeProfile),
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 8),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppThemeTokens.radiusLarge),
                  side: const BorderSide(color: AppThemeTokens.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            context.l10n.completeProfile,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppThemeTokens.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            context.l10n.finishAccountSetup,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppThemeTokens.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        Text(context.l10n.username),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _usernameController,
                          hintText: context.l10n.enterUsername,
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: context.l10n.username,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(context.l10n.firstName),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _firstNameController,
                          hintText: context.l10n.enterFirstName,
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: context.l10n.firstName,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(context.l10n.lastName),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _lastNameController,
                          hintText: context.l10n.enterLastName,
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: context.l10n.lastName,
                          ),
                        ),

                        const SizedBox(height: 16),

                        SwitchListTile(
                          value: _isPublicProfile,
                          onChanged: _isSaving
                              ? null
                              : (value) {
                                  setState(() => _isPublicProfile = value);
                                },
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.l10n.publicProfile),
                        ),

                        const SizedBox(height: 24),

                        PrimaryButton(
                          text: context.l10n.saveAndContinue,
                          isLoading: _isSaving,
                          onPressed: _isSaving ? null : _saveProfile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

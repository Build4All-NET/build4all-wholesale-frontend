import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/primary_text_field.dart';
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
  final _namesFormKey = GlobalKey<FormState>();
  final _usernameFormKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;

  int _step = 0;
  bool _isPublicProfile = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_step == 0) {
      if (!_namesFormKey.currentState!.validate()) return;
      setState(() => _step = 1);
      return;
    }

    if (_step == 1) {
      if (!_usernameFormKey.currentState!.validate()) return;
      setState(() => _step = 2);
    }
  }

  void _goPrevious() {
    if (_step > 0) {
      setState(() => _step -= 1);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final authService = sl<AuthService>();

      final completed = await authService.completeBuild4AllProfile(
        pendingId: widget.pendingId,
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        isPublicProfile: _isPublicProfile,
      );

      final user = Map<String, dynamic>.from(completed['user'] as Map);
      final build4allUserId = user['id'] is int
          ? user['id'] as int
          : int.parse(user['id'].toString());

      await authService.syncRetailerFromBuild4All(
        build4allUserId: build4allUserId,
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: widget.email,
        password: widget.password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please login.'),
        ),
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _stepBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildNamesStep() {
    return Form(
      key: _namesFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepBadge('1 / 3'),
          const SizedBox(height: 18),
          const Text(
            'Complete Your Profile - Names',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please provide your first and last name.',
            style: TextStyle(
              fontSize: 16,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          PrimaryTextField(
            controller: _firstNameController,
            hintText: 'First name',
            validator: (value) =>
                Validators.requiredField(value, fieldName: 'First name'),
          ),
          const SizedBox(height: 16),
          PrimaryTextField(
            controller: _lastNameController,
            hintText: 'Last name',
            validator: (value) =>
                Validators.requiredField(value, fieldName: 'Last name'),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Next Step',
            onPressed: _goNext,
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameStep() {
    return Form(
      key: _usernameFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepBadge('2 / 3'),
          const SizedBox(height: 18),
          const Text(
            'Complete Your Profile - Username',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a unique username for your account.',
            style: TextStyle(
              fontSize: 16,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          PrimaryTextField(
            controller: _usernameController,
            hintText: 'Username',
            validator: (value) =>
                Validators.requiredField(value, fieldName: 'Username'),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            value: _isPublicProfile,
            onChanged: (value) {
              setState(() {
                _isPublicProfile = value;
              });
            },
            title: const Text(
              'Public profile',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            subtitle: const Text(
              'If enabled, your profile can be found by other users.',
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _goPrevious,
                  child: const Text('Previous Step'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Next Step',
                  onPressed: _goNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepBadge('3 / 3'),
        const SizedBox(height: 18),
        const Text(
          'Complete Your Profile - Photo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add a profile picture later if you want. This step is optional.',
          style: TextStyle(
            fontSize: 16,
            color: AppThemeTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              color: Color(0xFFF8E8F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 80,
              color: Color(0xFF8F0F56),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Photo upload is optional and can be added later.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppThemeTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _goPrevious,
                child: const Text('Previous Step'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: 'Save profile',
                isLoading: _isSaving,
                onPressed: _saveProfile,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_step == 0) {
      child = _buildNamesStep();
    } else if (_step == 1) {
      child = _buildUsernameStep();
    } else {
      child = _buildPhotoStep();
    }

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppThemeTokens.radiusLarge,
                  ),
                  side: const BorderSide(color: AppThemeTokens.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
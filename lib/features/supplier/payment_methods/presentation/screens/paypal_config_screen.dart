import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../bloc/supplier_payment_methods_bloc.dart';
import '../bloc/supplier_payment_methods_event.dart';
import '../bloc/supplier_payment_methods_state.dart';

class PayPalConfigScreen extends StatefulWidget {
  final Map<String, dynamic> currentConfigValues;
  final bool currentlyEnabled;

  const PayPalConfigScreen({
    super.key,
    required this.currentConfigValues,
    required this.currentlyEnabled,
  });

  @override
  State<PayPalConfigScreen> createState() => _PayPalConfigScreenState();
}

class _PayPalConfigScreenState extends State<PayPalConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _clientIdCtrl;
  late final TextEditingController _clientSecretCtrl;
  late final TextEditingController _returnUrlCtrl;
  late final TextEditingController _cancelUrlCtrl;
  late final TextEditingController _brandNameCtrl;
  late bool _enabled;
  late String _mode;
  late final bool _clientIdAlreadyConfigured;
  late final bool _clientSecretAlreadyConfigured;

  bool _clientSecretObscured = true;

  @override
  void initState() {
    super.initState();
    final cfg = widget.currentConfigValues;
    _clientIdAlreadyConfigured = cfg['clientIdConfigured'] == true;
    _clientSecretAlreadyConfigured = cfg['clientSecretConfigured'] == true;
    _clientIdCtrl = TextEditingController(
      text: _clientIdAlreadyConfigured ? '' : _safe(cfg['clientId']),
    );
    _clientSecretCtrl = TextEditingController(
      text: _clientSecretAlreadyConfigured ? '' : _safe(cfg['clientSecret']),
    );
    _returnUrlCtrl = TextEditingController(
      text: _safe(cfg['returnUrl']).isEmpty
          ? 'https://example.com/paypal/return'
          : _safe(cfg['returnUrl']),
    );
    _cancelUrlCtrl = TextEditingController(
      text: _safe(cfg['cancelUrl']).isEmpty
          ? 'https://example.com/paypal/cancel'
          : _safe(cfg['cancelUrl']),
    );
    _brandNameCtrl = TextEditingController(
      text: _safe(cfg['brandName']).isEmpty
          ? 'Build4All Wholesale'
          : _safe(cfg['brandName']),
    );
    _mode = _safe(cfg['mode']).isEmpty ? 'SANDBOX' : _safe(cfg['mode']).toUpperCase();
    _enabled = widget.currentlyEnabled;
  }

  @override
  void dispose() {
    _clientIdCtrl.dispose();
    _clientSecretCtrl.dispose();
    _returnUrlCtrl.dispose();
    _cancelUrlCtrl.dispose();
    _brandNameCtrl.dispose();
    super.dispose();
  }

  static String _safe(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text == 'null' ? '' : text;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final bg = theme.scaffoldBackgroundColor;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final outline = theme.colorScheme.outline;
    final error = theme.colorScheme.error;

    return BlocConsumer<SupplierPaymentMethodsBloc, SupplierPaymentMethodsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage ||
          previous.testResultMessage != current.testResultMessage ||
          previous.testResultMethodCode != current.testResultMethodCode,
      listener: (ctx, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: error),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state.savingMethodCode == 'PAYPAL';
        final isTesting = state.testingMethodCode == 'PAYPAL';

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              l10n.payPalConfigTitle,
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoBanner(
                    text: l10n.payPalInfoBanner,
                    primary: primary,
                  ),
                  const SizedBox(height: 24),
                  _Card(
                    surface: surface,
                    outline: outline,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.payPalEnableLabel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.payPalEnableSubtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _enabled,
                          activeColor: primary,
                          onChanged: (value) => setState(() => _enabled = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.payPalCredentialsTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Card(
                    surface: surface,
                    outline: outline,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _mode,
                          items: [
                            DropdownMenuItem(
                              value: 'SANDBOX',
                              child: Text(l10n.payPalModeSandbox),
                            ),
                            DropdownMenuItem(
                              value: 'LIVE',
                              child: Text(l10n.payPalModeLive),
                            ),
                          ],
                          onChanged: (value) => setState(() => _mode = value ?? 'SANDBOX'),
                          decoration: InputDecoration(
                            labelText: l10n.payPalModeLabel,
                            helperText: l10n.payPalModeHelper,
                            helperMaxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _clientIdCtrl,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return _clientIdAlreadyConfigured
                                  ? null
                                  : l10n.payPalClientIdRequired;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: l10n.payPalClientIdLabel,
                            hintText: l10n.payPalClientIdHint,
                            helperText: _clientIdAlreadyConfigured
                                ? l10n.paymentCredentialAlreadyConfiguredHelper
                                : l10n.payPalClientIdHelper,
                            helperMaxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _clientSecretCtrl,
                          obscureText: _clientSecretObscured,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return _clientSecretAlreadyConfigured
                                  ? null
                                  : l10n.payPalClientSecretRequired;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: l10n.payPalClientSecretLabel,
                            hintText: l10n.payPalClientSecretHint,
                            helperText: _clientSecretAlreadyConfigured
                                ? l10n.paymentCredentialAlreadyConfiguredHelper
                                : l10n.payPalClientSecretHelper,
                            helperMaxLines: 2,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _clientSecretObscured
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _clientSecretObscured = !_clientSecretObscured,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _returnUrlCtrl,
                          validator: _urlValidator,
                          decoration: InputDecoration(
                            labelText: l10n.payPalReturnUrlLabel,
                            helperText: l10n.payPalReturnUrlHelper,
                            helperMaxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _cancelUrlCtrl,
                          validator: _urlValidator,
                          decoration: InputDecoration(
                            labelText: l10n.payPalCancelUrlLabel,
                            helperText: l10n.payPalCancelUrlHelper,
                            helperMaxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _brandNameCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.payPalBrandNameLabel,
                            helperText: l10n.payPalBrandNameHelper,
                            helperMaxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (state.testResultMethodCode == 'PAYPAL' &&
                      state.testResultMessage != null) ...[
                    _TestResultBanner(
                      success: state.testResultSuccess ?? false,
                      message: state.testResultMessage!,
                      errorColor: error,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isSaving || isTesting ? null : _onTest,
                          icon: isTesting
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primary,
                                  ),
                                )
                              : const Icon(Icons.wifi_tethering_rounded),
                          label: Text(
                            isTesting ? l10n.payPalTesting : l10n.payPalTestButton,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: isSaving || isTesting ? null : _onSave,
                          icon: isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            isSaving ? l10n.payPalSaving : l10n.payPalSaveButton,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String? _urlValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.l10n.payPalUrlRequired;
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return context.l10n.payPalUrlInvalid;
    }
    return null;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final configValues = <String, dynamic>{
      'clientId': _clientIdCtrl.text.trim(),
      'clientSecret': _clientSecretCtrl.text.trim(),
      'mode': _mode,
      'returnUrl': _returnUrlCtrl.text.trim(),
      'cancelUrl': _cancelUrlCtrl.text.trim(),
    };

    final brandName = _brandNameCtrl.text.trim();
    if (brandName.isNotEmpty) configValues['brandName'] = brandName;

    context.read<SupplierPaymentMethodsBloc>().add(
          SupplierPaymentMethodConfigSaved(
            methodCode: 'PAYPAL',
            enabled: _enabled,
            configValues: configValues,
          ),
        );
  }

  void _onTest() {
    context.read<SupplierPaymentMethodsBloc>().add(
          const SupplierPaymentMethodTested(methodCode: 'PAYPAL'),
        );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  final Color primary;

  const _InfoBanner({required this.text, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w700,
                height: 1.4,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color surface;
  final Color outline;

  const _Card({
    required this.child,
    required this.surface,
    required this.outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TestResultBanner extends StatelessWidget {
  final bool success;
  final String message;
  final Color errorColor;

  const _TestResultBanner({
    required this.success,
    required this.message,
    required this.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = success ? const Color(0xFF16A34A) : errorColor;
    final icon = success ? Icons.check_circle_outline : Icons.error_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

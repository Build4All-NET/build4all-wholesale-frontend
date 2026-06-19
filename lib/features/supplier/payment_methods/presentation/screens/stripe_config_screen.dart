import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../shared/utils/supplier_success_message_localizer.dart';
import '../bloc/supplier_payment_methods_bloc.dart';
import '../bloc/supplier_payment_methods_event.dart';
import '../bloc/supplier_payment_methods_state.dart';

/// Stripe credentials configuration screen for the supplier.
///
/// Opened from the Payment Methods screen via the Configure button on the
/// Stripe card. Uses [context.l10n] for all visible text and
/// [Theme.of(context)] for all colours so it respects the runtime theme
/// and locale correctly.
class StripeConfigScreen extends StatefulWidget {
  final Map<String, dynamic> currentConfigValues;
  final bool currentlyEnabled;

  const StripeConfigScreen({
    super.key,
    required this.currentConfigValues,
    required this.currentlyEnabled,
  });

  @override
  State<StripeConfigScreen> createState() => _StripeConfigScreenState();
}

class _StripeConfigScreenState extends State<StripeConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _secretKeyCtrl;
  late final TextEditingController _publishableKeyCtrl;
  late final TextEditingController _webhookSecretCtrl;
  late bool _enabled;
  late final bool _secretKeyAlreadyConfigured;
  late final bool _webhookSecretAlreadyConfigured;

  bool _secretObscured = true;
  bool _webhookObscured = true;

  bool _showTestResultBanner = false;

  @override
  void initState() {
    super.initState();
    final cfg = widget.currentConfigValues;
    _secretKeyAlreadyConfigured = cfg['secretKeyConfigured'] == true;
    _webhookSecretAlreadyConfigured = cfg['webhookSecretConfigured'] == true;
    _secretKeyCtrl = TextEditingController(
      text: _secretKeyAlreadyConfigured ? '' : _safe(cfg['secretKey']),
    );
    _publishableKeyCtrl = TextEditingController(text: _safe(cfg['publishableKey']));
    _webhookSecretCtrl = TextEditingController(
      text: _webhookSecretAlreadyConfigured ? '' : _safe(cfg['webhookSecret']),
    );
    _enabled = widget.currentlyEnabled;
  }

  @override
  void dispose() {
    _secretKeyCtrl.dispose();
    _publishableKeyCtrl.dispose();
    _webhookSecretCtrl.dispose();
    super.dispose();
  }

  static String _safe(dynamic v) {
    final s = (v?.toString() ?? '').trim();
    return s == 'null' ? '' : s;
  }

  // ─────────────────────────────────────────────────────────── build ──

  @override
  Widget build(BuildContext context) {
    final l10n    = context.l10n;
    final theme   = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final bg      = theme.scaffoldBackgroundColor;
    final surface = theme.colorScheme.surface;
    final onSurface       = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final outline = theme.colorScheme.outline;
    final error   = theme.colorScheme.error;

    return BlocConsumer<SupplierPaymentMethodsBloc, SupplierPaymentMethodsState>(
      listenWhen: (p, c) =>
          p.errorMessage   != c.errorMessage   ||
          p.successMessage != c.successMessage ||
          p.testResultMessage != c.testResultMessage ||
          p.testResultMethodCode != c.testResultMethodCode,
      listener: (context, state) {
        if (state.testResultMethodCode == 'STRIPE' &&
            state.testResultMessage != null &&
            !_showTestResultBanner) {
          setState(() => _showTestResultBanner = true);
        }
      },
      builder: (context, state) {
        final isSaving  = state.savingMethodCode  == 'STRIPE';
        final isTesting = state.testingMethodCode == 'STRIPE';

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
              l10n.stripeConfigTitle,
              style: TextStyle(
                  color: primary, fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Info banner ──
                  Container(
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
                            l10n.stripeInfoBanner,
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
                  ),
                  const SizedBox(height: 24),

                  // ── Enable toggle ──
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
                                l10n.stripeEnableLabel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.stripeEnableSubtitle,
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
                          onChanged: (v) {
                            setState(() {
                              _enabled = v;
                              if (!v) {
                                _showTestResultBanner = false;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Credentials title ──
                  Text(
                    l10n.stripeCredentialsTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Fields ──
                  _Card(
                    surface: surface,
                    outline: outline,
                    child: Column(
                      children: [
                        // Secret Key
                        TextFormField(
                          controller: _secretKeyCtrl,
                          obscureText: _secretObscured,
                          validator: (v) {
                            final text = v?.trim() ?? '';
                            if (text.isEmpty) {
                              return _secretKeyAlreadyConfigured
                                  ? null
                                  : l10n.stripeSecretKeyRequired;
                            }
                            if (!text.startsWith('sk_')) {
                              return l10n.stripeSecretKeyInvalid;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: l10n.stripeSecretKeyLabel,
                            hintText: 'sk_test_... or sk_live_...',
                            helperText: _secretKeyAlreadyConfigured
                                ? l10n.paymentCredentialAlreadyConfiguredHelper
                                : l10n.stripeSecretKeyHelper,
                            helperMaxLines: 2,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _secretObscured
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _secretObscured = !_secretObscured),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Publishable Key
                        TextFormField(
                          controller: _publishableKeyCtrl,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return l10n.stripePublishableKeyRequired;
                            if (!v.trim().startsWith('pk_'))
                              return l10n.stripePublishableKeyInvalid;
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: l10n.stripePublishableKeyLabel,
                            hintText: 'pk_test_... or pk_live_...',
                            helperText: l10n.stripePublishableKeyHelper,
                            helperMaxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Webhook Secret (optional)
                        TextFormField(
                          controller: _webhookSecretCtrl,
                          obscureText: _webhookObscured,
                          decoration: InputDecoration(
                            labelText: l10n.stripeWebhookSecretLabel,
                            hintText: 'whsec_...',
                            helperText: _webhookSecretAlreadyConfigured
                                ? l10n.paymentCredentialAlreadyConfiguredHelper
                                : l10n.stripeWebhookSecretHelper,
                            helperMaxLines: 2,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _webhookObscured
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _webhookObscured = !_webhookObscured),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Test result banner ──
                  if (_enabled &&
                      _showTestResultBanner &&
                      state.testResultMethodCode == 'STRIPE' &&
                      state.testResultMessage != null) ...[
                    _TestResultBanner(
                      success: state.testResultSuccess ?? false,
                      message: localizeSupplierPaymentMessage(
                        context,
                        state.testResultMessage!,
                      ),
                      errorColor: error,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Action buttons ──
                  Row(
                    children: [
                      // Test
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isSaving || isTesting ? null : _onTest,
                          icon: isTesting
                              ? SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: primary))
                              : const Icon(Icons.wifi_tethering_rounded),
                          label: Text(
                            isTesting ? l10n.stripeTesting : l10n.stripeTestButton,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Save
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: isSaving || isTesting ? null : _onSave,
                          icon: isSaving
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            isSaving ? l10n.stripeSaving : l10n.stripeSaveButton,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
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

  // ─────────────────────────────────────────────────────────── actions ──

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _showTestResultBanner = false);

    final configValues = <String, dynamic>{
      'publishableKey': _publishableKeyCtrl.text.trim(),
    };

    final secretKey = _secretKeyCtrl.text.trim();
    if (secretKey.isNotEmpty) {
      configValues['secretKey'] = secretKey;
    }

    final webhook = _webhookSecretCtrl.text.trim();
    if (webhook.isNotEmpty) configValues['webhookSecret'] = webhook;

    context.read<SupplierPaymentMethodsBloc>().add(
          SupplierPaymentMethodConfigSaved(
            methodCode: 'STRIPE',
            enabled: _enabled,
            configValues: configValues,
          ),
        );
  }

  void _onTest() {
    if (!_enabled) {
      setState(() => _showTestResultBanner = false);
      AppToast.warning(context, context.l10n.paymentMethodTestEnableFirst);
      return;
    }

    setState(() => _showTestResultBanner = false);

    context.read<SupplierPaymentMethodsBloc>().add(
          const SupplierPaymentMethodTested(methodCode: 'STRIPE'),
        );
  }
}

// ─────────────────────────────────────────────────── sub-widgets ──

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
    final icon  = success ? Icons.check_circle_outline : Icons.error_outline;

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
                  color: color, fontWeight: FontWeight.w700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
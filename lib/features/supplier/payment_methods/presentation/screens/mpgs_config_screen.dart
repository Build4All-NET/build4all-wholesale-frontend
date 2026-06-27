import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/currency/currency_formatter.dart';
import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../shared/utils/supplier_success_message_localizer.dart';
import '../bloc/supplier_payment_methods_bloc.dart';
import '../bloc/supplier_payment_methods_event.dart';
import '../bloc/supplier_payment_methods_state.dart';

class MpgsConfigScreen extends StatefulWidget {
  final Map<String, dynamic> currentConfigValues;
  final bool currentlyEnabled;

  const MpgsConfigScreen({
    super.key,
    required this.currentConfigValues,
    required this.currentlyEnabled,
  });

  @override
  State<MpgsConfigScreen> createState() => _MpgsConfigScreenState();
}

class _MpgsConfigScreenState extends State<MpgsConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _merchantIdCtrl;
  late final TextEditingController _apiPasswordCtrl;
  late final TextEditingController _apiBaseUrlCtrl;
  late final TextEditingController _currencyCtrl;
  late final TextEditingController _brandNameCtrl;
  late bool _enabled;
  late String _mode;
  late final bool _merchantIdAlreadyConfigured;
  late final bool _apiPasswordAlreadyConfigured;

  bool _apiPasswordObscured = true;

  bool _showTestResultBanner = false;

  @override
  void initState() {
    super.initState();
    final cfg = widget.currentConfigValues;
    _merchantIdAlreadyConfigured = cfg['merchantIdConfigured'] == true;
    _apiPasswordAlreadyConfigured = cfg['apiPasswordConfigured'] == true;
    _merchantIdCtrl = TextEditingController(
      text: _merchantIdAlreadyConfigured ? '' : _safe(cfg['merchantId']),
    );
    _apiPasswordCtrl = TextEditingController(
      text: _apiPasswordAlreadyConfigured ? '' : _safe(cfg['apiPassword']),
    );
    _apiBaseUrlCtrl = TextEditingController(
      text: _safe(cfg['apiBaseUrl']).isEmpty
          ? 'https://test-bobsal.gateway.mastercard.com'
          : _safe(cfg['apiBaseUrl']),
    );
    _currencyCtrl = TextEditingController(
      text: _safe(cfg['currency']).isEmpty
          ? CurrencyFormatter.runtimeCode()
          : _safe(cfg['currency']).toUpperCase(),
    );
    _brandNameCtrl = TextEditingController(
      text: _safe(cfg['brandName']).isEmpty
          ? 'Build4All Wholesale'
          : _safe(cfg['brandName']),
    );
    _mode = _safe(cfg['mode']).isEmpty ? 'TEST' : _safe(cfg['mode']).toUpperCase();
    _enabled = widget.currentlyEnabled;
  }

  @override
  void dispose() {
    _merchantIdCtrl.dispose();
    _apiPasswordCtrl.dispose();
    _apiBaseUrlCtrl.dispose();
    _currencyCtrl.dispose();
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
      listener: (context, state) {
        if (state.testResultMethodCode == 'MPGS' &&
            state.testResultMessage != null &&
            !_showTestResultBanner) {
          setState(() => _showTestResultBanner = true);
        }
      },
      builder: (context, state) {
        final isSaving = state.savingMethodCode == 'MPGS';
        final isTesting = state.testingMethodCode == 'MPGS';

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
              l10n.mpgsConfigTitle,
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
                  _InfoBanner(text: l10n.mpgsInfoBanner, primary: primary),
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
                                l10n.mpgsEnableLabel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.mpgsEnableSubtitle,
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
                          onChanged: (value) {
                            setState(() {
                              _enabled = value;
                              if (!value) {
                                _showTestResultBanner = false;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.mpgsCredentialsTitle,
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
                            DropdownMenuItem(value: 'TEST', child: Text(l10n.mpgsModeTest)),
                            DropdownMenuItem(value: 'LIVE', child: Text(l10n.mpgsModeLive)),
                          ],
                          onChanged: (value) => setState(() => _mode = value ?? 'TEST'),
                          decoration: InputDecoration(
                            labelText: l10n.mpgsModeLabel,
                            helperText: l10n.mpgsModeHelper,
                            helperMaxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _merchantIdCtrl,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return _merchantIdAlreadyConfigured
                                  ? null
                                  : l10n.mpgsMerchantIdRequired;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: l10n.mpgsMerchantIdLabel,
                            hintText: l10n.mpgsMerchantIdHint,
                            helperText: _merchantIdAlreadyConfigured
                                ? l10n.paymentCredentialAlreadyConfiguredHelper
                                : l10n.mpgsMerchantIdHelper,
                            helperMaxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _apiPasswordCtrl,
                          obscureText: _apiPasswordObscured,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return _apiPasswordAlreadyConfigured
                                  ? null
                                  : l10n.mpgsApiPasswordRequired;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: l10n.mpgsApiPasswordLabel,
                            hintText: l10n.mpgsApiPasswordHint,
                            helperText: _apiPasswordAlreadyConfigured
                                ? l10n.paymentCredentialAlreadyConfiguredHelper
                                : l10n.mpgsApiPasswordHelper,
                            helperMaxLines: 2,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _apiPasswordObscured
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _apiPasswordObscured = !_apiPasswordObscured,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _apiBaseUrlCtrl,
                          validator: _urlValidator,
                          decoration: InputDecoration(
                            labelText: l10n.mpgsApiBaseUrlLabel,
                            helperText: l10n.mpgsApiBaseUrlHelper,
                            helperMaxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _currencyCtrl,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return l10n.mpgsCurrencyRequired;
                            if (text.length != 3) return l10n.mpgsCurrencyRequired;
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: l10n.mpgsCurrencyLabel,
                            helperText: l10n.mpgsCurrencyHelper,
                            helperMaxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _brandNameCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.mpgsBrandNameLabel,
                            helperText: l10n.mpgsBrandNameHelper,
                            helperMaxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_enabled &&
                      _showTestResultBanner &&
                      state.testResultMethodCode == 'MPGS' &&
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
                            isTesting ? l10n.mpgsTesting : l10n.mpgsTestButton,
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
                            isSaving ? l10n.mpgsSaving : l10n.mpgsSaveButton,
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
    if (text.isEmpty) return context.l10n.mpgsUrlRequired;
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return context.l10n.mpgsUrlInvalid;
    }
    return null;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _showTestResultBanner = false);

    final configValues = <String, dynamic>{
      'apiBaseUrl': _apiBaseUrlCtrl.text.trim(),
      'mode': _mode,
      'currency': _currencyCtrl.text.trim().toUpperCase(),
    };

    final merchantId = _merchantIdCtrl.text.trim();
    if (merchantId.isNotEmpty) {
      configValues['merchantId'] = merchantId;
    }

    final apiPassword = _apiPasswordCtrl.text.trim();
    if (apiPassword.isNotEmpty) {
      configValues['apiPassword'] = apiPassword;
    }

    final brandName = _brandNameCtrl.text.trim();
    if (brandName.isNotEmpty) configValues['brandName'] = brandName;

    context.read<SupplierPaymentMethodsBloc>().add(
          SupplierPaymentMethodConfigSaved(
            methodCode: 'MPGS',
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
          const SupplierPaymentMethodTested(methodCode: 'MPGS'),
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

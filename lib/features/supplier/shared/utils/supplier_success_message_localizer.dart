import 'package:flutter/widgets.dart';

import '../../../../core/extensions/l10n_extension.dart';

String localizeSupplierSuccessMessage(BuildContext context, String messageKey) {
  switch (messageKey) {
    case 'promotionCreatedSuccessfully':
      return context.l10n.promotionCreatedSuccessfully;
    case 'promotionUpdatedSuccessfully':
      return context.l10n.promotionUpdatedSuccessfully;
    case 'promotionDeletedSuccessfully':
      return context.l10n.promotionDeletedSuccessfully;
    case 'couponCreatedSuccessfully':
      return context.l10n.couponCreatedSuccessfully;
    case 'couponUpdatedSuccessfully':
      return context.l10n.couponUpdatedSuccessfully;
    case 'couponDeletedSuccessfully':
      return context.l10n.couponDeletedSuccessfully;
    case 'bannerCreatedSuccessfully':
      return context.l10n.bannerCreatedSuccessfully;
    case 'bannerUpdatedSuccessfully':
      return context.l10n.bannerUpdatedSuccessfully;
    case 'bannerDeletedSuccessfully':
      return context.l10n.bannerDeletedSuccessfully;
    case 'shippingMethodCreatedSuccessfully':
      return context.l10n.shippingMethodCreatedSuccessfully;
    case 'shippingMethodUpdatedSuccessfully':
      return context.l10n.shippingMethodUpdatedSuccessfully;
    case 'shippingMethodDeletedSuccessfully':
      return context.l10n.shippingMethodDeletedSuccessfully;
    case 'taxRuleCreatedSuccessfully':
      return context.l10n.taxRuleCreatedSuccessfully;
    case 'taxRuleUpdatedSuccessfully':
      return context.l10n.taxRuleUpdatedSuccessfully;
    case 'taxRuleDeletedSuccessfully':
      return context.l10n.taxRuleDeletedSuccessfully;
    default:
      return localizeSupplierPaymentMessage(context, messageKey);
  }
}

String localizeSupplierPaymentMessage(BuildContext context, String message) {
  final clean = message.trim();
  final methodName = _extractPaymentMethodName(clean);

  if (clean == 'Payment method not found.') {
    return context.l10n.paymentMethodNotFoundMessage;
  }

  if (clean.endsWith(' configuration saved successfully.')) {
    return context.l10n.paymentMethodConfigurationSavedSuccessfully(methodName);
  }

  if (clean.endsWith(' enabled successfully.')) {
    return context.l10n.paymentMethodEnabledSuccessfully(methodName);
  }

  if (clean.endsWith(' disabled successfully.')) {
    return context.l10n.paymentMethodDisabledSuccessfully(methodName);
  }

  if (clean.contains('requires credentials.')) {
    return context.l10n.paymentMethodRequiresCredentialsMessage(methodName);
  }

  if (clean == 'Stripe configuration is valid and ready for sandbox payment start.') {
    return context.l10n.paymentTestStripeReadySandbox;
  }

  if (clean == 'PayPal configuration is valid and ready for sandbox payment start.') {
    return context.l10n.paymentTestPayPalReadySandbox;
  }

  if (clean ==
      'Credit / Debit Card configuration is valid and ready for MPGS hosted checkout.') {
    return context.l10n.paymentTestMpgsReady;
  }

  if (clean ==
      'Credit / Debit Card connection test could not be completed. The saved credentials can still be used by checkout to prepare hosted payment.') {
    return context.l10n.paymentTestMpgsConnectionCouldNotComplete;
  }

  if (clean == 'Credit / Debit Card is not enabled for this supplier.') {
    return context.l10n.paymentTestMpgsNotEnabled;
  }

  if (clean == 'Stripe is not enabled for this supplier.') {
    return context.l10n.paymentTestStripeNotEnabled;
  }

  if (clean == 'PayPal is not enabled for this supplier.') {
    return context.l10n.paymentTestPayPalNotEnabled;
  }

  return clean;
}

String _extractPaymentMethodName(String message) {
  if (message.startsWith('Credit / Debit Card')) {
    return 'Credit / Debit Card';
  }
  if (message.startsWith('Stripe')) {
    return 'Stripe';
  }
  if (message.startsWith('PayPal')) {
    return 'PayPal';
  }
  if (message.endsWith(' configuration saved successfully.')) {
    return message.replaceFirst(' configuration saved successfully.', '').trim();
  }
  if (message.endsWith(' enabled successfully.')) {
    return message.replaceFirst(' enabled successfully.', '').trim();
  }
  if (message.endsWith(' disabled successfully.')) {
    return message.replaceFirst(' disabled successfully.', '').trim();
  }
  if (message.contains(' requires credentials.')) {
    return message.split(' requires credentials.').first.trim();
  }
  return message;
}

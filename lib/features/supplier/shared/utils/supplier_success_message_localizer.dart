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
      return messageKey;
  }
}

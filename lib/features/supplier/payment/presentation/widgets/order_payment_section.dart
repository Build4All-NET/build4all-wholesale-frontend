import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../shared/utils/supplier_formatters.dart';
import '../../domain/entities/order_payment_entity.dart';

class OrderPaymentSection extends StatelessWidget {
  final String paymentMethodFromOrder;
  final OrderPaymentEntity? payment;
  final bool isLoading;
  final bool isUpdating;
  final VoidCallback onRefresh;
  final VoidCallback onMarkCashAsPaid;

  const OrderPaymentSection({
    super.key,
    required this.paymentMethodFromOrder,
    required this.payment,
    required this.isLoading,
    required this.isUpdating,
    required this.onRefresh,
    required this.onMarkCashAsPaid,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final canMarkPaid = payment?.canMarkCashAsPaid ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  color: primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(context, 'Payment'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t(context, 'Cash collection and payment status'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: _t(context, 'Refresh'),
                onPressed: isLoading || isUpdating ? null : onRefresh,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _PaymentStatusBanner(payment: payment),
          const SizedBox(height: 16),
          _PaymentInfoRow(
            label: _t(context, 'Method'),
            value: _paymentMethodLabel(context),
          ),
          const SizedBox(height: 12),
          _PaymentInfoRow(
            label: _t(context, 'State'),
            value: _paymentStateLabel(context),
            valueColor: _paymentStateColor(context),
          ),
          const SizedBox(height: 12),
          _PaymentInfoRow(
            label: _t(context, 'Latest status'),
            value: _latestStatusLabel(context),
            valueColor: _latestStatusColor(context),
          ),
          if ((payment?.providerPaymentId ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _PaymentInfoRow(
              label: _t(context, 'Reference'),
              value: payment!.providerPaymentId!,
            ),
          ],
          const SizedBox(height: 12),
          _PaymentInfoRow(
            label: _t(context, 'Paid'),
            value: formatSupplierCurrency(context, payment?.paidAmount ?? 0),
          ),
          const SizedBox(height: 12),
          _PaymentInfoRow(
            label: _t(context, 'Remaining'),
            value: formatSupplierCurrency(
              context,
              payment?.remainingAmount ?? payment?.orderTotal ?? 0,
            ),
            valueColor: (payment?.fullyPaid ?? false)
                ? Colors.green.shade700
                : AppThemeTokens.textPrimary,
          ),
          if (payment?.transactionUpdatedAt != null) ...[
            const SizedBox(height: 12),
            _PaymentInfoRow(
              label: _t(context, 'Updated'),
              value: formatSupplierCompactDateTime(
                context,
                payment!.transactionUpdatedAt!,
              ),
            ),
          ],
          if (canMarkPaid) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isUpdating ? null : onMarkCashAsPaid,
                icon: isUpdating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.task_alt),
                label: Text(
                  isUpdating
                      ? _t(context, 'Updating...')
                      : _t(context, 'Mark Cash as Paid'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusSmall,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _paymentMethodLabel(BuildContext context) {
    final method = (payment?.paymentMethod ?? paymentMethodFromOrder).trim();
    final normalized = method.toUpperCase().replaceAll(' ', '_');

    switch (normalized) {
      case 'CASH':
      case 'CASH_ON_DELIVERY':
      case 'COD':
        return _t(context, 'Cash on Delivery');
      case 'CARD':
      case 'CREDIT_CARD':
      case 'DEBIT_CARD':
        return _t(context, 'Card');
      case 'STRIPE':
        return _t(context, 'Card / Stripe');
      case 'BANK_TRANSFER':
        return _t(context, 'Bank Transfer');
      default:
        return method.isEmpty ? _t(context, 'Not provided') : method;
    }
  }

  String _paymentStateLabel(BuildContext context) {
    final state = payment?.paymentState?.trim().toUpperCase();

    switch (state) {
      case 'PAID':
        return _t(context, 'Paid');
      case 'PARTIALLY_PAID':
        return _t(context, 'Partially paid');
      case 'FAILED':
        return _t(context, 'Failed');
      case 'UNPAID':
        return _t(context, 'Unpaid');
      default:
        return payment == null ? _t(context, 'No payment yet') : state ?? '-';
    }
  }

  String _latestStatusLabel(BuildContext context) {
    final status = payment?.latestPaymentStatus?.trim().toUpperCase();

    switch (status) {
      case 'OFFLINE_PENDING':
        return _t(context, 'Pending cash collection');
      case 'REQUIRES_PAYMENT_METHOD':
        return _t(context, 'Requires payment method');
      case 'REQUIRES_CONFIRMATION':
        return _t(context, 'Requires confirmation');
      case 'REQUIRES_ACTION':
        return _t(context, 'Requires retailer action');
      case 'PROCESSING':
        return _t(context, 'Processing');
      case 'SUCCEEDED':
      case 'PAID':
        return _t(context, 'Paid');
      case 'FAILED':
        return _t(context, 'Failed');
      case 'CANCELLED':
      case 'CANCELED':
        return _t(context, 'Cancelled');
      default:
        return status == null || status.isEmpty
            ? _t(context, 'No transaction')
            : _humanizeStatus(status);
    }
  }

  Color _paymentStateColor(BuildContext context) {
    final state = payment?.paymentState?.trim().toUpperCase();

    if (state == 'PAID') return Colors.green.shade700;
    if (state == 'FAILED') return AppThemeTokens.error;
    return AppThemeTokens.textPrimary;
  }

  Color _latestStatusColor(BuildContext context) {
    final status = payment?.latestPaymentStatus?.trim().toUpperCase();

    if (status == 'PAID' || status == 'SUCCEEDED') return Colors.green.shade700;
    if (status == 'FAILED' || status == 'CANCELED' || status == 'CANCELLED') {
      return AppThemeTokens.error;
    }
    if (status == 'OFFLINE_PENDING' ||
        status == 'REQUIRES_PAYMENT_METHOD' ||
        status == 'REQUIRES_CONFIRMATION' ||
        status == 'REQUIRES_ACTION') {
      return Colors.orange.shade800;
    }
    if (status == 'PROCESSING') return Colors.blueGrey.shade700;
    return AppThemeTokens.textPrimary;
  }
}

class _PaymentStatusBanner extends StatelessWidget {
  final OrderPaymentEntity? payment;

  const _PaymentStatusBanner({required this.payment});

  @override
  Widget build(BuildContext context) {
    final latestStatus = payment?.latestPaymentStatus?.trim().toUpperCase();
    final paymentState = payment?.paymentState?.trim().toUpperCase();

    final Color color;
    final IconData icon;
    final String title;
    final String subtitle;

    if (payment == null) {
      color = AppThemeTokens.textSecondary;
      icon = Icons.info_outline;
      title = _t(context, 'No payment transaction yet');
      subtitle = _t(context, 'Payment will appear here after checkout starts it.');
    } else if (payment!.fullyPaid ||
        paymentState == 'PAID' ||
        latestStatus == 'SUCCEEDED' ||
        latestStatus == 'PAID') {
      color = Colors.green.shade700;
      icon = Icons.verified_outlined;
      title = _t(context, 'Payment collected');
      subtitle = _t(context, 'This order is fully paid.');
    } else if (payment!.isOfflinePending) {
      color = Colors.orange.shade800;
      icon = Icons.pending_actions_outlined;
      title = _t(context, 'Pending cash collection');
      subtitle = _t(context, 'Collect cash from the retailer, then mark it as paid.');
    } else if (latestStatus == 'REQUIRES_PAYMENT_METHOD' ||
        latestStatus == 'REQUIRES_CONFIRMATION' ||
        latestStatus == 'REQUIRES_ACTION') {
      color = Colors.orange.shade800;
      icon = Icons.credit_card_off_outlined;
      title = _t(context, 'Payment not completed');
      subtitle = _t(context, 'The retailer started card payment but did not complete it yet.');
    } else if (latestStatus == 'PROCESSING') {
      color = Colors.blueGrey.shade700;
      icon = Icons.sync_outlined;
      title = _t(context, 'Payment processing');
      subtitle = _t(context, 'The payment provider is still processing this transaction.');
    } else if (latestStatus == 'FAILED' ||
        latestStatus == 'CANCELED' ||
        latestStatus == 'CANCELLED' ||
        paymentState == 'FAILED') {
      color = AppThemeTokens.error;
      icon = Icons.error_outline;
      title = _t(context, 'Payment failed');
      subtitle = _t(context, 'The payment was not completed. The order remains unpaid.');
    } else {
      color = AppThemeTokens.textSecondary;
      icon = Icons.info_outline;
      title = _t(context, 'Payment not completed');
      subtitle = _t(context, 'This order has a payment record, but it is not fully paid yet.');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PaymentInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 125,
          child: Text(
            label,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: valueColor ?? AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}


String _humanizeStatus(String value) {
  final normalized = value.trim().toLowerCase().replaceAll('_', ' ');
  if (normalized.isEmpty) return value;
  return normalized[0].toUpperCase() + normalized.substring(1);
}

String _t(BuildContext context, String key) {
  final languageCode = Localizations.localeOf(context).languageCode;

  const ar = {
    'Payment': 'الدفع',
    'Cash collection and payment status': 'تحصيل الكاش وحالة الدفع',
    'Refresh': 'تحديث',
    'Method': 'الطريقة',
    'State': 'الحالة',
    'Latest status': 'آخر حالة',
    'Reference': 'المرجع',
    'Paid': 'المدفوع',
    'Remaining': 'المتبقي',
    'Updated': 'آخر تحديث',
    'Mark Cash as Paid': 'تأكيد تحصيل الكاش',
    'Updating...': 'جاري التحديث...',
    'Cash on Delivery': 'الدفع عند الاستلام',
    'Card': 'بطاقة',
    'Bank Transfer': 'تحويل بنكي',
    'Card / Stripe': 'بطاقة / Stripe',
    'Requires payment method': 'يتطلب طريقة دفع',
    'Requires confirmation': 'يتطلب تأكيد الدفع',
    'Requires retailer action': 'يتطلب إجراء من التاجر',
    'Processing': 'قيد المعالجة',
    'Payment not completed': 'الدفع غير مكتمل',
    'The retailer started card payment but did not complete it yet.':
        'بدأ التاجر الدفع بالبطاقة لكنه لم يكمله بعد.',
    'Payment processing': 'الدفع قيد المعالجة',
    'The payment provider is still processing this transaction.':
        'مزود الدفع لا يزال يعالج هذه العملية.',
    'Payment failed': 'فشل الدفع',
    'The payment was not completed. The order remains unpaid.':
        'لم تكتمل عملية الدفع. الطلب لا يزال غير مدفوع.',
    'This order has a payment record, but it is not fully paid yet.':
        'هذا الطلب لديه سجل دفع، لكنه غير مدفوع بالكامل بعد.',
    'Not provided': 'غير محدد',
    'Partially paid': 'مدفوع جزئياً',
    'Failed': 'فشل',
    'Unpaid': 'غير مدفوع',
    'No payment yet': 'لا يوجد دفع بعد',
    'Pending cash collection': 'بانتظار تحصيل الكاش',
    'Cancelled': 'ملغى',
    'No transaction': 'لا توجد عملية',
    'Payment collected': 'تم تحصيل الدفع',
    'This order is fully paid.': 'هذا الطلب مدفوع بالكامل.',
    'Collect cash from the retailer, then mark it as paid.':
        'حصّلي الكاش من التاجر ثم أكدي أنه مدفوع.',
    'No payment transaction yet': 'لا توجد عملية دفع بعد',
    'Payment will appear here after checkout starts it.':
        'سيظهر الدفع هنا بعد أن يبدأه قسم الـ checkout.',
  };

  const fr = {
    'Payment': 'Paiement',
    'Cash collection and payment status': 'Encaissement et état du paiement',
    'Refresh': 'Actualiser',
    'Method': 'Méthode',
    'State': 'État',
    'Latest status': 'Dernier statut',
    'Reference': 'Référence',
    'Paid': 'Payé',
    'Remaining': 'Restant',
    'Updated': 'Mis à jour',
    'Mark Cash as Paid': 'Marquer le cash comme payé',
    'Updating...': 'Mise à jour...',
    'Cash on Delivery': 'Paiement à la livraison',
    'Card': 'Carte',
    'Bank Transfer': 'Virement bancaire',
    'Card / Stripe': 'Carte / Stripe',
    'Requires payment method': 'Méthode de paiement requise',
    'Requires confirmation': 'Confirmation requise',
    'Requires retailer action': 'Action du détaillant requise',
    'Processing': 'En traitement',
    'Payment not completed': 'Paiement non terminé',
    'The retailer started card payment but did not complete it yet.':
        'Le détaillant a commencé le paiement par carte mais ne l’a pas terminé.',
    'Payment processing': 'Paiement en traitement',
    'The payment provider is still processing this transaction.':
        'Le prestataire de paiement traite encore cette transaction.',
    'Payment failed': 'Paiement échoué',
    'The payment was not completed. The order remains unpaid.':
        'Le paiement n’a pas été terminé. La commande reste impayée.',
    'This order has a payment record, but it is not fully paid yet.':
        'Cette commande a un enregistrement de paiement, mais elle n’est pas encore entièrement payée.',
    'Not provided': 'Non fourni',
    'Partially paid': 'Partiellement payé',
    'Failed': 'Échoué',
    'Unpaid': 'Non payé',
    'No payment yet': 'Aucun paiement',
    'Pending cash collection': 'Encaissement en attente',
    'Cancelled': 'Annulé',
    'No transaction': 'Aucune transaction',
    'Payment collected': 'Paiement encaissé',
    'This order is fully paid.': 'Cette commande est entièrement payée.',
    'Collect cash from the retailer, then mark it as paid.':
        'Encaissez le cash du détaillant, puis marquez-le comme payé.',
    'No payment transaction yet': 'Aucune transaction de paiement',
    'Payment will appear here after checkout starts it.':
        'Le paiement apparaîtra ici après le démarrage du checkout.',
  };

  if (languageCode == 'ar') return ar[key] ?? key;
  if (languageCode == 'fr') return fr[key] ?? key;
  return key;
}

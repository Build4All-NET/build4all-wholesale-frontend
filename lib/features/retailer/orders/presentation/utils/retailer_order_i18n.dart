import 'package:flutter/widgets.dart';

import '../../domain/entities/retailer_order_entity.dart';

class RetailerOrderI18n {
  final BuildContext context;

  const RetailerOrderI18n(this.context);

  String get _languageCode => Localizations.localeOf(context).languageCode;

  String _select({required String en, required String ar, required String fr}) {
    switch (_languageCode) {
      case 'ar':
        return ar;
      case 'fr':
        return fr;
      case 'en':
      default:
        return en;
    }
  }

  String get myOrders => _select(
        en: 'My Orders',
        ar: 'طلباتي',
        fr: 'Mes commandes',
      );

  String get all => _select(en: 'All', ar: 'الكل', fr: 'Toutes');
  String get pending => _select(en: 'Pending', ar: 'قيد المعالجة', fr: 'En cours');
  String get delivered => _select(en: 'Delivered', ar: 'تم التسليم', fr: 'Livrées');
  String get cancelled => _select(en: 'Cancelled', ar: 'ملغاة', fr: 'Annulées');

  String get trackOrder => _select(
        en: 'Track order',
        ar: 'تتبع الطلب',
        fr: 'Suivre la commande',
      );

  String get orderTracking => _select(
        en: 'Order Tracking',
        ar: 'تتبع الطلب',
        fr: 'Suivi de commande',
      );

  String get orderDetails => _select(
        en: 'Order Details',
        ar: 'تفاصيل الطلب',
        fr: 'Détails de la commande',
      );

  String get orderItems => _select(
        en: 'Order Items',
        ar: 'عناصر الطلب',
        fr: 'Articles commandés',
      );

  String get paymentMethod => _select(
        en: 'Payment method',
        ar: 'طريقة الدفع',
        fr: 'Mode de paiement',
      );

  String get deliveryBranch => _select(
        en: 'Delivery branch',
        ar: 'فرع التسليم',
        fr: 'Branche de livraison',
      );

  String get deliveryAddress => _select(
        en: 'Delivery address',
        ar: 'عنوان التسليم',
        fr: 'Adresse de livraison',
      );

  String get totalAmount => _select(
        en: 'Total amount',
        ar: 'المبلغ الإجمالي',
        fr: 'Montant total',
      );

  String get cancelOrder => _select(
        en: 'Cancel order',
        ar: 'إلغاء الطلب',
        fr: 'Annuler la commande',
      );

  String get cancelOrderTitle => _select(
        en: 'Cancel this order?',
        ar: 'هل تريدين إلغاء هذا الطلب؟',
        fr: 'Annuler cette commande ?',
      );

  String get cancelOrderMessage => _select(
        en: 'You can cancel this order while it is still pending or accepted.',
        ar: 'يمكنك إلغاء هذا الطلب طالما أنه ما زال قيد المعالجة أو مقبولًا.',
        fr: 'Vous pouvez annuler cette commande tant qu’elle est en attente ou acceptée.',
      );

  String get keepOrder => _select(
        en: 'Keep order',
        ar: 'الاحتفاظ بالطلب',
        fr: 'Garder la commande',
      );

  String get orderCancelled => _select(
        en: 'Order cancelled successfully',
        ar: 'تم إلغاء الطلب بنجاح',
        fr: 'Commande annulée avec succès',
      );

  String get noOrdersTitle => _select(
        en: 'No orders yet',
        ar: 'لا توجد طلبات بعد',
        fr: 'Aucune commande pour le moment',
      );

  String get noOrdersMessage => _select(
        en: 'Orders you place after checkout will appear here.',
        ar: 'ستظهر هنا الطلبات التي تقومين بها بعد إتمام الشراء.',
        fr: 'Les commandes passées après le paiement apparaîtront ici.',
      );

  String get noFilteredOrders => _select(
        en: 'No orders match this filter.',
        ar: 'لا توجد طلبات تطابق هذا الفلتر.',
        fr: 'Aucune commande ne correspond à ce filtre.',
      );

  String get loadingOrders => _select(
        en: 'Loading orders...',
        ar: 'جاري تحميل الطلبات...',
        fr: 'Chargement des commandes...',
      );

  String get retry => _select(en: 'Retry', ar: 'إعادة المحاولة', fr: 'Réessayer');

  String get notProvided => _select(
        en: 'Not provided',
        ar: 'غير متوفر',
        fr: 'Non fourni',
      );

  String get items => _select(en: 'items', ar: 'عناصر', fr: 'articles');
  String get item => _select(en: 'item', ar: 'عنصر', fr: 'article');

  String get orderPlaced => _select(
        en: 'Order Placed',
        ar: 'تم إنشاء الطلب',
        fr: 'Commande passée',
      );

  String get accepted => _select(en: 'Accepted', ar: 'تم القبول', fr: 'Acceptée');
  String get preparing => _select(en: 'Preparing', ar: 'قيد التحضير', fr: 'Préparation');
  String get shipped => _select(en: 'Shipped', ar: 'تم الشحن', fr: 'Expédiée');

  String get completed => _select(en: 'Completed', ar: 'مكتمل', fr: 'Terminé');
  String get inProgress => _select(en: 'In progress', ar: 'قيد التنفيذ', fr: 'En cours');
  String get waiting => _select(en: 'Waiting', ar: 'بانتظار التحديث', fr: 'En attente');

  String get viewCart => _select(
        en: 'View cart',
        ar: 'عرض السلة',
        fr: 'Voir le panier',
      );

  String get reorderComingSoon => _select(
        en: 'Reorder will be enabled after checkout/cart integration is finalized.',
        ar: 'سيتم تفعيل إعادة الطلب بعد تثبيت ربط السلة والدفع النهائي.',
        fr: 'La commande à nouveau sera activée après la finalisation du panier et du paiement.',
      );

  String filterLabel(RetailerOrderFilter filter) {
    switch (filter) {
      case RetailerOrderFilter.all:
        return all;
      case RetailerOrderFilter.pending:
        return pending;
      case RetailerOrderFilter.delivered:
        return delivered;
      case RetailerOrderFilter.cancelled:
        return cancelled;
    }
  }

  String statusLabel(RetailerOrderStatus status) {
    switch (status) {
      case RetailerOrderStatus.pending:
        return pending;
      case RetailerOrderStatus.accepted:
        return accepted;
      case RetailerOrderStatus.preparing:
        return preparing;
      case RetailerOrderStatus.shipped:
        return shipped;
      case RetailerOrderStatus.delivered:
        return delivered;
      case RetailerOrderStatus.cancelled:
        return cancelled;
    }
  }

  String paymentLabel(String rawValue) {
    final normalized = rawValue.trim().toUpperCase().replaceAll(' ', '_');
    switch (normalized) {
      case 'COD':
      case 'CASH':
      case 'CASH_ON_DELIVERY':
        return _select(
          en: 'Cash on delivery',
          ar: 'الدفع عند الاستلام',
          fr: 'Paiement à la livraison',
        );
      case 'CARD':
      case 'CREDIT_CARD':
      case 'DEBIT_CARD':
        return _select(en: 'Card payment', ar: 'الدفع بالبطاقة', fr: 'Paiement par carte');
      case 'BANK_TRANSFER':
      case 'TRANSFER':
        return _select(en: 'Bank transfer', ar: 'تحويل مصرفي', fr: 'Virement bancaire');
      case 'WALLET':
        return _select(en: 'Wallet', ar: 'المحفظة', fr: 'Portefeuille');
      default:
        return rawValue.trim().isEmpty ? notProvided : rawValue;
    }
  }

  String itemsCount(int count) {
    return '$count ${count == 1 ? item : items}';
  }
}

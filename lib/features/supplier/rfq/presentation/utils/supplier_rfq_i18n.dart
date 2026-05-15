import 'package:flutter/widgets.dart';

class SupplierRfqI18n {
  final BuildContext context;

  const SupplierRfqI18n(this.context);

  String get _lang => Localizations.localeOf(context).languageCode.toLowerCase();

  String t(String key) {
    final values = _labels[key];
    if (values == null) return key;
    return values[_lang] ?? values['en'] ?? key;
  }

  String countRequests(int count) {
    if (_lang == 'ar') return count == 1 ? 'طلب واحد متاح' : '$count طلبات متاحة';
    if (_lang == 'fr') return count == 1 ? '1 demande disponible' : '$count demandes disponibles';
    return count == 1 ? '1 request available' : '$count requests available';
  }

  String quoteCount(int count) {
    if (_lang == 'ar') return count == 1 ? 'عرض واحد' : '$count عروض';
    if (_lang == 'fr') return count == 1 ? '1 devis' : '$count devis';
    return count == 1 ? '1 quote' : '$count quotes';
  }

  String targetPrice(String value) {
    if (_lang == 'ar') return 'السعر المستهدف $value';
    if (_lang == 'fr') return 'Prix cible $value';
    return 'Target $value';
  }

  String status(String status) {
    final normalized = status.toUpperCase();
    final map = _statusLabels[normalized];
    if (map == null) {
      return normalized
          .split('_')
          .map((word) => word.isEmpty ? word : '${word[0]}${word.substring(1).toLowerCase()}')
          .join(' ');
    }
    return map[_lang] ?? map['en'] ?? normalized;
  }
}

const Map<String, Map<String, String>> _labels = {
  'rfqRequests': {
    'en': 'RFQ Requests',
    'ar': 'طلبات عروض الأسعار',
    'fr': 'Demandes de devis',
  },
  'rfqDetails': {
    'en': 'RFQ Details',
    'ar': 'تفاصيل طلب العرض',
    'fr': 'Détails de la demande',
  },
  'openRfqsFromRetailers': {
    'en': 'Open RFQs from retailers',
    'ar': 'طلبات عروض مفتوحة من التجار',
    'fr': 'Demandes ouvertes des détaillants',
  },
  'reviewRequests': {
    'en': 'Review requests and submit competitive quotations.',
    'ar': 'راجع الطلبات وقدّم عروض أسعار منافسة.',
    'fr': 'Consultez les demandes et envoyez des devis compétitifs.',
  },
  'searchHint': {
    'en': 'Search by product, category, city...',
    'ar': 'ابحث حسب المنتج أو الفئة أو المدينة...',
    'fr': 'Rechercher par produit, catégorie, ville...',
  },
  'all': {'en': 'All', 'ar': 'الكل', 'fr': 'Tous'},
  'open': {'en': 'Open', 'ar': 'مفتوح', 'fr': 'Ouvert'},
  'quoted': {'en': 'Quoted', 'ar': 'تم التسعير', 'fr': 'Devis reçu'},
  'noOpenRfqs': {'en': 'No open RFQs', 'ar': 'لا توجد طلبات عروض مفتوحة', 'fr': 'Aucune demande ouverte'},
  'noOpenRfqsMessage': {
    'en': 'When retailers post requests for products, they will appear here for you to quote.',
    'ar': 'عندما يضيف التجار طلبات منتجات، ستظهر هنا لتقديم عرض سعر.',
    'fr': 'Lorsque les détaillants publient des demandes de produits, elles apparaîtront ici pour envoyer un devis.',
  },
  'refresh': {'en': 'Refresh', 'ar': 'تحديث', 'fr': 'Actualiser'},
  'unnamedProduct': {'en': 'Unnamed product', 'ar': 'منتج بدون اسم', 'fr': 'Produit sans nom'},
  'noRequirementsAdded': {'en': 'No requirements added.', 'ar': 'لم تتم إضافة متطلبات.', 'fr': 'Aucune exigence ajoutée.'},
  'requirements': {'en': 'Requirements', 'ar': 'المتطلبات', 'fr': 'Exigences'},
  'deliveryInformation': {'en': 'Delivery information', 'ar': 'معلومات التوصيل', 'fr': 'Informations de livraison'},
  'preferredDelivery': {'en': 'Preferred delivery', 'ar': 'التوصيل المفضل', 'fr': 'Livraison préférée'},
  'deadline': {'en': 'Deadline', 'ar': 'الموعد النهائي', 'fr': 'Date limite'},
  'country': {'en': 'Country', 'ar': 'البلد', 'fr': 'Pays'},
  'region': {'en': 'Region', 'ar': 'المنطقة', 'fr': 'Région'},
  'city': {'en': 'City', 'ar': 'المدينة', 'fr': 'Ville'},
  'address': {'en': 'Address', 'ar': 'العنوان', 'fr': 'Adresse'},
  'quantity': {'en': 'Quantity', 'ar': 'الكمية', 'fr': 'Quantité'},
  'category': {'en': 'Category', 'ar': 'الفئة', 'fr': 'Catégorie'},
  'subcategory': {'en': 'Subcategory', 'ar': 'الفئة الفرعية', 'fr': 'Sous-catégorie'},
  'targetUnitPrice': {'en': 'Target unit price', 'ar': 'سعر الوحدة المستهدف', 'fr': 'Prix unitaire cible'},
  'quotes': {'en': 'Quotes', 'ar': 'العروض', 'fr': 'Devis'},
  'submitQuotation': {'en': 'Submit Quotation', 'ar': 'إرسال عرض السعر', 'fr': 'Envoyer le devis'},
  'submitQuotationSmall': {'en': 'Submit quotation', 'ar': 'إرسال عرض السعر', 'fr': 'Envoyer le devis'},
  'editQuotation': {'en': 'Edit quotation', 'ar': 'تعديل عرض السعر', 'fr': 'Modifier le devis'},
  'updateQuotation': {'en': 'Update quotation', 'ar': 'تحديث عرض السعر', 'fr': 'Mettre à jour le devis'},
  'submitting': {'en': 'Submitting...', 'ar': 'جارٍ الإرسال...', 'fr': 'Envoi en cours...'},
  'yourQuotation': {'en': 'Your quotation', 'ar': 'عرض السعر الخاص بك', 'fr': 'Votre devis'},
  'unitPrice': {'en': 'Unit price', 'ar': 'سعر الوحدة', 'fr': 'Prix unitaire'},
  'total': {'en': 'Total', 'ar': 'المجموع', 'fr': 'Total'},
  'availableQty': {'en': 'Available qty', 'ar': 'الكمية المتوفرة', 'fr': 'Qté disponible'},
  'availableQuantity': {'en': 'Available quantity', 'ar': 'الكمية المتوفرة', 'fr': 'Quantité disponible'},
  'shipping': {'en': 'Shipping', 'ar': 'الشحن', 'fr': 'Livraison'},
  'shippingCost': {'en': 'Shipping cost', 'ar': 'تكلفة الشحن', 'fr': 'Frais de livraison'},
  'deliveryDate': {'en': 'Delivery date', 'ar': 'تاريخ التوصيل', 'fr': 'Date de livraison'},
  'messageNotes': {'en': 'Message / notes', 'ar': 'رسالة / ملاحظات', 'fr': 'Message / notes'},
  'edit': {'en': 'Edit', 'ar': 'تعديل', 'fr': 'Modifier'},
  'withdraw': {'en': 'Withdraw', 'ar': 'سحب', 'fr': 'Retirer'},
  'withdrawQuotationQuestion': {'en': 'Withdraw quotation?', 'ar': 'هل تريد سحب عرض السعر؟', 'fr': 'Retirer le devis ?'},
  'withdrawQuotationMessage': {
    'en': 'The retailer will no longer be able to accept this offer.',
    'ar': 'لن يستطيع التاجر قبول هذا العرض بعد سحبه.',
    'fr': 'Le détaillant ne pourra plus accepter cette offre.',
  },
  'keepQuotation': {'en': 'Keep quotation', 'ar': 'إبقاء العرض', 'fr': 'Garder le devis'},
  'quotationAccepted': {
    'en': 'Your quotation was accepted by the retailer.',
    'ar': 'تم قبول عرض السعر الخاص بك من قبل التاجر.',
    'fr': 'Votre devis a été accepté par le détaillant.',
  },
  'rfqNotOpened': {
    'en': 'The selected RFQ could not be opened.',
    'ar': 'تعذر فتح طلب العرض المحدد.',
    'fr': 'Impossible d’ouvrir la demande sélectionnée.',
  },
  'notAvailableForQuotations': {
    'en': 'This RFQ is no longer available for quotations.',
    'ar': 'هذا الطلب لم يعد متاحًا لتقديم عروض الأسعار.',
    'fr': 'Cette demande n’est plus disponible pour les devis.',
  },
  'fieldRequired': {'en': 'is required', 'ar': 'مطلوب', 'fr': 'est obligatoire'},
  'mustBeGreaterThanZero': {'en': 'must be greater than 0', 'ar': 'يجب أن يكون أكبر من 0', 'fr': 'doit être supérieur à 0'},
  'cannotBeNegative': {'en': 'cannot be negative', 'ar': 'لا يمكن أن يكون سالبًا', 'fr': 'ne peut pas être négatif'},
};

const Map<String, Map<String, String>> _statusLabels = {
  'OPEN': {'en': 'Open', 'ar': 'مفتوح', 'fr': 'Ouvert'},
  'QUOTED': {'en': 'Quoted', 'ar': 'تم التسعير', 'fr': 'Devis reçu'},
  'ACCEPTED': {'en': 'Accepted', 'ar': 'مقبول', 'fr': 'Accepté'},
  'CLOSED': {'en': 'Closed', 'ar': 'مغلق', 'fr': 'Fermé'},
  'CANCELLED': {'en': 'Cancelled', 'ar': 'ملغى', 'fr': 'Annulé'},
  'EXPIRED': {'en': 'Expired', 'ar': 'منتهي', 'fr': 'Expiré'},
  'PENDING': {'en': 'Pending', 'ar': 'قيد الانتظار', 'fr': 'En attente'},
  'REJECTED': {'en': 'Rejected', 'ar': 'مرفوض', 'fr': 'Rejeté'},
  'WITHDRAWN': {'en': 'Withdrawn', 'ar': 'مسحوب', 'fr': 'Retiré'},
};

import 'package:flutter/widgets.dart';

class SupplierExcelImportI18n {
  final BuildContext context;

  SupplierExcelImportI18n(this.context);

  String get _code => Localizations.localeOf(context).languageCode;

  String _t(String en, String ar, String fr) {
    switch (_code) {
      case 'ar':
        return ar;
      case 'fr':
        return fr;
      default:
        return en;
    }
  }

  String get title => _t('Supplier Excel Import', 'استيراد Excel للمورد', 'Import Excel fournisseur');
  String get instructionTitle => _t('Import supplier data from Excel', 'استيراد بيانات المورد من Excel', 'Importer les données fournisseur depuis Excel');
  String get instructionBody => _t(
        'Download the official template, fill the sheets you need, upload it, review validation errors, then import. Fix any errors directly in Excel and upload again.',
        'حمّلي القالب الرسمي، عبّئي الأوراق التي تحتاجينها، ارفعي الملف، راجعي أخطاء التحقق، ثم استوردي البيانات. صححي الأخطاء داخل Excel ثم ارفعي الملف من جديد.',
        'Téléchargez le modèle officiel, remplissez les feuilles nécessaires, importez-le, vérifiez les erreurs, puis lancez l’import. Corrigez les erreurs dans Excel puis téléversez à nouveau.',
      );
  String get noteOne => _t(
        'Core wholesale setup: categories, subcategories, branches, products, and branch stock.',
        'إعدادات الجملة الأساسية: الفئات، الفئات الفرعية، الفروع، المنتجات، ومخزون الفروع.',
        'Configuration de base wholesale : catégories, sous-catégories, branches, produits et stock par branche.',
      );
  String get noteTwo => _t(
        'Optional operational sheets are available for tax rules, shipping methods, and coupons.',
        'توجد أوراق اختيارية لإعداد قواعد الضريبة، طرق الشحن، والكوبونات.',
        'Des feuilles opérationnelles optionnelles sont disponibles pour les taxes, la livraison et les coupons.',
      );

  String get subtitle => instructionBody;
  String get templateTitle => officialTemplateTitle;
  String get templateSubtitle => officialTemplateHint;
  String get templateSaved => savedTemplatePath;
  String get rows => totalRows;
  String get valid => validRows;

  String get compactInstructionHint => _t(
        'Download the template, fill it, upload it, then review only the rows that need attention.',
        'حمّلي القالب، عبّئيه، ارفعيه، ثم راجعي فقط الصفوف التي تحتاج تعديلًا.',
        'Téléchargez le modèle, remplissez-le, importez-le, puis vérifiez seulement les lignes à corriger.',
      );
  String get templateStructureTitle => _t('Template sheets and columns', 'أوراق وأعمدة القالب', 'Feuilles et colonnes du modèle');
  String get templateStructureSubtitle => _t(
        'Closed by default to keep the page clean. Open it only when you need to check sheet names or columns.',
        'مغلقة تلقائيًا حتى تبقى الصفحة مرتبة. افتحيها فقط عند الحاجة لمعرفة أسماء الأوراق أو الأعمدة.',
        'Fermé par défaut pour garder la page claire. Ouvrez-le seulement pour vérifier les feuilles ou colonnes.',
      );
  String get workbookSummary => _t('Workbook summary', 'ملخص ملف Excel', 'Résumé du classeur');
  String get columnLabel => _t('Column', 'العمود', 'Colonne');
  String get unknownColumn => _t('Related column', 'العمود المرتبط', 'Colonne liée');
  String get issueDetailsTitle => _t('Where to fix this row', 'أين يجب تصحيح هذا الصف', 'Où corriger cette ligne');
  String get excelLocation => _t('Excel location', 'مكان الخطأ في Excel', 'Emplacement dans Excel');
  String get problem => _t('Problem', 'المشكلة', 'Problème');
  String get issueFixInstruction => _t(
        'Open the selected Excel file, go to this sheet and row, fix the highlighted column, save the file, then upload it again.',
        'افتحي ملف Excel المحدد، انتقلي إلى هذه الورقة وهذا الصف، صححي العمود المذكور، احفظي الملف، ثم ارفعيه من جديد.',
        'Ouvrez le fichier Excel sélectionné, allez à cette feuille et cette ligne, corrigez la colonne indiquée, enregistrez puis téléversez à nouveau.',
      );
  String get copyLocation => _t('Copy location', 'نسخ مكان الخطأ', 'Copier l’emplacement');
  String get locationCopied => _t('Excel location copied.', 'تم نسخ مكان الخطأ.', 'Emplacement copié.');

  String get editRow => _t('Edit row', 'تعديل الصف', 'Modifier la ligne');
  String get editRowTitle => _t('Edit Excel row', 'تعديل صف Excel', 'Modifier la ligne Excel');
  String get editRowInstruction => _t(
        'Update only the wrong values below, then save. The app will validate this row again before import.',
        'عدّلي فقط القيم الخاطئة في الأسفل، ثم احفظي. سيعيد التطبيق التحقق من هذا الصف قبل الاستيراد.',
        'Modifiez uniquement les valeurs incorrectes ci-dessous, puis enregistrez. L’application validera à nouveau cette ligne avant l’import.',
      );
  String get fieldWithIssue => _t('This field likely needs correction.', 'غالبًا هذا الحقل يحتاج تصحيحًا.', 'Ce champ doit probablement être corrigé.');
  String get saveRow => _t('Save row', 'حفظ الصف', 'Enregistrer la ligne');
  String get rowUpdated => _t('Row updated. Validation refreshed.', 'تم تعديل الصف وإعادة التحقق.', 'Ligne mise à jour. Validation actualisée.');
  String get cancel => _t('Cancel', 'إلغاء', 'Annuler');

  String get noteThree => _t(
        'The app blocks duplicate products, duplicate stock rows, negative stock, invalid dates, and invalid amounts before importing.',
        'التطبيق يمنع المنتجات المكررة، صفوف المخزون المكررة، المخزون السالب، التواريخ غير الصحيحة، والقيم غير الصحيحة قبل الاستيراد.',
        'L’application bloque les produits dupliqués, les lignes de stock dupliquées, le stock négatif, les dates invalides et les montants invalides avant l’import.',
      );

  String get officialTemplateTitle => _t('Official supplier template', 'القالب الرسمي للمورد', 'Modèle fournisseur officiel');
  String get officialTemplateHint => _t(
        'Use this template for the cleanest import. It includes the sheets needed for supplier setup, products, branch stock, and optional operational settings.',
        'استخدمي هذا القالب لأفضل استيراد. يحتوي على الأوراق اللازمة لإعداد المورد، المنتجات، مخزون الفروع، وبعض الإعدادات التشغيلية الاختيارية.',
        'Utilisez ce modèle pour un import propre. Il inclut les feuilles nécessaires à la configuration fournisseur, aux produits, au stock par branche et aux réglages optionnels.',
      );
  String get simpleTemplateTitle => officialTemplateTitle;
  String get simpleTemplateHint => officialTemplateHint;
  String get downloadTemplate => _t('Download template', 'تحميل القالب', 'Télécharger le modèle');
  String get downloadingTemplate => _t('Downloading...', 'جارٍ التحميل...', 'Téléchargement...');
  String get templateDownloaded => _t('Template downloaded successfully.', 'تم تحميل القالب بنجاح.', 'Modèle téléchargé avec succès.');
  String get savedTemplatePath => _t('Saved template path', 'مسار القالب المحفوظ', 'Chemin du modèle enregistré');

  String get selectedFile => _t('Selected Excel file', 'ملف Excel المحدد', 'Fichier Excel sélectionné');
  String get noFile => _t('No file selected yet', 'لم يتم اختيار ملف بعد', 'Aucun fichier sélectionné');
  String get pickFile => _t('Upload Excel file', 'رفع ملف Excel', 'Téléverser un fichier Excel');
  String get replaceFile => _t('Replace file', 'استبدال الملف', 'Remplacer le fichier');
  String get clear => _t('Clear', 'مسح', 'Effacer');

  String get mainColumns => _t('Columns', 'الأعمدة', 'Colonnes');
  String get previewTitle => _t('Validation results', 'نتائج التحقق', 'Résultats de validation');
  String get readyToImport => _t('The file is valid and ready to import.', 'الملف صحيح وجاهز للاستيراد.', 'Le fichier est valide et prêt à importer.');
  String get fixExcelFile => _t('Fix the errors in Excel, then upload the file again.', 'صححي الأخطاء داخل Excel ثم ارفعي الملف من جديد.', 'Corrigez les erreurs dans Excel puis téléversez le fichier à nouveau.');
  String get fixErrors => fixExcelFile;
  String get noRows => _t('No supplier rows found yet.', 'لم يتم العثور على صفوف للمورد بعد.', 'Aucune ligne fournisseur trouvée.');
  String get workbookStructureHint => _t(
        'Use the official sheets: Categories, SubCategories, Branches, Products, BranchInventory, TaxRules, ShippingMethods, and Coupons.',
        'استخدمي الأوراق الرسمية: Categories و SubCategories و Branches و Products و BranchInventory و TaxRules و ShippingMethods و Coupons.',
        'Utilisez les feuilles officielles : Categories, SubCategories, Branches, Products, BranchInventory, TaxRules, ShippingMethods et Coupons.',
      );

  String get errors => _t('Errors', 'أخطاء', 'Erreurs');
  String get warnings => _t('Warnings', 'تحذيرات', 'Avertissements');
  String get errorsFound => _t('Errors to fix in Excel', 'أخطاء يجب تصحيحها في Excel', 'Erreurs à corriger dans Excel');
  String get warningsFound => _t('Warnings to review', 'تحذيرات للمراجعة', 'Avertissements à vérifier');
  String get fixInExcelHint => _t(
        'Each issue shows the sheet name and row number. Open the Excel file, fix that row, save it, then upload again.',
        'كل مشكلة تعرض اسم الورقة ورقم الصف. افتحي ملف Excel، صححي ذلك الصف، احفظيه، ثم ارفعيه من جديد.',
        'Chaque problème affiche la feuille et le numéro de ligne. Ouvrez Excel, corrigez la ligne, sauvegardez puis téléversez à nouveau.',
      );
  String get warningHint => _t(
        'Warnings do not always block import, but they should be reviewed before importing.',
        'التحذيرات لا تمنع الاستيراد دائمًا، لكن من الأفضل مراجعتها قبل الاستيراد.',
        'Les avertissements ne bloquent pas toujours l’import, mais doivent être vérifiés avant de continuer.',
      );
  String get moreIssues => _t('more issues', 'مشاكل إضافية', 'problèmes en plus');

  String get totalRows => _t('Total rows', 'كل الصفوف', 'Total lignes');
  String get validRows => _t('Valid rows', 'صفوف صحيحة', 'Lignes valides');
  String get errorRows => _t('Rows with errors', 'صفوف فيها أخطاء', 'Lignes avec erreurs');
  String get warningRows => _t('Rows with warnings', 'صفوف فيها تحذيرات', 'Lignes avec avertissements');
  String get import => _t('Import', 'استيراد', 'Importer');
  String get importing => _t('Importing...', 'جارٍ الاستيراد...', 'Importation...');
  String get importSuccess => _t('Import completed successfully.', 'تم الاستيراد بنجاح.', 'Import terminé avec succès.');
  String get importPartial => _t('Import completed with some failed rows.', 'تم الاستيراد مع فشل بعض الصفوف.', 'Import terminé avec quelques lignes échouées.');
  String get importResult => _t('Import result', 'نتيجة الاستيراد', 'Résultat de l’import');

  String get imported => _t('Imported', 'تم استيرادها', 'Importées');
  String get failed => _t('Failed', 'فشلت', 'Échouées');
  String get details => _t('Details', 'التفاصيل', 'Détails');

  String rowNumber(int row) => _t('Row $row', 'الصف $row', 'Ligne $row');

  String sectionTitle(String section) {
    switch (section) {
      case 'categories':
        return _t('Categories', 'الفئات', 'Catégories');
      case 'subCategories':
        return _t('SubCategories', 'الفئات الفرعية', 'Sous-catégories');
      case 'branches':
        return _t('Branches', 'الفروع', 'Branches');
      case 'products':
        return _t('Products', 'المنتجات', 'Produits');
      case 'inventory':
        return _t('Branch Inventory', 'مخزون الفروع', 'Stock des branches');
      case 'taxRules':
        return _t('Tax Rules', 'قواعد الضريبة', 'Règles fiscales');
      case 'shippingMethods':
        return _t('Shipping Methods', 'طرق الشحن', 'Méthodes de livraison');
      case 'coupons':
        return _t('Coupons', 'الكوبونات', 'Coupons');
      default:
        return section;
    }
  }

  String headerLabel(String key) {
    switch (key) {
      case 'name':
        return _t('Name', 'الاسم', 'Nom');
      case 'status':
        return _t('Status', 'الحالة', 'Statut');
      case 'category':
        return _t('Category', 'الفئة', 'Catégorie');
      case 'subcategory':
        return _t('Subcategory', 'الفئة الفرعية', 'Sous-catégorie');
      case 'branchname':
        return _t('Branch name', 'اسم الفرع', 'Nom de la branche');
      case 'branch':
        return _t('Branch', 'الفرع', 'Branche');
      case 'productname':
        return _t('Product name', 'اسم المنتج', 'Nom du produit');
      case 'description':
        return _t('Description', 'الوصف', 'Description');
      case 'price':
        return _t('Price', 'السعر', 'Prix');
      case 'moq':
        return _t('MOQ', 'الحد الأدنى للطلب', 'MOQ');
      case 'stockquantity':
        return _t('Stock quantity', 'كمية المخزون', 'Quantité en stock');
      case 'imageurl':
        return _t('Image URL', 'رابط الصورة', 'URL de l’image');
      case 'countrycode':
        return _t('Country code', 'رمز الدولة', 'Code pays');
      case 'countryid':
        return _t('Country ID', 'معرّف الدولة', 'ID pays');
      case 'countryname':
        return _t('Country name', 'اسم الدولة', 'Nom du pays');
      case 'regionid':
        return _t('Region ID', 'معرّف المنطقة', 'ID région');
      case 'regionname':
        return _t('Region name', 'اسم المنطقة', 'Nom de la région');
      case 'city':
        return _t('City', 'المدينة', 'Ville');
      case 'address':
        return _t('Address', 'العنوان', 'Adresse');
      case 'phone':
        return _t('Phone', 'الهاتف', 'Téléphone');
      case 'rulename':
        return _t('Rule name', 'اسم القاعدة', 'Nom de la règle');
      case 'rate':
        return _t('Rate', 'النسبة', 'Taux');
      case 'appliestoshipping':
        return _t('Applies to shipping', 'تطبق على الشحن', 'S’applique à la livraison');
      case 'active':
        return _t('Active', 'نشط', 'Actif');
      case 'notes':
        return _t('Notes', 'ملاحظات', 'Notes');
      case 'type':
        return _t('Type', 'النوع', 'Type');
      case 'cost':
        return _t('Cost', 'الكلفة', 'Coût');
      case 'estimateddeliverytime':
        return _t('Estimated delivery time', 'وقت التوصيل المتوقع', 'Délai estimé');
      case 'minimumorderamount':
        return _t('Minimum order amount', 'الحد الأدنى للطلب', 'Montant minimum');
      case 'freeshippingthreshold':
        return _t('Free shipping threshold', 'حد الشحن المجاني', 'Seuil livraison gratuite');
      case 'branchscope':
        return _t('Branch scope', 'نطاق الفروع', 'Portée des branches');
      case 'branchnames':
        return _t('Branch names', 'أسماء الفروع', 'Noms des branches');
      case 'code':
        return _t('Code', 'الكود', 'Code');
      case 'discounttype':
        return _t('Discount type', 'نوع الخصم', 'Type de remise');
      case 'discountvalue':
        return _t('Discount value', 'قيمة الخصم', 'Valeur de remise');
      case 'maxuses':
        return _t('Max uses', 'أقصى استخدام', 'Utilisations max');
      case 'minorderamount':
        return _t('Min order amount', 'الحد الأدنى للطلب', 'Montant min');
      case 'maxdiscountamount':
        return _t('Max discount amount', 'أقصى خصم', 'Remise max');
      case 'startsat':
        return _t('Starts at', 'يبدأ في', 'Début');
      case 'expiresat':
        return _t('Expires at', 'ينتهي في', 'Expiration');
      default:
        return _prettyKey(key);
    }
  }

  String issueMessage(String message) {
    if (message.contains('must be ACTIVE or INACTIVE')) {
      return _t(message, 'القيمة يجب أن تكون ACTIVE أو INACTIVE.', 'La valeur doit être ACTIVE ou INACTIVE.');
    }
    if (message.contains('must be TRUE/FALSE')) {
      return _t(message, 'القيمة يجب أن تكون TRUE أو FALSE.', 'La valeur doit être TRUE ou FALSE.');
    }
    if (message.contains('must be a valid date')) {
      return _t(message, 'التاريخ يجب أن يكون صحيحًا، مثل 2026-05-25.', 'La date doit être valide, par exemple 2026-05-25.');
    }
    if (message.contains('must be zero or greater')) {
      return _t(message, 'القيمة يجب أن تكون صفرًا أو أكثر.', 'La valeur doit être égale ou supérieure à zéro.');
    }
    if (message.contains('must be greater than zero')) {
      return _t(message, 'القيمة يجب أن تكون أكبر من صفر.', 'La valeur doit être supérieure à zéro.');
    }
    if (message.contains('already exists')) {
      return _t(message, 'هذا السجل موجود مسبقًا.', 'Cet élément existe déjà.');
    }
    if (message.contains('duplicated')) {
      return _t(message, 'هذه القيمة مكررة داخل ملف Excel.', 'Cette valeur est dupliquée dans le fichier Excel.');
    }
    if (message.contains('was not found')) {
      return _t(message, 'لم يتم العثور على السجل المطلوب. أضيفيه في الورقة المناسبة أو أنشئيه أولًا.', 'Élément introuvable. Ajoutez-le dans la feuille correcte ou créez-le d’abord.');
    }
    return message;
  }

  // ===== Photographing a catalogue =====

  String get sourceQuestion => _t(
        'Where are your products now?',
        'وين منتجاتك حاليًا؟',
        'Où sont vos produits actuellement ?',
      );
  String get sourceFileTitle =>
      _t('I filled in your template', 'عبّيت القالب تبعكن', "J'ai rempli votre modèle");
  String get sourceFileSubtitle => _t(
        'The workbook you downloaded from here, with your products in it.',
        'ملف Excel يلي نزّلتيه من هون، وفيه منتجاتك.',
        'Le classeur téléchargé ici, avec vos produits dedans.',
      );
  String get sourceForeignTitle => _t(
        'I have a file from another system',
        'عندي ملف من نظام تاني',
        "J'ai un fichier d'un autre système",
      );
  String get sourceForeignSubtitle => _t(
        'Upload it as it is. We will work out what each column holds.',
        'ارفعيه متل ما هو، ونحنا منفهم شو يعني كل عمود.',
        'Téléversez-le tel quel. Nous déterminerons ce que contient chaque colonne.',
      );
  String get sourcePhotosTitle =>
      _t("I'll photograph them", 'رح صوّر منتجاتي', 'Je vais les photographier');
  String get sourcePhotosSubtitle => _t(
        'Take a picture of each thing. We will say what it is.',
        'صوّري كل قطعة، ورح نقول شو هي.',
        'Prenez une photo de chaque article. Nous dirons ce que c’est.',
      );

  String get photosTakeBtn => _t('Take photos', 'التقاط صور', 'Prendre des photos');
  String get photosAddMoreBtn => _t('Add more photos', 'إضافة المزيد من الصور', "Ajouter d'autres photos");
  String get photosPickBtn => _t('Choose from gallery', 'اختيار من المعرض', 'Choisir depuis la galerie');
  String get photosReading => _t('Reading the photos…', 'جارٍ قراءة الصور…', 'Lecture des photos…');
  String get photosEmpty => _t(
        'No photos yet. Take a picture of the first item.',
        'لا صور بعد. صوّري أول قطعة.',
        'Aucune photo pour le moment. Photographiez le premier article.',
      );
  String photosNeedNames(int count) => _t(
        '$count still need a name',
        'لسا $count بحاجة لاسم',
        '$count nécessitent encore un nom',
      );
  String get photoNameLabel => _t('Product name', 'اسم المنتج', 'Nom du produit');
  String get photoNameMissing => _t(
        "The assistant couldn't name this one",
        'لم يتمكن المساعد من تسمية هذه القطعة',
        "L'assistant n'a pas pu nommer cet article",
      );
  String get photoCategoryLabel => _t('Category', 'الفئة', 'Catégorie');
  String get photoPriceLabel => _t('Price', 'السعر', 'Prix');
  String get photoMoqLabel => _t('Minimum order qty', 'الحد الأدنى للطلب', 'Qté min. de commande');
  String get photoRemove => _t('Remove', 'إزالة', 'Retirer');
  String photosMissingDescriptions(int count) => _t(
        '$count have nothing written about them',
        '$count لم يُكتب عنها شيء بعد',
        "$count n'ont encore aucune description",
      );
  String get photosWriteDescriptions =>
      _t('Let the assistant write these', 'خلي المساعد يكتبها', "Laisser l'assistant les rédiger");
  String get photosWriting => _t('Writing…', 'جارٍ الكتابة…', 'Rédaction…');
  String get photosAddProductsBtn => _t('Add these products', 'إضافة هذه المنتجات', 'Ajouter ces produits');
  String get photosAddingProducts => _t('Adding…', 'جارٍ الإضافة…', 'Ajout…');

  String _prettyKey(String key) {
    final spaced = key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll(RegExp(r'[_\-]+'), ' ');
    return spaced.isEmpty ? key : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }

  /* ---------------- a file another system wrote ---------------- */

  String get foreignTitle => _t(
        'Import from another system',
        'استيراد من نظام تاني',
        "Importer depuis un autre système",
      );
  String get foreignPickFile =>
      _t('Choose your file', 'اختاري ملفك', 'Choisissez votre fichier');
  String get foreignReadingFile =>
      _t('Reading your file…', 'عم نقرا ملفك…', 'Lecture de votre fichier…');
  String get foreignNoSheets => _t(
        'Nothing in this file looks like a product list.',
        'ما في شي بهالملف بيشبه لستة منتجات.',
        "Rien dans ce fichier ne ressemble à une liste de produits.",
      );
  String get foreignSheetPickerTitle =>
      _t('Which sheet holds your products?', 'أي ورقة فيها منتجاتك؟',
          'Quelle feuille contient vos produits ?');
  String foreignSheetRows(int count) => _t(
        '$count rows',
        '$count صف',
        '$count lignes',
      );
  String get foreignColumnsTitle =>
      _t('What each column holds', 'شو فيه كل عمود', 'Ce que contient chaque colonne');
  String get foreignColumnsSubtitle => _t(
        'We read your file and guessed. Change anything we got wrong.',
        'قرينا ملفك وحزرنا. غيّري أي شي غلطنا فيه.',
        "Nous avons lu votre fichier et deviné. Corrigez ce qui est faux.",
      );
  String get foreignAiUsed => _t(
        'The assistant helped read this sheet.',
        'المساعد ساعد بقراءة هالورقة.',
        "L'assistant a aidé à lire cette feuille.",
      );
  String get foreignAiNotUsed => _t(
        'Read from the values in your file.',
        'انقرأت من القيم يلي بملفك.',
        'Lu à partir des valeurs de votre fichier.',
      );
  String get foreignNoHeading => _t('(no heading)', '(بدون عنوان)', '(sans titre)');

  String foreignField(String wireName) {
    switch (wireName) {
      case 'NAME':
        return _t('Product name', 'اسم المنتج', 'Nom du produit');
      case 'PRICE':
        return _t('Price', 'السعر', 'Prix');
      case 'STOCK':
        return _t('Quantity', 'الكمية', 'Quantité');
      case 'MOQ':
        return _t('Minimum order', 'أقل كمية للطلب', 'Commande minimum');
      case 'DESCRIPTION':
        return _t('Description', 'الوصف', 'Description');
      case 'CATEGORY':
        return _t('Category', 'الفئة', 'Catégorie');
      case 'IMAGE_URL':
        return _t('Image link', 'رابط الصورة', "Lien de l'image");
      default:
        return _t("Don't import", 'ما تستوردو', 'Ne pas importer');
    }
  }

  String get foreignReasonAgreed => _t(
        'The heading and the values agree.',
        'العنوان والقيم متفقين.',
        "Le titre et les valeurs concordent.",
      );
  String get foreignReasonFromValues => _t(
        'Read from the values.',
        'انقرأ من القيم.',
        'Lu à partir des valeurs.',
      );
  String get foreignReasonFromHeading => _t(
        'Read from the heading only.',
        'انقرأ من العنوان بس.',
        'Lu à partir du titre seulement.',
      );
  String get foreignReasonFromAssistant => _t(
        'The assistant recognised this one.',
        'المساعد عرف هيدا.',
        "L'assistant a reconnu celle-ci.",
      );
  String foreignReasonDisputed(String other) => _t(
        'The values look more like $other. Please check.',
        'القيم بتشبه أكتر $other. تأكدي منها.',
        'Les valeurs ressemblent plutôt à $other. Vérifiez.',
      );
  String get foreignReasonNoMatch => _t(
        'Nothing in the catalogue matches this.',
        'ما في شي بالكاتالوغ بيطابق هيدا.',
        'Rien dans le catalogue ne correspond.',
      );

  String get foreignNeedsName => _t(
        'Choose which column holds the product name before continuing.',
        'اختاري أي عمود فيه اسم المنتج قبل ما تكملي.',
        'Choisissez la colonne du nom du produit avant de continuer.',
      );
  String get foreignCategoryTitle =>
      _t('File these under', 'حطيهن تحت', 'Classer sous');
  String get foreignCategoryHint => _t(
        'Used when a row has no category of its own.',
        'بينستعمل لما الصف ما عندو فئة خاصة فيه.',
        "Utilisé lorsqu'une ligne n'a pas de catégorie.",
      );
  String get foreignBranchTitle =>
      _t('Count quantities at', 'احسب الكميات بـ', 'Compter les quantités à');
  String get foreignBranchHint => _t(
        'Stock belongs to a branch here. Choose one, or quantities are skipped.',
        'الكمية بتتبع لفرع هون. اختاري واحد، وإلا الكميات بتنشال.',
        "Le stock appartient à une succursale. Choisissez-en une, sinon les quantités sont ignorées.",
      );
  String get foreignBranchPick =>
      _t('Choose a branch', 'اختاري فرع', 'Choisir une succursale');
  String get foreignNoBranches => _t(
        'You have no branches yet. Add one first, or the quantities in this file are skipped.',
        'لسا ما عندك فروع. اعملي فرع أول، وإلا الكميات يلي بهالملف بتنشال.',
        "Vous n'avez pas encore de succursale. Créez-en une, sinon les quantités de ce fichier sont ignorées.",
      );

  String get foreignContinue => _t('Continue', 'كمّل', 'Continuer');
  String get foreignBackToColumns =>
      _t('Back to columns', 'ارجع للأعمدة', 'Retour aux colonnes');
  String get foreignPreviewTitle =>
      _t('What will be created', 'شو رح ينتعمل', 'Ce qui sera créé');
  String foreignPreviewCount(int count) => _t(
        '$count products',
        '$count منتج',
        '$count produits',
      );
  String foreignSkippedRows(int count) => _t(
        '$count rows had no name and were skipped.',
        '$count صف ما عندن اسم وانشالوا.',
        "$count lignes sans nom ont été ignorées.",
      );
  String foreignNeedingAttention(int count) => _t(
        '$count need a look.',
        '$count بدهن نظرة.',
        '$count à vérifier.',
      );
  String get foreignIssueNoPrice => _t('No price', 'ما في سعر', 'Pas de prix');
  String get foreignNoteNoQuantity =>
      _t('No quantity', 'ما في كمية', 'Pas de quantité');
  String get foreignNoteStockNeedsBranch => _t(
        'Quantity needs a branch',
        'الكمية بدها فرع',
        'La quantité nécessite une succursale',
      );
  String get foreignDescriptionHint => _t(
        'What this product says about itself.',
        'شو بيقول هالمنتج عن حالو.',
        'Ce que ce produit dit de lui-même.',
      );
  String foreignMissingDescriptions(int count) => _t(
        '$count products have nothing written about them.',
        '$count منتج ما مكتوب عنن شي.',
        '$count produits sans description.',
      );
  String get foreignWriteDescriptions =>
      _t('Write them', 'اكتبهن', 'Les rédiger');
  String get foreignWritingDescriptions =>
      _t('Writing…', 'عم نكتب…', 'Rédaction…');
  String get foreignImport => _t('Import these', 'استوردهن', 'Importer');
  String get foreignImporting => _t('Importing…', 'عم نستورد…', 'Importation…');
  String get foreignNothingToImport => _t(
        'There is nothing to import from this sheet.',
        'ما في شي لنستوردو من هالورقة.',
        'Il n\'y a rien à importer depuis cette feuille.',
      );
}

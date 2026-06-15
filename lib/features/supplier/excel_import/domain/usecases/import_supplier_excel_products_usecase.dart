import '../../../branches/domain/entities/branch_entity.dart';
import '../../../branches/domain/entities/branch_inventory_item_entity.dart';
import '../../../branches/domain/usecases/assign_product_to_branch_usecase.dart';
import '../../../branches/domain/usecases/create_branch_usecase.dart';
import '../../../branches/domain/usecases/get_branches_usecase.dart';
import '../../../branches/domain/usecases/get_inventory_by_branch_usecase.dart';
import '../../../branches/domain/usecases/update_branch_stock_usecase.dart';
import '../../../categories/domain/entities/supplier_category_entity.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../../categories/domain/usecases/create_category_usecase.dart';
import '../../../categories/domain/usecases/create_subcategory_usecase.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../../categories/domain/usecases/get_subcategories_by_category_usecase.dart';
import '../../../coupons/domain/entities/coupon_entity.dart';
import '../../../promotions/domain/entities/promotion_entity.dart';
import '../../../promotions/domain/usecases/create_promotion_usecase.dart';
import '../../../promotions/domain/usecases/get_promotions_usecase.dart';
import '../../../banners/domain/entities/banner_entity.dart';
import '../../../banners/domain/usecases/create_banner_usecase.dart';
import '../../../banners/domain/usecases/get_banners_usecase.dart';
import '../../../coupons/domain/usecases/create_coupon_usecase.dart';
import '../../../coupons/domain/usecases/get_coupons_usecase.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/usecases/create_product_usecase.dart';
import '../../../products/domain/usecases/get_products_usecase.dart';
import '../../../shipping/data/models/shipping_location_model.dart';
import '../../../shipping/data/services/shipping_location_api_service.dart';
import '../../../shipping/domain/entities/shipping_method_entity.dart';
import '../../../shipping/domain/usecases/create_shipping_method_usecase.dart';
import '../../../shipping/domain/usecases/get_shipping_methods_usecase.dart';
import '../../../tax/domain/entities/tax_rule_entity.dart';
import '../../../tax/domain/usecases/create_tax_rule_usecase.dart';
import '../../../tax/domain/usecases/get_tax_rules_usecase.dart';
import '../../../tax/domain/usecases/update_tax_rule_usecase.dart';
import '../entities/supplier_excel_import_result_entity.dart';
import '../entities/supplier_excel_parsed_file_entity.dart';
import '../entities/supplier_excel_row_entity.dart';
import '../entities/supplier_excel_section.dart';

class ImportSupplierExcelProductsUseCase {
  final CreateCategoryUseCase createCategoryUseCase;
  final CreateSubCategoryUseCase createSubCategoryUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubCategoriesByCategoryUseCase getSubCategoriesByCategoryUseCase;
  final CreateBranchUseCase createBranchUseCase;
  final GetBranchesUseCase getBranchesUseCase;
  final CreateProductUseCase createProductUseCase;
  final GetProductsUseCase getProductsUseCase;
  final AssignProductToBranchUseCase assignProductToBranchUseCase;
  final GetInventoryByBranchUseCase getInventoryByBranchUseCase;
  final UpdateBranchStockUseCase updateBranchStockUseCase;
  final CreateShippingMethodUseCase createShippingMethodUseCase;
  final GetShippingMethodsUseCase getShippingMethodsUseCase;
  final CreateTaxRuleUseCase createTaxRuleUseCase;
  final GetTaxRulesUseCase getTaxRulesUseCase;
  final UpdateTaxRuleUseCase updateTaxRuleUseCase;
  final CreateCouponUseCase createCouponUseCase;
  final GetCouponsUseCase getCouponsUseCase;
  final ShippingLocationApiService shippingLocationApiService;
  final CreatePromotionUseCase createPromotionUseCase;
  final GetPromotionsUseCase getPromotionsUseCase;
  final CreateBannerUseCase createBannerUseCase;
  final GetBannersUseCase getBannersUseCase;

  ImportSupplierExcelProductsUseCase({
    required this.createCategoryUseCase,
    required this.createSubCategoryUseCase,
    required this.getCategoriesUseCase,
    required this.getSubCategoriesByCategoryUseCase,
    required this.createBranchUseCase,
    required this.getBranchesUseCase,
    required this.createProductUseCase,
    required this.getProductsUseCase,
    required this.assignProductToBranchUseCase,
    required this.getInventoryByBranchUseCase,
    required this.updateBranchStockUseCase,
    required this.createShippingMethodUseCase,
    required this.getShippingMethodsUseCase,
    required this.createTaxRuleUseCase,
    required this.getTaxRulesUseCase,
    required this.updateTaxRuleUseCase,
    required this.createCouponUseCase,
    required this.getCouponsUseCase,
    required this.shippingLocationApiService,
    required this.createPromotionUseCase,
    required this.getPromotionsUseCase,
    required this.createBannerUseCase,
    required this.getBannersUseCase,
  });

  Future<SupplierExcelImportResultEntity> call({
    required SupplierExcelParsedFileEntity parsedFile,
  }) async {
    final messages = <String>[];
    final failedMessages = <String>[];
    var importedCount = 0;

    var categoriesByName = await _loadCategoriesByName();
    final subCategoriesByCategory = await _loadSubCategories(categoriesByName.values);
    var branchesByName = await _loadBranchesByName();
    var productsByName = await _loadProductsByName();
    var promotionsByTitle = await _loadPromotionsByTitle();
    var bannersByTitle = await _loadBannersByTitle();
    final locations = await _loadLocations();
    var shippingByName = await _loadShippingMethodsByName();
    var taxByScope = await _loadTaxRulesByScope();
    var couponsByCode = await _loadCouponsByCode();

    Future<void> runRow(
      SupplierExcelRowEntity row,
      Future<void> Function() action,
    ) async {
      if (!row.isValid) {
        failedMessages.add(
          '${row.section.templateTitle} row ${row.rowNumber}: ${row.errors.join(' ')}',
        );
        return;
      }

      try {
        await action();
        importedCount++;
      } catch (error) {
        failedMessages.add(
          '${row.section.templateTitle} row ${row.rowNumber}: ${_message(error)}',
        );
      }
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.categories)) {
      await runRow(row, () async {
        final name = row.value('Name').trim();
        final key = _n(name);

        if (categoriesByName.containsKey(key)) {
          messages.add('Category "$name" already exists. Skipped.');
          return;
        }

        final created = await createCategoryUseCase(name: name);
        categoriesByName[key] = created;
        subCategoriesByCategory[created.id] = <SupplierSubCategoryEntity>[];
        messages.add('Category "$name" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.subCategories)) {
      await runRow(row, () async {
        final categoryName = row.value('Category').trim();
        final subCategoryName = row.value('SubCategory').trim();
        final category = categoriesByName[_n(categoryName)];

        if (category == null) {
          throw Exception('Category "$categoryName" was not found.');
        }

        final existing = (subCategoriesByCategory[category.id] ?? const <SupplierSubCategoryEntity>[])
            .where((subCategory) => _n(subCategory.name) == _n(subCategoryName))
            .cast<SupplierSubCategoryEntity?>()
            .firstWhere((subCategory) => subCategory != null, orElse: () => null);

        if (existing != null) {
          messages.add('SubCategory "$subCategoryName" already exists. Skipped.');
          return;
        }

        final created = await createSubCategoryUseCase(
          categoryId: category.id,
          name: subCategoryName,
        );

        subCategoriesByCategory.putIfAbsent(category.id, () => <SupplierSubCategoryEntity>[]).add(created);
        messages.add('SubCategory "$subCategoryName" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.branches)) {
      await runRow(row, () async {
        final name = row.value('Branch Name').trim();
        final key = _n(name);

        if (branchesByName.containsKey(key)) {
          messages.add('Branch "$name" already exists. Skipped.');
          return;
        }

        final created = await createBranchUseCase(
          name: name,
          countryCode: row.value('Country Code').trim().toUpperCase(),
          regionId: _int(row.value('Region ID')),
          city: row.value('City').trim(),
          address: row.value('Address').trim(),
          phoneNumber: row.value('Phone').trim(),
          status: _branchStatus(row.value('Status')),
        );

        branchesByName[key] = created;
        messages.add('Branch "$name" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.products)) {
      await runRow(row, () async {
        final name = row.value('Product Name').trim();
        final key = _n(name);

        if (productsByName.containsKey(key)) {
          messages.add('Product "$name" already exists. Skipped.');
          return;
        }

        final category = categoriesByName[_n(row.value('Category'))];
        if (category == null) {
          throw Exception('Category "${row.value('Category')}" was not found.');
        }

        final subCategoryName = row.value('SubCategory').trim();
        String? subCategoryId;

        if (subCategoryName.isNotEmpty) {
          final subCategory = (subCategoriesByCategory[category.id] ?? const <SupplierSubCategoryEntity>[])
              .where((item) => _n(item.name) == _n(subCategoryName))
              .cast<SupplierSubCategoryEntity?>()
              .firstWhere((item) => item != null, orElse: () => null);
          subCategoryId = subCategory?.id;
        }

        final created = await createProductUseCase(
          name: name,
          description: row.value('Description').trim(),
          categoryId: category.id,
          subCategoryId: subCategoryId,
          price: _double(row.value('Price')) ?? 0,
          minimumOrderQuantity: _int(row.value('MOQ')) ?? 5,
          status: _productStatus(row.value('Status')),
          imagePath: _clean(row.value('Image Url')),
        );

        productsByName[key] = created;
        messages.add('Product "$name" imported.');
      });
    }

    productsByName = await _loadProductsByName();

    for (final row in parsedFile.rowsFor(SupplierExcelSection.inventory)) {
      await runRow(row, () async {
        final branchName = row.value('Branch').trim();
        final productName = row.value('Product Name').trim();
        final branch = branchesByName[_n(branchName)];
        final product = productsByName[_n(productName)];

        if (branch == null) throw Exception('Branch "$branchName" was not found.');
        if (product == null) throw Exception('Product "$productName" was not found.');

        final stock = _int(row.value('Stock Quantity')) ?? 0;
        final existingInventory = await _findInventory(
          branchId: branch.id,
          productId: product.id,
        );

        if (existingInventory == null) {
          await assignProductToBranchUseCase(
            branchId: branch.id,
            productId: product.id,
            stockQuantity: stock,
          );
        } else {
          await updateBranchStockUseCase(
            inventoryId: existingInventory.id,
            stockQuantity: stock,
          );
        }

        messages.add('Stock for "$productName" in "$branchName" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.taxRules)) {
      await runRow(row, () async {
        final ruleName = row.value('Rule Name').trim();
        final country = _resolveCountry(row, locations);
        final region = await _resolveRegion(row, country, locations);
        final active = _bool(row.value('Active'), defaultValue: true);
        final scopeKey = _taxScopeKey(country.id, region?.id);
        final existingRule = taxByScope[scopeKey];

        final now = DateTime.now();
        final taxRuleFromExcel = TaxRuleEntity(
          id: existingRule?.id ?? '',
          ruleName: ruleName,
          rate: _double(row.value('Rate')) ?? 0,
          countryId: country.id,
          countryName: country.name,
          countryIso2Code: country.iso2Code,
          countryIso3Code: country.iso3Code,
          regionId: region?.id,
          regionName: region?.name,
          regionCode: region?.code,
          appliesToShipping: _bool(
            row.value('Applies To Shipping'),
            defaultValue: false,
          ),
          active: active,
          status: active ? 'ACTIVE' : 'INACTIVE',
          notes: _clean(row.value('Notes')),
          createdAt: existingRule?.createdAt ?? now,
          updatedAt: now,
        );

        if (existingRule != null) {
          final updated = await updateTaxRuleUseCase(taxRuleFromExcel);
          taxByScope[_taxScopeKey(updated.countryId, updated.regionId)] =
              updated;
          messages.add(
            'Tax rule "$ruleName" updated for ${country.name}${region == null ? '' : ' / ${region.name}'}.',
          );
          return;
        }

        final created = await createTaxRuleUseCase(taxRuleFromExcel);
        taxByScope[_taxScopeKey(created.countryId, created.regionId)] = created;
        messages.add('Tax rule "$ruleName" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.shippingMethods)) {
      await runRow(row, () async {
        final name = row.value('Name').trim();
        final key = _n(name);

        if (shippingByName.containsKey(key)) {
          messages.add('Shipping method "$name" already exists. Skipped.');
          return;
        }

        final methodType = _shippingType(row.value('Type'));
        final isPickup = methodType == ShippingMethodType.pickup;
        final country = _resolveCountry(row, locations);
        final region = await _resolveRegion(row, country, locations);
        final active = _bool(row.value('Active'), defaultValue: true);
        final now = DateTime.now();

        final created = await createShippingMethodUseCase(
          ShippingMethodEntity(
            id: '',
            name: name,
            methodType: methodType,
            countryId: country.id,
            countryName: country.name,
            countryIso2Code: country.iso2Code,
            countryIso3Code: country.iso3Code,
            regionId: region?.id,
            regionName: region?.name,
            regionCode: region?.code,
            cost: isPickup ? 0 : (_double(row.value('Cost')) ?? 0),
            estimatedDeliveryTime: isPickup
                ? 'Pickup from branch'
                : row.value('Estimated Delivery Time').trim(),
            minimumOrderAmount: _double(row.value('Minimum Order Amount')),
            freeShippingThreshold: isPickup ? null : _double(row.value('Free Shipping Threshold')),
            branchScope: _shippingBranchScope(row.value('Branch Scope')),
            selectedBranchIds: _branchIdsFromNames(row.value('Branch Names'), branchesByName),
            selectedBranchNames: _branchNamesFromNames(row.value('Branch Names'), branchesByName),
            active: active,
            status: active ? 'ACTIVE' : 'INACTIVE',
            notes: _clean(row.value('Notes')),
            createdAt: now,
            updatedAt: now,
          ),
        );

        shippingByName[_n(created.name)] = created;
        messages.add('Shipping method "$name" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.coupons)) {
      await runRow(row, () async {
        final code = row.value('Code').trim().toUpperCase();
        if (couponsByCode.containsKey(_n(code))) {
          messages.add('Coupon "$code" already exists. Skipped.');
          return;
        }

        final created = await createCouponUseCase(
          CouponEntity(
            id: '',
            ownerProjectId: 0,
            code: code,
            description: _clean(row.value('Description')),
            discountType: _couponDiscountType(row.value('Discount Type')),
            discountValue: _double(row.value('Discount Value')) ?? 0,
            maxUses: _int(row.value('Max Uses')),
            minOrderAmount: _double(row.value('Min Order Amount')),
            maxDiscountAmount: _double(row.value('Max Discount Amount')),
            startsAt: _date(row.value('Starts At')),
            expiresAt: _date(row.value('Expires At')),
            active: _bool(row.value('Active'), defaultValue: true),
            branchScope: _couponBranchScope(row.value('Branch Scope')),
            selectedBranchIds: _branchIdsFromNames(row.value('Branch Names'), branchesByName),
            selectedBranchNames: _branchNamesFromNames(row.value('Branch Names'), branchesByName),
          ),
        );

        couponsByCode[_n(created.code)] = created;
        messages.add('Coupon "$code" imported.');
      });
    }

    productsByName = await _loadProductsByName();
    categoriesByName = await _loadCategoriesByName();
    final allSubCategories = subCategoriesByCategory.values.expand((items) => items).toList();

    for (final row in parsedFile.rowsFor(SupplierExcelSection.promotions)) {
      await runRow(row, () async {
        final title = row.value('Title').trim();
        final key = _n(title);

        if (promotionsByTitle.containsKey(key)) {
          messages.add('Promotion "$title" already exists. Skipped.');
          return;
        }

        final targetType = _promotionTargetType(row.value('Target Type'));
        final targetName = row.value('Target Name').trim();
        String? targetId;
        String? resolvedTargetName;

        if (targetType == PromotionTargetType.product) {
          final product = productsByName[_n(targetName)];
          if (product == null) throw Exception('Promotion target product "$targetName" was not found.');
          targetId = product.id;
          resolvedTargetName = product.name;
        } else if (targetType == PromotionTargetType.category) {
          final category = categoriesByName[_n(targetName)];
          if (category == null) throw Exception('Promotion target category "$targetName" was not found.');
          targetId = category.id;
          resolvedTargetName = category.name;
        }

        final now = DateTime.now();
        final created = await createPromotionUseCase(
          PromotionEntity(
            id: '',
            title: title,
            description: _clean(row.value('Description')),
            discountType: _promotionDiscountType(row.value('Discount Type')),
            discountValue: _double(row.value('Discount Value')) ?? 0,
            targetType: targetType,
            targetId: targetId,
            targetName: resolvedTargetName,
            minOrderAmount: _double(row.value('Min Order Amount')),
            maxDiscountAmount: _double(row.value('Max Discount Amount')),
            startDate: _date(row.value('Start Date')),
            endDate: _date(row.value('End Date')),
            active: _bool(row.value('Active'), defaultValue: true),
            branchScope: PromotionBranchScope.allBranches,
            selectedBranchIds: const [],
            selectedBranchNames: const [],
            createdAt: now,
            updatedAt: now,
          ),
        );

        promotionsByTitle[_n(created.title)] = created;
        messages.add('Promotion "$title" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.banners)) {
      await runRow(row, () async {
        final title = row.value('Title').trim();
        final key = _n(title);

        if (bannersByTitle.containsKey(key)) {
          messages.add('Banner "$title" already exists. Skipped.');
          return;
        }

        final targetType = _bannerTargetType(row.value('Target Type'));
        final targetValueText = row.value('Target Value').trim();
        String? targetValue;
        String? targetLabel;

        if (targetType == BannerTargetType.product) {
          final product = productsByName[_n(targetValueText)];
          if (product == null) throw Exception('Banner target product "$targetValueText" was not found.');
          targetValue = product.id;
          targetLabel = product.name;
        } else if (targetType == BannerTargetType.category) {
          final category = categoriesByName[_n(targetValueText)];
          if (category == null) throw Exception('Banner target category "$targetValueText" was not found.');
          targetValue = category.id;
          targetLabel = category.name;
        } else if (targetType == BannerTargetType.subcategory) {
          final subCategory = allSubCategories
              .where((item) => _n(item.name) == _n(targetValueText))
              .cast<SupplierSubCategoryEntity?>()
              .firstWhere((item) => item != null, orElse: () => null);
          if (subCategory == null) throw Exception('Banner target subcategory "$targetValueText" was not found.');
          targetValue = subCategory.id;
          targetLabel = subCategory.name;
        } else if (targetType == BannerTargetType.url) {
          targetValue = _clean(targetValueText);
          targetLabel = targetValue;
        }

        final now = DateTime.now();
        final created = await createBannerUseCase(
          BannerEntity(
            id: '',
            title: title,
            subtitle: _clean(row.value('Subtitle')),
            imageUrl: row.value('Image URL').trim(),
            targetType: targetType,
            targetValue: targetValue,
            targetLabel: targetLabel,
            sortOrder: _int(row.value('Sort Order')) ?? 0,
            startsAt: _date(row.value('Start Date')),
            expiresAt: _date(row.value('End Date')),
            active: _bool(row.value('Active'), defaultValue: true),
            createdAt: now,
            updatedAt: now,
          ),
        );

        bannersByTitle[_n(created.title)] = created;
        messages.add('Banner "$title" imported.');
      });
    }

    return SupplierExcelImportResultEntity(
      totalRows: parsedFile.totalRows,
      importedCount: importedCount,
      failedCount: failedMessages.length,
      messages: messages,
      failedMessages: failedMessages,
    );
  }

  Future<Map<String, SupplierCategoryEntity>> _loadCategoriesByName() async {
    final categories = await getCategoriesUseCase();
    return {
      for (final category in categories) _n(category.name): category,
    };
  }

  Future<Map<String, List<SupplierSubCategoryEntity>>> _loadSubCategories(
    Iterable<SupplierCategoryEntity> categories,
  ) async {
    final result = <String, List<SupplierSubCategoryEntity>>{};

    for (final category in categories) {
      result[category.id] = await getSubCategoriesByCategoryUseCase(categoryId: category.id);
    }

    return result;
  }

  Future<Map<String, BranchEntity>> _loadBranchesByName() async {
    final branches = await getBranchesUseCase();
    return {
      for (final branch in branches) _n(branch.name): branch,
    };
  }

  Future<Map<String, ProductEntity>> _loadProductsByName() async {
    final products = await getProductsUseCase();
    return {
      for (final product in products) _n(product.name): product,
    };
  }


  Future<_LocationCache> _loadLocations() async {
    final countries = await shippingLocationApiService.getCountries();
    return _LocationCache(countries: countries);
  }

  Future<Map<String, ShippingMethodEntity>> _loadShippingMethodsByName() async {
    final methods = await getShippingMethodsUseCase();
    return {
      for (final method in methods) _n(method.name): method,
    };
  }

  Future<Map<String, TaxRuleEntity>> _loadTaxRulesByScope() async {
    final rules = await getTaxRulesUseCase();
    return {
      for (final rule in rules)
        if (rule.active) _taxScopeKey(rule.countryId, rule.regionId): rule,
    };
  }

  Future<Map<String, CouponEntity>> _loadCouponsByCode() async {
    final coupons = await getCouponsUseCase();
    return {
      for (final coupon in coupons) _n(coupon.code): coupon,
    };
  }

  Future<Map<String, PromotionEntity>> _loadPromotionsByTitle() async {
    final promotions = await getPromotionsUseCase();
    return {
      for (final promotion in promotions) _n(promotion.title): promotion,
    };
  }

  Future<Map<String, BannerEntity>> _loadBannersByTitle() async {
    final banners = await getBannersUseCase();
    return {
      for (final banner in banners) _n(banner.title): banner,
    };
  }

  Future<BranchInventoryItemEntity?> _findInventory({
    required String branchId,
    required String productId,
  }) async {
    final items = await getInventoryByBranchUseCase(branchId: branchId);

    return items
        .where((item) => item.productId == productId)
        .cast<BranchInventoryItemEntity?>()
        .firstWhere((item) => item != null, orElse: () => null);
  }

  List<String> _branchIdsFromNames(
    String rawNames,
    Map<String, BranchEntity> branchesByName,
  ) {
    if (_n(rawNames).isEmpty || _n(rawNames) == 'all') return const [];

    return rawNames
        .split(RegExp(r'[,;]'))
        .map((name) => branchesByName[_n(name)])
        .whereType<BranchEntity>()
        .map((branch) => branch.id)
        .toList();
  }

  List<String> _branchNamesFromNames(
    String rawNames,
    Map<String, BranchEntity> branchesByName,
  ) {
    if (_n(rawNames).isEmpty || _n(rawNames) == 'all') return const [];

    return rawNames
        .split(RegExp(r'[,;]'))
        .map((name) => branchesByName[_n(name)])
        .whereType<BranchEntity>()
        .map((branch) => branch.name)
        .toList();
  }


  ShippingCountryModel _resolveCountry(
    SupplierExcelRowEntity row,
    _LocationCache locations,
  ) {
    final countryId = row.value('Country ID').trim();
    final countryName = row.value('Country Name').trim();
    final countryCode = row.value('Country Code').trim();

    ShippingCountryModel? country;

    if (countryId.isNotEmpty) {
      country = locations.countries
          .where((item) => item.id == countryId)
          .cast<ShippingCountryModel?>()
          .firstWhere((item) => item != null, orElse: () => null);
    }

    country ??= locations.countries
        .where((item) =>
            _n(item.name) == _n(countryName) ||
            _n(item.iso2Code) == _n(countryName) ||
            _n(item.iso3Code) == _n(countryName) ||
            _n(item.iso2Code) == _n(countryCode) ||
            _n(item.iso3Code) == _n(countryCode))
        .cast<ShippingCountryModel?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (country == null) {
      final label = countryName.isNotEmpty
          ? countryName
          : countryCode.isNotEmpty
              ? countryCode
              : countryId;
      throw Exception('Country "$label" was not found. Use a valid country name/code from the app location list.');
    }

    return country;
  }

  Future<ShippingRegionModel?> _resolveRegion(
    SupplierExcelRowEntity row,
    ShippingCountryModel country,
    _LocationCache locations,
  ) async {
    final regions = await locations.regionsFor(
      country.id,
      shippingLocationApiService,
    );

    if (regions.isEmpty) return null;

    final regionId = row.value('Region ID').trim();
    final regionName = row.value('Region Name').trim();

    ShippingRegionModel? region;

    if (regionId.isNotEmpty) {
      region = regions
          .where((item) => item.id == regionId)
          .cast<ShippingRegionModel?>()
          .firstWhere((item) => item != null, orElse: () => null);
    }

    region ??= regions
        .where((item) =>
            _n(item.name) == _n(regionName) ||
            _n(item.code) == _n(regionName))
        .cast<ShippingRegionModel?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (country.isLebanon && region == null) {
      final label = regionName.isNotEmpty ? regionName : regionId;
      throw Exception('Region "$label" was not found for Lebanon. Use a valid Region Name from the app.');
    }

    return region;
  }

  String _taxScopeKey(String countryId, String? regionId) {
    return '${countryId.trim()}|${(regionId ?? '').trim()}';
  }

  BranchStatus _branchStatus(String value) {
    return _n(value) == 'inactive' ? BranchStatus.inactive : BranchStatus.active;
  }

  ProductStatus _productStatus(String value) {
    return _n(value) == 'inactive' ? ProductStatus.inactive : ProductStatus.active;
  }

  ShippingMethodType _shippingType(String value) {
    final normalized = _n(value);
    if (normalized == 'express' || normalized == 'expressdelivery') {
      return ShippingMethodType.expressDelivery;
    }
    if (normalized == 'pickup' || normalized == 'pickupfrombranch') {
      return ShippingMethodType.pickup;
    }
    return ShippingMethodType.standardDelivery;
  }

  ShippingBranchScope _shippingBranchScope(String value) {
    return _n(value).contains('selected')
        ? ShippingBranchScope.selectedBranches
        : ShippingBranchScope.allBranches;
  }

  CouponDiscountType _couponDiscountType(String value) {
    final normalized = _n(value);
    if (normalized == 'fixed') return CouponDiscountType.fixed;
    if (normalized == 'freeshipping' || normalized == 'free_shipping') {
      return CouponDiscountType.freeShipping;
    }
    return CouponDiscountType.percent;
  }

  CouponBranchScope _couponBranchScope(String value) {
    return _n(value).contains('selected')
        ? CouponBranchScope.selectedBranches
        : CouponBranchScope.allBranches;
  }

  PromotionDiscountType _promotionDiscountType(String value) {
    final normalized = _n(value);
    if (normalized == 'fixed' || normalized == 'fixedamount') {
      return PromotionDiscountType.fixed;
    }
    return PromotionDiscountType.percent;
  }

  PromotionTargetType _promotionTargetType(String value) {
    final normalized = _n(value);
    if (normalized == 'category') return PromotionTargetType.category;
    return PromotionTargetType.product;
  }

  BannerTargetType _bannerTargetType(String value) {
    final normalized = _n(value);
    if (normalized == 'product') return BannerTargetType.product;
    if (normalized == 'category') return BannerTargetType.category;
    if (normalized == 'subcategory') return BannerTargetType.subcategory;
    if (normalized == 'url') return BannerTargetType.url;
    return BannerTargetType.none;
  }

  bool _bool(String value, {required bool defaultValue}) {
    final normalized = _n(value);
    if (normalized.isEmpty) return defaultValue;
    return ['true', 'yes', '1', 'active', 'enabled'].contains(normalized);
  }

  double? _double(String value) {
    final cleaned = value.trim().replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  int? _int(String value) {
    final numeric = double.tryParse(value.trim().replaceAll(',', '.'));
    return numeric?.round();
  }

  DateTime? _date(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;

    final normalizedIso = text.contains(' ') ? text.replaceFirst(' ', 'T') : text;
    final parsed = DateTime.tryParse(normalizedIso);
    if (parsed != null) return parsed;

    final excelNumber = double.tryParse(text);
    if (excelNumber != null && excelNumber > 0) {
      final wholeDays = excelNumber.floor();
      final fraction = excelNumber - wholeDays;
      final seconds = (fraction * 86400).round();
      return DateTime(1899, 12, 30)
          .add(Duration(days: wholeDays, seconds: seconds));
    }

    final parts = text.split(RegExp(r'[\/\-]'));
    if (parts.length == 3) {
      final first = int.tryParse(parts[0]);
      final second = int.tryParse(parts[1]);
      final thirdText = parts[2].split(RegExp(r'\s+')).first;
      final third = int.tryParse(thirdText);

      if (first != null && second != null && third != null) {
        if (parts[0].length == 4) return DateTime(first, second, third);
        if (thirdText.length == 4) return DateTime(third, second, first);
      }
    }

    return null;
  }

  String? _clean(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  String _n(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');
  }

  String _message(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}


class _LocationCache {
  final List<ShippingCountryModel> countries;
  final Map<String, List<ShippingRegionModel>> _regionsByCountryId = {};

  _LocationCache({required this.countries});

  Future<List<ShippingRegionModel>> regionsFor(
    String countryId,
    ShippingLocationApiService service,
  ) async {
    if (_regionsByCountryId.containsKey(countryId)) {
      return _regionsByCountryId[countryId]!;
    }

    final regions = await service.getRegionsByCountry(countryId);
    _regionsByCountryId[countryId] = regions;
    return regions;
  }
}

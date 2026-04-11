import 'package:flutter/widgets.dart';
import 'package:build4all_wholesale_frontend/l10n/app_localizations.dart';

extension SelectOptionLocalization on BuildContext {
  String trOption(String labelKey) {
    final l10n = AppLocalizations.of(this)!;

    switch (labelKey) {
      case 'cityBeirut':
        return l10n.cityBeirut;
      case 'cityTripoli':
        return l10n.cityTripoli;
      case 'citySidon':
        return l10n.citySidon;
      case 'cityTyre':
        return l10n.cityTyre;
      case 'cityZahle':
        return l10n.cityZahle;
      case 'cityJounieh':
        return l10n.cityJounieh;
      case 'cityNabatieh':
        return l10n.cityNabatieh;
      case 'cityByblos':
        return l10n.cityByblos;
      case 'cityAley':
        return l10n.cityAley;
      case 'cityBaalbek':
        return l10n.cityBaalbek;

      case 'businessMiniMarket':
        return l10n.businessMiniMarket;
      case 'businessSupermarket':
        return l10n.businessSupermarket;
      case 'businessPharmacy':
        return l10n.businessPharmacy;
      case 'businessRestaurant':
        return l10n.businessRestaurant;
      case 'businessCafe':
        return l10n.businessCafe;
      case 'businessRetailShop':
        return l10n.businessRetailShop;

      case 'businessBuildingMaterials':
        return l10n.businessBuildingMaterials;
      case 'businessElectricalSupplies':
        return l10n.businessElectricalSupplies;
      case 'businessPlumbing':
        return l10n.businessPlumbing;
      case 'businessToolsHardware':
        return l10n.businessToolsHardware;
      case 'businessIndustrialEquipment':
        return l10n.businessIndustrialEquipment;
      case 'businessHomeImprovement':
        return l10n.businessHomeImprovement;
      case 'businessWholesaleDistribution':
        return l10n.businessWholesaleDistribution;
      case 'businessOther':
        return l10n.businessOther;

      default:
        return labelKey;
    }
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'B2B Wholesale App'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @supplierManager.
  ///
  /// In en, this message translates to:
  /// **'Supplier Manager'**
  String get supplierManager;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your wholesale account'**
  String get loginSubtitle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @createRetailerAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Retailer Account'**
  String get createRetailerAccount;

  /// No description provided for @joinMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Join our wholesale marketplace'**
  String get joinMarketplace;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @storeAddress.
  ///
  /// In en, this message translates to:
  /// **'Store Address'**
  String get storeAddress;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @businessType.
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get businessType;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @completeSupplierProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Supplier Profile'**
  String get completeSupplierProfile;

  /// No description provided for @completeSupplierProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Supplier Profile'**
  String get completeSupplierProfileTitle;

  /// No description provided for @completeSupplierProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide your business information to continue'**
  String get completeSupplierProfileSubtitle;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @companyAddress.
  ///
  /// In en, this message translates to:
  /// **'Company Address'**
  String get companyAddress;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @logoUrl.
  ///
  /// In en, this message translates to:
  /// **'Logo URL'**
  String get logoUrl;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and Continue'**
  String get saveAndContinue;

  /// No description provided for @supplierDashboard.
  ///
  /// In en, this message translates to:
  /// **'Supplier Dashboard'**
  String get supplierDashboard;

  /// No description provided for @retailerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Retailer Dashboard'**
  String get retailerDashboard;

  /// No description provided for @dashboardPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Placeholder'**
  String get dashboardPlaceholder;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @resetToken.
  ///
  /// In en, this message translates to:
  /// **'Reset Token'**
  String get resetToken;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @enterValidLebanesePhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Lebanese phone number'**
  String get enterValidLebanesePhone;

  /// No description provided for @userSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'User session not found. Please login again.'**
  String get userSessionNotFound;

  /// No description provided for @supplierProfileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Supplier profile saved successfully'**
  String get supplierProfileSavedSuccessfully;

  /// No description provided for @retailerProfileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Retailer profile updated successfully'**
  String get retailerProfileUpdatedSuccessfully;

  /// No description provided for @provideBusinessInfoToContinue.
  ///
  /// In en, this message translates to:
  /// **'Provide your business information to continue'**
  String get provideBusinessInfoToContinue;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter your company name'**
  String get enterCompanyName;

  /// No description provided for @enterCompanyAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your company address'**
  String get enterCompanyAddress;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select city'**
  String get selectCity;

  /// No description provided for @selectBusinessType.
  ///
  /// In en, this message translates to:
  /// **'Select business type'**
  String get selectBusinessType;

  /// No description provided for @tellAboutBusiness.
  ///
  /// In en, this message translates to:
  /// **'Tell retailers about your company and products'**
  String get tellAboutBusiness;

  /// No description provided for @pasteResetToken.
  ///
  /// In en, this message translates to:
  /// **'Paste your reset token'**
  String get pasteResetToken;

  /// No description provided for @enterEmailToGenerateResetToken.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to generate a reset token'**
  String get enterEmailToGenerateResetToken;

  /// No description provided for @enterResetTokenAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your reset token and choose a new password'**
  String get enterResetTokenAndPassword;

  /// No description provided for @saveLanguage.
  ///
  /// In en, this message translates to:
  /// **'Save Language'**
  String get saveLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @cityBeirut.
  ///
  /// In en, this message translates to:
  /// **'Beirut'**
  String get cityBeirut;

  /// No description provided for @cityTripoli.
  ///
  /// In en, this message translates to:
  /// **'Tripoli'**
  String get cityTripoli;

  /// No description provided for @citySidon.
  ///
  /// In en, this message translates to:
  /// **'Sidon'**
  String get citySidon;

  /// No description provided for @cityTyre.
  ///
  /// In en, this message translates to:
  /// **'Tyre'**
  String get cityTyre;

  /// No description provided for @cityZahle.
  ///
  /// In en, this message translates to:
  /// **'Zahle'**
  String get cityZahle;

  /// No description provided for @cityJounieh.
  ///
  /// In en, this message translates to:
  /// **'Jounieh'**
  String get cityJounieh;

  /// No description provided for @cityNabatieh.
  ///
  /// In en, this message translates to:
  /// **'Nabatieh'**
  String get cityNabatieh;

  /// No description provided for @cityByblos.
  ///
  /// In en, this message translates to:
  /// **'Byblos'**
  String get cityByblos;

  /// No description provided for @cityAley.
  ///
  /// In en, this message translates to:
  /// **'Aley'**
  String get cityAley;

  /// No description provided for @cityBaalbek.
  ///
  /// In en, this message translates to:
  /// **'Baalbek'**
  String get cityBaalbek;

  /// No description provided for @businessMiniMarket.
  ///
  /// In en, this message translates to:
  /// **'Mini Market'**
  String get businessMiniMarket;

  /// No description provided for @businessSupermarket.
  ///
  /// In en, this message translates to:
  /// **'Supermarket'**
  String get businessSupermarket;

  /// No description provided for @businessPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get businessPharmacy;

  /// No description provided for @businessRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get businessRestaurant;

  /// No description provided for @businessCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get businessCafe;

  /// No description provided for @businessRetailShop.
  ///
  /// In en, this message translates to:
  /// **'Retail Shop'**
  String get businessRetailShop;

  /// No description provided for @businessBuildingMaterials.
  ///
  /// In en, this message translates to:
  /// **'Building Materials'**
  String get businessBuildingMaterials;

  /// No description provided for @businessElectricalSupplies.
  ///
  /// In en, this message translates to:
  /// **'Electrical Supplies'**
  String get businessElectricalSupplies;

  /// No description provided for @businessPlumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get businessPlumbing;

  /// No description provided for @businessToolsHardware.
  ///
  /// In en, this message translates to:
  /// **'Tools & Hardware'**
  String get businessToolsHardware;

  /// No description provided for @businessIndustrialEquipment.
  ///
  /// In en, this message translates to:
  /// **'Industrial Equipment'**
  String get businessIndustrialEquipment;

  /// No description provided for @businessHomeImprovement.
  ///
  /// In en, this message translates to:
  /// **'Home Improvement'**
  String get businessHomeImprovement;

  /// No description provided for @businessWholesaleDistribution.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Distribution'**
  String get businessWholesaleDistribution;

  /// No description provided for @businessOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get businessOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

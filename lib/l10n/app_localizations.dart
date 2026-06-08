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

  /// No description provided for @supplierLogo.
  ///
  /// In en, this message translates to:
  /// **'Supplier Logo'**
  String get supplierLogo;

  /// No description provided for @uploadSupplierLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload supplier logo'**
  String get uploadSupplierLogo;

  /// No description provided for @tapToUploadLogoImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose JPG, PNG, or WEBP image'**
  String get tapToUploadLogoImage;

  /// No description provided for @changeLogo.
  ///
  /// In en, this message translates to:
  /// **'Change logo'**
  String get changeLogo;

  /// No description provided for @removeLogo.
  ///
  /// In en, this message translates to:
  /// **'Remove logo'**
  String get removeLogo;

  /// No description provided for @supplierLogoRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please upload your supplier logo'**
  String get supplierLogoRequiredError;

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

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @featuredProducts.
  ///
  /// In en, this message translates to:
  /// **'Featured Products'**
  String get featuredProducts;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @topRanking.
  ///
  /// In en, this message translates to:
  /// **'Top Ranking'**
  String get topRanking;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @rfq.
  ///
  /// In en, this message translates to:
  /// **'RFQ'**
  String get rfq;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @couldNotLoadRetailerHome.
  ///
  /// In en, this message translates to:
  /// **'Could not load retailer home'**
  String get couldNotLoadRetailerHome;

  /// No description provided for @checkConnectionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get checkConnectionTryAgain;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Cart page will be available soon'**
  String get cartComingSoon;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications page will be available soon'**
  String get notificationsComingSoon;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @promotionsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Promotions will be available soon'**
  String get promotionsComingSoon;

  /// No description provided for @topRankingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Top ranking products will appear here soon'**
  String get topRankingComingSoon;

  /// No description provided for @ordersComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here soon'**
  String get ordersComingSoon;

  /// No description provided for @rfqComingSoon.
  ///
  /// In en, this message translates to:
  /// **'RFQ requests will appear here soon'**
  String get rfqComingSoon;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @aiAssistantComingSoon.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant will be available soon'**
  String get aiAssistantComingSoon;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @liveChatComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Live Chat will be available soon'**
  String get liveChatComingSoon;

  /// No description provided for @loyaltyPoints.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Points'**
  String get loyaltyPoints;

  /// No description provided for @loyaltyComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Loyalty points will be available soon'**
  String get loyaltyComingSoon;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get basicInformation;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get logoutQuestion;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @businessInformation.
  ///
  /// In en, this message translates to:
  /// **'Business Information'**
  String get businessInformation;

  /// No description provided for @changePasswordOptional.
  ///
  /// In en, this message translates to:
  /// **'Change Password (optional)'**
  String get changePasswordOptional;

  /// No description provided for @passwordManagedByBuild4All.
  ///
  /// In en, this message translates to:
  /// **'Password change requires Build4All verification flow and will be added next.'**
  String get passwordManagedByBuild4All;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneLebanon.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Lebanon)'**
  String get phoneLebanon;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @creditBalance.
  ///
  /// In en, this message translates to:
  /// **'Credit Balance'**
  String get creditBalance;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @languageSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Language settings will be available soon'**
  String get languageSettingsComingSoon;

  /// No description provided for @walletComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Wallet details will be available soon'**
  String get walletComingSoon;

  /// No description provided for @creditComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Credit details will be available soon'**
  String get creditComingSoon;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get chooseLanguage;

  /// No description provided for @emailVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'A verification code was sent to your new email.'**
  String get emailVerificationRequired;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @emailUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email updated successfully'**
  String get emailUpdatedSuccessfully;

  /// No description provided for @passwordVerificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Password verification code sent'**
  String get passwordVerificationCodeSent;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountWarningTitle;

  /// No description provided for @deleteAccountWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account is permanent. This action cannot be undone.'**
  String get deleteAccountWarningMessage;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This will remove your Build4All account and your retailer profile.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccessfully;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;

  /// No description provided for @shoppingCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get shoppingCart;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get yourCartIsEmpty;

  /// No description provided for @emptyCartMessage.
  ///
  /// In en, this message translates to:
  /// **'Add products from the home page to start your order.'**
  String get emptyCartMessage;

  /// No description provided for @perUnit.
  ///
  /// In en, this message translates to:
  /// **'per unit'**
  String get perUnit;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shippingEstimated.
  ///
  /// In en, this message translates to:
  /// **'Shipping (estimated)'**
  String get shippingEstimated;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @checkoutComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Checkout will be available soon'**
  String get checkoutComingSoon;

  /// No description provided for @createRfq.
  ///
  /// In en, this message translates to:
  /// **'Create RFQ'**
  String get createRfq;

  /// No description provided for @smartRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Smart recommendations'**
  String get smartRecommendations;

  /// No description provided for @requestQuotesQuickly.
  ///
  /// In en, this message translates to:
  /// **'Request quotes quickly'**
  String get requestQuotesQuickly;

  /// No description provided for @trackYourRewards.
  ///
  /// In en, this message translates to:
  /// **'Track your rewards'**
  String get trackYourRewards;

  /// No description provided for @viewAvailableDeals.
  ///
  /// In en, this message translates to:
  /// **'View available deals'**
  String get viewAvailableDeals;

  /// No description provided for @productsLabel.
  ///
  /// In en, this message translates to:
  /// **'products'**
  String get productsLabel;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @moq.
  ///
  /// In en, this message translates to:
  /// **'MOQ'**
  String get moq;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get outOfStock;

  /// No description provided for @noProductsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No products in this category'**
  String get noProductsInCategory;

  /// No description provided for @productAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Product added to cart'**
  String get productAddedToCart;

  /// No description provided for @supplierDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Supplier Dashboard'**
  String get supplierDashboardTitle;

  /// No description provided for @supplierDashboardMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get supplierDashboardMenuTooltip;

  /// No description provided for @supplierDashboardRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get supplierDashboardRefreshTooltip;

  /// No description provided for @supplierDashboardSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get supplierDashboardSettingsTooltip;

  /// No description provided for @supplierDashboardLowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get supplierDashboardLowStockAlerts;

  /// No description provided for @supplierDashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get supplierDashboardQuickActions;

  /// No description provided for @supplierDashboardOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here’s an overview of your business'**
  String get supplierDashboardOverviewSubtitle;

  /// No description provided for @supplierPendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get supplierPendingOrders;

  /// No description provided for @supplierActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get supplierActiveOrders;

  /// No description provided for @supplierShippedOrders.
  ///
  /// In en, this message translates to:
  /// **'Shipped Orders'**
  String get supplierShippedOrders;

  /// No description provided for @supplierCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'Completed Orders'**
  String get supplierCompletedOrders;

  /// No description provided for @supplierFinancialSummary.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get supplierFinancialSummary;

  /// No description provided for @supplierTodaySales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get supplierTodaySales;

  /// No description provided for @supplierMonthlyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Monthly Revenue'**
  String get supplierMonthlyRevenue;

  /// No description provided for @supplierOrdersToday.
  ///
  /// In en, this message translates to:
  /// **'Orders Today'**
  String get supplierOrdersToday;

  /// No description provided for @supplierNoLowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'No low stock alerts'**
  String get supplierNoLowStockAlerts;

  /// No description provided for @supplierAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get supplierAddProduct;

  /// No description provided for @supplierCreatePromotion.
  ///
  /// In en, this message translates to:
  /// **'Create Promotion'**
  String get supplierCreatePromotion;

  /// No description provided for @supplierManageBranches.
  ///
  /// In en, this message translates to:
  /// **'Manage Branches'**
  String get supplierManageBranches;

  /// No description provided for @supplierShippingMethods.
  ///
  /// In en, this message translates to:
  /// **'Shipping Methods'**
  String get supplierShippingMethods;

  /// No description provided for @supplierConfigureTaxes.
  ///
  /// In en, this message translates to:
  /// **'Configure Taxes'**
  String get supplierConfigureTaxes;

  /// No description provided for @supplierImportExcel.
  ///
  /// In en, this message translates to:
  /// **'Import Excel'**
  String get supplierImportExcel;

  /// No description provided for @supplierHomeBanners.
  ///
  /// In en, this message translates to:
  /// **'Home Banners'**
  String get supplierHomeBanners;

  /// No description provided for @supplierCoupons.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get supplierCoupons;

  /// No description provided for @supplierLoadingDashboardData.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard data...'**
  String get supplierLoadingDashboardData;

  /// No description provided for @supplierLowStockItem.
  ///
  /// In en, this message translates to:
  /// **'Low stock item'**
  String get supplierLowStockItem;

  /// No description provided for @supplierLowStockProduct.
  ///
  /// In en, this message translates to:
  /// **'Low stock product'**
  String get supplierLowStockProduct;

  /// No description provided for @supplierCurrentMinimumStock.
  ///
  /// In en, this message translates to:
  /// **'Current stock: {currentStock} | Minimum: {minimumStock}'**
  String supplierCurrentMinimumStock(Object currentStock, Object minimumStock);

  /// No description provided for @supplierLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get supplierLogoutTitle;

  /// No description provided for @supplierLogoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get supplierLogoutConfirmation;

  /// No description provided for @supplierDrawerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get supplierDrawerDashboard;

  /// No description provided for @supplierDrawerProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get supplierDrawerProfile;

  /// No description provided for @supplierDrawerProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get supplierDrawerProducts;

  /// No description provided for @supplierDrawerCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get supplierDrawerCatalog;

  /// No description provided for @supplierDrawerBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get supplierDrawerBranches;

  /// No description provided for @supplierDrawerOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get supplierDrawerOrders;

  /// No description provided for @supplierDrawerPromotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get supplierDrawerPromotions;

  /// No description provided for @supplierDrawerCoupons.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get supplierDrawerCoupons;

  /// No description provided for @supplierDrawerHomeBanners.
  ///
  /// In en, this message translates to:
  /// **'Home Banners'**
  String get supplierDrawerHomeBanners;

  /// No description provided for @supplierDrawerShippingMethods.
  ///
  /// In en, this message translates to:
  /// **'Shipping Methods'**
  String get supplierDrawerShippingMethods;

  /// No description provided for @supplierDrawerTaxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get supplierDrawerTaxes;

  /// No description provided for @supplierDrawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get supplierDrawerSettings;

  /// No description provided for @supplierProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Supplier Profile'**
  String get supplierProfileTitle;

  /// No description provided for @supplierProfileRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get supplierProfileRefreshTooltip;

  /// No description provided for @supplierProfileNoData.
  ///
  /// In en, this message translates to:
  /// **'No supplier profile data found'**
  String get supplierProfileNoData;

  /// No description provided for @supplierProfileInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get supplierProfileInformation;

  /// No description provided for @supplierFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get supplierFullNameLabel;

  /// No description provided for @supplierUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get supplierUsernameLabel;

  /// No description provided for @supplierEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get supplierEmailLabel;

  /// No description provided for @supplierPhoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get supplierPhoneNumberLabel;

  /// No description provided for @supplierAccountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get supplierAccountTypeLabel;

  /// No description provided for @supplierOwnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get supplierOwnerLabel;

  /// No description provided for @supplierUnableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load supplier profile'**
  String get supplierUnableToLoadProfile;

  /// No description provided for @supplierTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get supplierTryAgain;

  /// No description provided for @supplierNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get supplierNotProvided;

  /// No description provided for @branchManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch\nManagement'**
  String get branchManagementTitle;

  /// No description provided for @addBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Branch'**
  String get addBranchTitle;

  /// No description provided for @editBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Branch'**
  String get editBranchTitle;

  /// No description provided for @updateBranchButton.
  ///
  /// In en, this message translates to:
  /// **'Update Branch'**
  String get updateBranchButton;

  /// No description provided for @saveBranchButton.
  ///
  /// In en, this message translates to:
  /// **'Save Branch'**
  String get saveBranchButton;

  /// No description provided for @branchInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch Information'**
  String get branchInformationTitle;

  /// No description provided for @branchInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a supplier branch or warehouse used later for inventory and stock allocation.'**
  String get branchInformationSubtitle;

  /// No description provided for @branchNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch Name *'**
  String get branchNameLabel;

  /// No description provided for @branchNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Main Warehouse'**
  String get branchNameHint;

  /// No description provided for @branchNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Branch name is required'**
  String get branchNameRequiredError;

  /// No description provided for @branchNameMinError.
  ///
  /// In en, this message translates to:
  /// **'Branch name must be at least 3 characters'**
  String get branchNameMinError;

  /// No description provided for @branchNameTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Branch name is too long'**
  String get branchNameTooLongError;

  /// No description provided for @cityAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'City / Area'**
  String get cityAreaLabel;

  /// No description provided for @cityAreaRequiredError.
  ///
  /// In en, this message translates to:
  /// **'City / Area is required'**
  String get cityAreaRequiredError;

  /// No description provided for @cityAreaMinError.
  ///
  /// In en, this message translates to:
  /// **'City / Area must be at least 2 characters'**
  String get cityAreaMinError;

  /// No description provided for @cityAreaTooLongError.
  ///
  /// In en, this message translates to:
  /// **'City / Area is too long'**
  String get cityAreaTooLongError;

  /// No description provided for @fullAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Address *'**
  String get fullAddressLabel;

  /// No description provided for @fullAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Building, street, industrial area'**
  String get fullAddressHint;

  /// No description provided for @addressRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequiredError;

  /// No description provided for @addressSpecificError.
  ///
  /// In en, this message translates to:
  /// **'Address must be more specific'**
  String get addressSpecificError;

  /// No description provided for @addressTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Address is too long'**
  String get addressTooLongError;

  /// No description provided for @branchCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country *'**
  String get branchCountryLabel;

  /// No description provided for @loadingCountries.
  ///
  /// In en, this message translates to:
  /// **'Loading countries...'**
  String get loadingCountries;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountry;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country...'**
  String get searchCountry;

  /// No description provided for @noCountriesFound.
  ///
  /// In en, this message translates to:
  /// **'No countries found'**
  String get noCountriesFound;

  /// No description provided for @countryRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get countryRequiredError;

  /// No description provided for @branchRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region / State'**
  String get branchRegionLabel;

  /// No description provided for @selectCountryFirst.
  ///
  /// In en, this message translates to:
  /// **'Select country first'**
  String get selectCountryFirst;

  /// No description provided for @loadingRegions.
  ///
  /// In en, this message translates to:
  /// **'Loading regions...'**
  String get loadingRegions;

  /// No description provided for @noPredefinedRegions.
  ///
  /// In en, this message translates to:
  /// **'No predefined regions, continue with city/area'**
  String get noPredefinedRegions;

  /// No description provided for @selectRegionState.
  ///
  /// In en, this message translates to:
  /// **'Select region / state'**
  String get selectRegionState;

  /// No description provided for @searchRegionState.
  ///
  /// In en, this message translates to:
  /// **'Search region / state...'**
  String get searchRegionState;

  /// No description provided for @noRegionsFound.
  ///
  /// In en, this message translates to:
  /// **'No regions found'**
  String get noRegionsFound;

  /// No description provided for @branchPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number *'**
  String get branchPhoneLabel;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @branchStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch Status *'**
  String get branchStatusLabel;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @inactiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveStatus;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select status'**
  String get selectStatus;

  /// No description provided for @pleaseSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Please select a country.'**
  String get pleaseSelectCountry;

  /// No description provided for @phoneRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequiredError;

  /// No description provided for @phoneSelectCountryFirstError.
  ///
  /// In en, this message translates to:
  /// **'Please select a country first'**
  String get phoneSelectCountryFirstError;

  /// No description provided for @phoneCountryMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Phone country must match the selected country'**
  String get phoneCountryMismatchError;

  /// No description provided for @lebanesePhoneDigitsError.
  ///
  /// In en, this message translates to:
  /// **'Lebanese phone numbers must contain 8 digits after +961'**
  String get lebanesePhoneDigitsError;

  /// No description provided for @validPhoneForSelectedCountryError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number with country code'**
  String get validPhoneForSelectedCountryError;

  /// No description provided for @deleteBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Branch'**
  String get deleteBranchTitle;

  /// No description provided for @deleteBranchConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {branchName}?'**
  String deleteBranchConfirmation(Object branchName);

  /// No description provided for @searchBranchesHint.
  ///
  /// In en, this message translates to:
  /// **'Search branches...'**
  String get searchBranchesHint;

  /// No description provided for @noBranchesFound.
  ///
  /// In en, this message translates to:
  /// **'No branches found'**
  String get noBranchesFound;

  /// No description provided for @addBranchesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add branches to manage stock and inventory by location.'**
  String get addBranchesEmptyMessage;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @totalProductsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalProductsLabel;

  /// No description provided for @totalStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Stock'**
  String get totalStockLabel;

  /// No description provided for @viewInventoryButton.
  ///
  /// In en, this message translates to:
  /// **'View Inventory'**
  String get viewInventoryButton;

  /// No description provided for @branchInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'{branchName} Inventory'**
  String branchInventoryTitle(Object branchName);

  /// No description provided for @allProductsAssigned.
  ///
  /// In en, this message translates to:
  /// **'All available products are already assigned to this branch'**
  String get allProductsAssigned;

  /// No description provided for @assignProductToBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Product to Branch'**
  String get assignProductToBranchTitle;

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productLabel;

  /// No description provided for @stockQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get stockQuantityLabel;

  /// No description provided for @stockQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 100'**
  String get stockQuantityHint;

  /// No description provided for @inventoryRecordNote.
  ///
  /// In en, this message translates to:
  /// **'This creates an inventory record for this branch and product.'**
  String get inventoryRecordNote;

  /// No description provided for @assignButton.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assignButton;

  /// No description provided for @updateStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Stock'**
  String get updateStockTitle;

  /// No description provided for @stockQuantityFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock quantity'**
  String get stockQuantityFieldLabel;

  /// No description provided for @stockQuantityUpdateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 500'**
  String get stockQuantityUpdateHint;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @removeProductFromBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Product from Branch'**
  String get removeProductFromBranchTitle;

  /// No description provided for @removeProductFromBranchConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {productName} from {branchName} inventory?'**
  String removeProductFromBranchConfirmation(
    Object productName,
    Object branchName,
  );

  /// No description provided for @removeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButton;

  /// No description provided for @noInventoryFound.
  ///
  /// In en, this message translates to:
  /// **'No inventory found'**
  String get noInventoryFound;

  /// No description provided for @assignProductsToBranchEmpty.
  ///
  /// In en, this message translates to:
  /// **'Assign products to this branch to start tracking stock.'**
  String get assignProductsToBranchEmpty;

  /// No description provided for @assignProductButton.
  ///
  /// In en, this message translates to:
  /// **'Assign Product'**
  String get assignProductButton;

  /// No description provided for @stockWithQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock: {quantity}'**
  String stockWithQuantity(Object quantity);

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog Management'**
  String get catalogTitle;

  /// No description provided for @searchCatalogHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories or subcategories...'**
  String get searchCatalogHint;

  /// No description provided for @noCatalogItems.
  ///
  /// In en, this message translates to:
  /// **'No catalog items found'**
  String get noCatalogItems;

  /// No description provided for @addCatalogFirst.
  ///
  /// In en, this message translates to:
  /// **'Add categories and subcategories to organize supplier products.'**
  String get addCatalogFirst;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @subCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'SubCategory'**
  String get subCategoryLabel;

  /// No description provided for @addCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategoryTitle;

  /// No description provided for @editCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategoryTitle;

  /// No description provided for @addSubCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add SubCategory'**
  String get addSubCategoryTitle;

  /// No description provided for @editSubCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit SubCategory'**
  String get editSubCategoryTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryNameLabel;

  /// No description provided for @subCategoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'SubCategory Name'**
  String get subCategoryNameLabel;

  /// No description provided for @parentCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent Category'**
  String get parentCategoryLabel;

  /// No description provided for @categoryRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Category is required'**
  String get categoryRequiredError;

  /// No description provided for @subCategoryRequiredError.
  ///
  /// In en, this message translates to:
  /// **'SubCategory is required'**
  String get subCategoryRequiredError;

  /// No description provided for @activateButton.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateButton;

  /// No description provided for @deactivateButton.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivateButton;

  /// No description provided for @productManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Product\nManagement'**
  String get productManagementTitle;

  /// No description provided for @searchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProductsHint;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @addProductsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add products to start building your supplier catalog.'**
  String get addProductsEmptyMessage;

  /// No description provided for @productNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productNameLabel;

  /// No description provided for @productNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get productNameRequiredError;

  /// No description provided for @productNameMinError.
  ///
  /// In en, this message translates to:
  /// **'Product name must be at least 3 characters'**
  String get productNameMinError;

  /// No description provided for @productNameTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Product name is too long'**
  String get productNameTooLongError;

  /// No description provided for @productDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescriptionLabel;

  /// No description provided for @productDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Product details, packaging, notes...'**
  String get productDescriptionHint;

  /// No description provided for @productPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productPriceLabel;

  /// No description provided for @productPriceRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get productPriceRequiredError;

  /// No description provided for @productPriceInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get productPriceInvalidError;

  /// No description provided for @minimumOrderQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Quantity'**
  String get minimumOrderQuantityLabel;

  /// No description provided for @minimumOrderQuantityRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Minimum order quantity is required'**
  String get minimumOrderQuantityRequiredError;

  /// No description provided for @minimumOrderQuantityInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid minimum order quantity'**
  String get minimumOrderQuantityInvalidError;

  /// No description provided for @productStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Status'**
  String get productStatusLabel;

  /// No description provided for @productImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get productImageLabel;

  /// No description provided for @uploadImageButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImageButton;

  /// No description provided for @changeImageButton.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImageButton;

  /// No description provided for @categoryDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryDropdownLabel;

  /// No description provided for @subCategoryDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'SubCategory'**
  String get subCategoryDropdownLabel;

  /// No description provided for @selectCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategoryHint;

  /// No description provided for @selectSubCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select subcategory'**
  String get selectSubCategoryHint;

  /// No description provided for @addProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductTitle;

  /// No description provided for @editProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProductTitle;

  /// No description provided for @saveProductButton.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get saveProductButton;

  /// No description provided for @updateProductButton.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProductButton;

  /// No description provided for @deleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProductTitle;

  /// No description provided for @deleteProductConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {productName}?'**
  String deleteProductConfirmation(Object productName);

  /// No description provided for @manageStockButton.
  ///
  /// In en, this message translates to:
  /// **'Manage Stock'**
  String get manageStockButton;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @moqLabel.
  ///
  /// In en, this message translates to:
  /// **'MOQ'**
  String get moqLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @productBranchStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Product Branch Stock'**
  String get productBranchStockTitle;

  /// No description provided for @branchStockCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch Stock'**
  String get branchStockCardsTitle;

  /// No description provided for @totalStockForProduct.
  ///
  /// In en, this message translates to:
  /// **'Total stock: {quantity}'**
  String totalStockForProduct(Object quantity);

  /// No description provided for @noBranchStockFound.
  ///
  /// In en, this message translates to:
  /// **'No branch stock found'**
  String get noBranchStockFound;

  /// No description provided for @assignStockToBranch.
  ///
  /// In en, this message translates to:
  /// **'Assign stock to a branch to start selling this product.'**
  String get assignStockToBranch;

  /// No description provided for @removeStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Stock'**
  String get removeStockTitle;

  /// No description provided for @removeStockConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove stock for {branchName}?'**
  String removeStockConfirmation(Object branchName);

  /// No description provided for @supplierOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders Management'**
  String get supplierOrdersTitle;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailsTitle;

  /// No description provided for @searchOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'Search orders...'**
  String get searchOrdersHint;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @orderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId}'**
  String orderNumberLabel(Object orderId);

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @retailerLabel.
  ///
  /// In en, this message translates to:
  /// **'Retailer'**
  String get retailerLabel;

  /// No description provided for @orderItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItemsLabel;

  /// No description provided for @orderTimelineLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Timeline'**
  String get orderTimelineLabel;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get orderStatusAccepted;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @acceptOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get acceptOrderButton;

  /// No description provided for @markPreparingButton.
  ///
  /// In en, this message translates to:
  /// **'Mark Preparing'**
  String get markPreparingButton;

  /// No description provided for @shipOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Ship Order'**
  String get shipOrderButton;

  /// No description provided for @markDeliveredButton.
  ///
  /// In en, this message translates to:
  /// **'Mark Delivered'**
  String get markDeliveredButton;

  /// No description provided for @cancelOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrderButton;

  /// No description provided for @orderTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get orderTotalLabel;

  /// No description provided for @orderDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDateLabel;

  /// No description provided for @deliveryAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddressLabel;

  /// No description provided for @paymentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatusLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @importExcelTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Excel'**
  String get importExcelTitle;

  /// No description provided for @uploadExcelFile.
  ///
  /// In en, this message translates to:
  /// **'Upload Excel File'**
  String get uploadExcelFile;

  /// No description provided for @acceptedExcelFormat.
  ///
  /// In en, this message translates to:
  /// **'Accepted format: .xlsx'**
  String get acceptedExcelFormat;

  /// No description provided for @readingFile.
  ///
  /// In en, this message translates to:
  /// **'Reading file...'**
  String get readingFile;

  /// No description provided for @selectExcel.
  ///
  /// In en, this message translates to:
  /// **'Select Excel'**
  String get selectExcel;

  /// No description provided for @clearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// No description provided for @expectedColumnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Expected Columns'**
  String get expectedColumnsTitle;

  /// No description provided for @importProductInfoOnly.
  ///
  /// In en, this message translates to:
  /// **'Import product information only'**
  String get importProductInfoOnly;

  /// No description provided for @excelImportExplanation.
  ///
  /// In en, this message translates to:
  /// **'This import creates supplier products in bulk. Branch stock is not imported here because stock belongs to Branch Inventory.'**
  String get excelImportExplanation;

  /// No description provided for @excelCreateCategoriesFirst.
  ///
  /// In en, this message translates to:
  /// **'Create categories and subcategories first, then upload the Excel file so rows can be matched safely.'**
  String get excelCreateCategoriesFirst;

  /// No description provided for @noRowsToPreview.
  ///
  /// In en, this message translates to:
  /// **'No rows to preview yet'**
  String get noRowsToPreview;

  /// No description provided for @selectExcelToPreview.
  ///
  /// In en, this message translates to:
  /// **'Select an Excel file to preview and validate products.'**
  String get selectExcelToPreview;

  /// No description provided for @previewRowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview Rows'**
  String get previewRowsTitle;

  /// No description provided for @previewRowsHelp.
  ///
  /// In en, this message translates to:
  /// **'Review invalid rows, edit them directly here, or update the Excel file and upload it again.'**
  String get previewRowsHelp;

  /// No description provided for @unnamedProduct.
  ///
  /// In en, this message translates to:
  /// **'Unnamed product'**
  String get unnamedProduct;

  /// No description provided for @editRowButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Row'**
  String get editRowButton;

  /// No description provided for @rowsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get rowsLabel;

  /// No description provided for @validLabel.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get validLabel;

  /// No description provided for @errorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get errorsLabel;

  /// No description provided for @warningsLabel.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get warningsLabel;

  /// No description provided for @duplicateProductWarning.
  ///
  /// In en, this message translates to:
  /// **'Duplicate product warning'**
  String get duplicateProductWarning;

  /// No description provided for @supplierComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'This supplier module will be implemented step by step.'**
  String get supplierComingSoonMessage;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @menuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTooltip;

  /// No description provided for @categoriesTab.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTab;

  /// No description provided for @subCategoriesTab.
  ///
  /// In en, this message translates to:
  /// **'Sub Categories'**
  String get subCategoriesTab;

  /// No description provided for @categoryNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNameFieldLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Clothing'**
  String get categoryNameHint;

  /// No description provided for @subCategoryNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Sub category name'**
  String get subCategoryNameFieldLabel;

  /// No description provided for @subCategoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Women Clothing'**
  String get subCategoryNameHint;

  /// No description provided for @createActiveCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Create an active category first'**
  String get createActiveCategoryFirst;

  /// No description provided for @deactivateCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Category'**
  String get deactivateCategoryTitle;

  /// No description provided for @activateCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate Category'**
  String get activateCategoryTitle;

  /// No description provided for @deactivateCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'This category will no longer appear when adding new products. Existing products will not be affected.'**
  String get deactivateCategoryMessage;

  /// No description provided for @activateCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'This category will appear again when adding new products.'**
  String get activateCategoryMessage;

  /// No description provided for @deactivateSubCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Sub Category'**
  String get deactivateSubCategoryTitle;

  /// No description provided for @activateSubCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate Sub Category'**
  String get activateSubCategoryTitle;

  /// No description provided for @deactivateSubCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'This sub category will no longer appear when adding new products. Existing products will not be affected.'**
  String get deactivateSubCategoryMessage;

  /// No description provided for @activateSubCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'This sub category will appear again when adding new products.'**
  String get activateSubCategoryMessage;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteSubCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Sub Category'**
  String get deleteSubCategoryTitle;

  /// No description provided for @deleteCategoryPermanentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{categoryName}\" permanently? This is allowed only if it is not linked to products or sub categories.'**
  String deleteCategoryPermanentConfirmation(Object categoryName);

  /// No description provided for @deleteSubCategoryPermanentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{subCategoryName}\" permanently? This is allowed only if it is not linked to products.'**
  String deleteSubCategoryPermanentConfirmation(Object subCategoryName);

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @noSubCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No sub categories found'**
  String get noSubCategoriesFound;

  /// No description provided for @searchCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get searchCategoriesHint;

  /// No description provided for @searchSubCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Search sub categories...'**
  String get searchSubCategoriesHint;

  /// No description provided for @categoryStats.
  ///
  /// In en, this message translates to:
  /// **'{productCount} products â€¢ {subCategoryCount} sub categories'**
  String categoryStats(Object productCount, Object subCategoryCount);

  /// No description provided for @subCategoryStats.
  ///
  /// In en, this message translates to:
  /// **'{categoryName} â€¢ {productCount} products'**
  String subCategoryStats(Object categoryName, Object productCount);

  /// No description provided for @linkedLabel.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linkedLabel;

  /// No description provided for @productInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Information'**
  String get productInformationTitle;

  /// No description provided for @productDescriptionRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get productDescriptionRequiredError;

  /// No description provided for @productDescriptionMinError.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 10 characters'**
  String get productDescriptionMinError;

  /// No description provided for @productDescriptionTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Description is too long'**
  String get productDescriptionTooLongError;

  /// No description provided for @pricePerUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per Unit *'**
  String get pricePerUnitLabel;

  /// No description provided for @priceGreaterThanZeroError.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than 0'**
  String get priceGreaterThanZeroError;

  /// No description provided for @priceTooHighError.
  ///
  /// In en, this message translates to:
  /// **'Price is too high'**
  String get priceTooHighError;

  /// No description provided for @quantityInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity'**
  String get quantityInvalidError;

  /// No description provided for @moqWholesaleMinError.
  ///
  /// In en, this message translates to:
  /// **'Minimum order quantity must be at least 5 for wholesale'**
  String get moqWholesaleMinError;

  /// No description provided for @moqTooHighError.
  ///
  /// In en, this message translates to:
  /// **'Minimum order quantity is too high'**
  String get moqTooHighError;

  /// No description provided for @productBranchStockSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Branch Stock'**
  String get productBranchStockSectionTitle;

  /// No description provided for @manageProductStockSavedNote.
  ///
  /// In en, this message translates to:
  /// **'Manage this product stock across all branches directly. Stock updates are saved immediately in Branch Inventory.'**
  String get manageProductStockSavedNote;

  /// No description provided for @manageProductStockAfterSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Save this product first, then assign its stock per branch from Product Branch Stock.'**
  String get manageProductStockAfterSaveNote;

  /// No description provided for @branchStockAfterSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Branch stock becomes available after saving the product.'**
  String get branchStockAfterSaveNote;

  /// No description provided for @addingLabel.
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get addingLabel;

  /// No description provided for @deletingLabel.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deletingLabel;

  /// No description provided for @deleteSelectedCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected Category'**
  String get deleteSelectedCategory;

  /// No description provided for @deleteSelectedSubCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected Sub Category'**
  String get deleteSelectedSubCategory;

  /// No description provided for @loadingSubCategories.
  ///
  /// In en, this message translates to:
  /// **'Loading sub categories...'**
  String get loadingSubCategories;

  /// No description provided for @selectSubCategoryIfNeeded.
  ///
  /// In en, this message translates to:
  /// **'Select sub category if needed'**
  String get selectSubCategoryIfNeeded;

  /// No description provided for @selectProductStatus.
  ///
  /// In en, this message translates to:
  /// **'Select product status'**
  String get selectProductStatus;

  /// No description provided for @uploadImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Images'**
  String get uploadImagesTitle;

  /// No description provided for @tapToUploadProductImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload product image'**
  String get tapToUploadProductImage;

  /// No description provided for @imageFormatHint.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPG up to 10MB'**
  String get imageFormatHint;

  /// No description provided for @selectCategoryFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a category first'**
  String get selectCategoryFirstMessage;

  /// No description provided for @selectedCategoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Selected category was not found'**
  String get selectedCategoryNotFound;

  /// No description provided for @selectedSubCategoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Selected sub category was not found'**
  String get selectedSubCategoryNotFound;

  /// No description provided for @selectSubCategoryFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a sub category first'**
  String get selectSubCategoryFirstMessage;

  /// No description provided for @categoryAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'{categoryName} added'**
  String categoryAddedMessage(Object categoryName);

  /// No description provided for @subCategoryAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'{subCategoryName} added'**
  String subCategoryAddedMessage(Object subCategoryName);

  /// No description provided for @categoryDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'{categoryName} deleted'**
  String categoryDeletedMessage(Object categoryName);

  /// No description provided for @subCategoryDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'{subCategoryName} deleted'**
  String subCategoryDeletedMessage(Object subCategoryName);

  /// No description provided for @deleteCategoryHelp.
  ///
  /// In en, this message translates to:
  /// **'If this category is already used by products or subcategories, the backend may prevent deleting it.'**
  String get deleteCategoryHelp;

  /// No description provided for @deleteSubCategoryHelp.
  ///
  /// In en, this message translates to:
  /// **'If this sub category is already used by products, the backend may prevent deleting it.'**
  String get deleteSubCategoryHelp;

  /// No description provided for @updateBranchStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Branch Stock'**
  String get updateBranchStockTitle;

  /// No description provided for @assignStockToBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Stock to Branch'**
  String get assignStockToBranchTitle;

  /// No description provided for @branchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branchLabel;

  /// No description provided for @stockSavedToBranchInventoryNote.
  ///
  /// In en, this message translates to:
  /// **'Stock is saved directly in Branch Inventory. You do not need to update the product details again.'**
  String get stockSavedToBranchInventoryNote;

  /// No description provided for @stockByBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock by Branch'**
  String get stockByBranchTitle;

  /// No description provided for @productBranchStockExplanation.
  ///
  /// In en, this message translates to:
  /// **'Update this product stock directly per branch. This saves to Branch Inventory, not Product details.'**
  String get productBranchStockExplanation;

  /// No description provided for @branchesLabel.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branchesLabel;

  /// No description provided for @notAssignedYet.
  ///
  /// In en, this message translates to:
  /// **'Not assigned yet'**
  String get notAssignedYet;

  /// No description provided for @createBranchFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a branch first, then assign product stock.'**
  String get createBranchFirst;

  /// No description provided for @totalBranchStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Branch Stock: {quantity}'**
  String totalBranchStockLabel(Object quantity);

  /// No description provided for @noBranchStockAssigned.
  ///
  /// In en, this message translates to:
  /// **'No branch stock assigned'**
  String get noBranchStockAssigned;

  /// No description provided for @viewDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetailsButton;

  /// No description provided for @itemsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCountLabel(Object count);

  /// No description provided for @allLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// No description provided for @incomingOrdersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Incoming retailer orders will appear here.'**
  String get incomingOrdersEmptyMessage;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodLabel;

  /// No description provided for @totalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmountLabel;

  /// No description provided for @orderCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled.'**
  String get orderCancelledMessage;

  /// No description provided for @productsOrderedTitle.
  ///
  /// In en, this message translates to:
  /// **'Products Ordered'**
  String get productsOrderedTitle;

  /// No description provided for @unitsTimesPrice.
  ///
  /// In en, this message translates to:
  /// **'{quantity} units Ã— {price}'**
  String unitsTimesPrice(Object quantity, Object price);

  /// No description provided for @deliveryInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Information'**
  String get deliveryInformationTitle;

  /// No description provided for @retailerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Retailer Phone'**
  String get retailerPhoneLabel;

  /// No description provided for @branchLabelPlain.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branchLabelPlain;

  /// No description provided for @orderNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Notes'**
  String get orderNotesTitle;

  /// No description provided for @noMoreStatusActions.
  ///
  /// In en, this message translates to:
  /// **'No more status actions available for this order.'**
  String get noMoreStatusActions;

  /// No description provided for @rejectOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Reject Order'**
  String get rejectOrderButton;

  /// No description provided for @manageCategoriesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategoriesTooltip;

  /// No description provided for @someRowsNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'Some rows need attention'**
  String get someRowsNeedAttention;

  /// No description provided for @allRowsReady.
  ///
  /// In en, this message translates to:
  /// **'All rows are ready to import'**
  String get allRowsReady;

  /// No description provided for @excelAttentionHelp.
  ///
  /// In en, this message translates to:
  /// **'You can edit invalid rows inside this screen, fix the Excel file and upload it again, or manage missing categories first.'**
  String get excelAttentionHelp;

  /// No description provided for @manageCategoriesButton.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategoriesButton;

  /// No description provided for @importResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Result'**
  String get importResultTitle;

  /// No description provided for @importedRowsSummary.
  ///
  /// In en, this message translates to:
  /// **'Imported: {importedCount} / {totalRows}'**
  String importedRowsSummary(Object importedCount, Object totalRows);

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @importingLabel.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importingLabel;

  /// No description provided for @importProductsButton.
  ///
  /// In en, this message translates to:
  /// **'Import {count} Products'**
  String importProductsButton(Object count);

  /// No description provided for @editRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Row {rowNumber}'**
  String editRowTitle(Object rowNumber);

  /// No description provided for @editRowHelp.
  ///
  /// In en, this message translates to:
  /// **'Correct the product information before importing. This updates the preview only; it does not change the Excel file on your phone.'**
  String get editRowHelp;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @noSubcategory.
  ///
  /// In en, this message translates to:
  /// **'No subcategory'**
  String get noSubcategory;

  /// No description provided for @noSubcategoriesForCategory.
  ///
  /// In en, this message translates to:
  /// **'No subcategories for this category'**
  String get noSubcategoriesForCategory;

  /// No description provided for @selectCategoryWithCurrent.
  ///
  /// In en, this message translates to:
  /// **'Select category ({categoryName})'**
  String selectCategoryWithCurrent(Object categoryName);

  /// No description provided for @rowNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}'**
  String rowNumberLabel(Object rowNumber);

  /// No description provided for @productNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Coca-Cola 24-Pack, Cotton T-Shirt Box'**
  String get productNameHint;

  /// No description provided for @countryRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Country *'**
  String get countryRequiredLabel;

  /// No description provided for @selectCountryFirstError.
  ///
  /// In en, this message translates to:
  /// **'Please select a country first'**
  String get selectCountryFirstError;

  /// No description provided for @regionStateLabel.
  ///
  /// In en, this message translates to:
  /// **'Region / State'**
  String get regionStateLabel;

  /// No description provided for @noPredefinedRegionsContinueWithCity.
  ///
  /// In en, this message translates to:
  /// **'No predefined regions, continue with city/area'**
  String get noPredefinedRegionsContinueWithCity;

  /// No description provided for @noRegionsFoundForSearch.
  ///
  /// In en, this message translates to:
  /// **'No regions found for your search'**
  String get noRegionsFoundForSearch;

  /// No description provided for @cityAreaHintGeneric.
  ///
  /// In en, this message translates to:
  /// **'e.g., city, district, or business area'**
  String get cityAreaHintGeneric;

  /// No description provided for @cityAreaHintLebanonBeirut.
  ///
  /// In en, this message translates to:
  /// **'e.g., Hamra, Achrafieh, Verdun'**
  String get cityAreaHintLebanonBeirut;

  /// No description provided for @cityAreaHintLebanonMount.
  ///
  /// In en, this message translates to:
  /// **'e.g., Baabda, Jounieh, Aley'**
  String get cityAreaHintLebanonMount;

  /// No description provided for @cityAreaHintLebanonNorth.
  ///
  /// In en, this message translates to:
  /// **'e.g., Tripoli, Batroun, Halba'**
  String get cityAreaHintLebanonNorth;

  /// No description provided for @cityAreaHintLebanonSouth.
  ///
  /// In en, this message translates to:
  /// **'e.g., Saida, Tyre, Nabatieh'**
  String get cityAreaHintLebanonSouth;

  /// No description provided for @cityAreaHintLebanonBekaa.
  ///
  /// In en, this message translates to:
  /// **'e.g., Zahle, Baalbek, Chtaura'**
  String get cityAreaHintLebanonBekaa;

  /// No description provided for @cityAreaHintLebanonGeneric.
  ///
  /// In en, this message translates to:
  /// **'e.g., Beirut, Tripoli, Saida'**
  String get cityAreaHintLebanonGeneric;

  /// No description provided for @phoneNumberRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequiredError;

  /// No description provided for @phoneCountryMustMatchSelectedCountry.
  ///
  /// In en, this message translates to:
  /// **'Phone country must match the selected country'**
  String get phoneCountryMustMatchSelectedCountry;

  /// No description provided for @completeRequiredFieldsCorrectly.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields correctly.'**
  String get completeRequiredFieldsCorrectly;

  /// No description provided for @businessTypeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Business type is required'**
  String get businessTypeRequiredError;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @noLabel.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noLabel;

  /// No description provided for @urlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// No description provided for @yesLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesLabel;

  /// No description provided for @copyButton.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyButton;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneLabel;

  /// No description provided for @supplierUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get supplierUsed;

  /// No description provided for @supplierFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get supplierFixed;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @supplierCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get supplierCustom;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @regionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get regionLabel;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @supplierTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get supplierTarget;

  /// No description provided for @supplierBanners.
  ///
  /// In en, this message translates to:
  /// **'Banners'**
  String get supplierBanners;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @supplierPercent.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get supplierPercent;

  /// No description provided for @refreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshButton;

  /// No description provided for @supplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get supplierTitle;

  /// No description provided for @supplierDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get supplierDiscount;

  /// No description provided for @supplierEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get supplierEndDate;

  /// No description provided for @inactiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveLabel;

  /// No description provided for @supplierLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get supplierLocation;

  /// No description provided for @supplierMaxUses.
  ///
  /// In en, this message translates to:
  /// **'Max Uses'**
  String get supplierMaxUses;

  /// No description provided for @regionRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Region *'**
  String get regionRequiredLabel;

  /// No description provided for @supplierSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get supplierSubtitle;

  /// No description provided for @supplierValidTo.
  ///
  /// In en, this message translates to:
  /// **'Valid To'**
  String get supplierValidTo;

  /// No description provided for @supplierValidity.
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get supplierValidity;

  /// No description provided for @supplierMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Min order'**
  String get supplierMinOrder;

  /// No description provided for @noRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'No region'**
  String get noRegionLabel;

  /// No description provided for @supplierRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get supplierRemaining;

  /// No description provided for @supplierUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get supplierUnlimited;

  /// No description provided for @supplierValidNow.
  ///
  /// In en, this message translates to:
  /// **'Valid now'**
  String get supplierValidNow;

  /// No description provided for @supplierPromotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get supplierPromotions;

  /// No description provided for @supplierStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get supplierStartDate;

  /// No description provided for @supplierValidFrom.
  ///
  /// In en, this message translates to:
  /// **'Valid From'**
  String get supplierValidFrom;

  /// No description provided for @supplierBannerList.
  ///
  /// In en, this message translates to:
  /// **'Banner List'**
  String get supplierBannerList;

  /// No description provided for @supplierCouponList.
  ///
  /// In en, this message translates to:
  /// **'Coupon List'**
  String get supplierCouponList;

  /// No description provided for @supplierCreateRule.
  ///
  /// In en, this message translates to:
  /// **'Create Rule'**
  String get supplierCreateRule;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @supplierEditBanner.
  ///
  /// In en, this message translates to:
  /// **'Edit Banner'**
  String get supplierEditBanner;

  /// No description provided for @supplierEditCoupon.
  ///
  /// In en, this message translates to:
  /// **'Edit Coupon'**
  String get supplierEditCoupon;

  /// No description provided for @supplierLebanonVat.
  ///
  /// In en, this message translates to:
  /// **'Lebanon VAT'**
  String get supplierLebanonVat;

  /// No description provided for @supplierPickupOnly.
  ///
  /// In en, this message translates to:
  /// **'Pickup only'**
  String get supplierPickupOnly;

  /// No description provided for @supplierRuleName.
  ///
  /// In en, this message translates to:
  /// **'Rule Name *'**
  String get supplierRuleName;

  /// No description provided for @supplierRulePreset.
  ///
  /// In en, this message translates to:
  /// **'Rule Preset'**
  String get supplierRulePreset;

  /// No description provided for @subcategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategoryLabel;

  /// No description provided for @supplierUpdateRule.
  ///
  /// In en, this message translates to:
  /// **'Update Rule'**
  String get supplierUpdateRule;

  /// No description provided for @supplierValidNow2.
  ///
  /// In en, this message translates to:
  /// **'Valid now: '**
  String get supplierValidNow2;

  /// No description provided for @supplierAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All Branches'**
  String get supplierAllBranches;

  /// No description provided for @supplierAllProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get supplierAllProducts;

  /// No description provided for @supplierAppliesTo.
  ///
  /// In en, this message translates to:
  /// **'Applies To *'**
  String get supplierAppliesTo;

  /// No description provided for @supplierBannerImage.
  ///
  /// In en, this message translates to:
  /// **'Banner Image'**
  String get supplierBannerImage;

  /// No description provided for @supplierCouponRules.
  ///
  /// In en, this message translates to:
  /// **'Coupon Rules'**
  String get supplierCouponRules;

  /// No description provided for @supplierEnabledOnly.
  ///
  /// In en, this message translates to:
  /// **'Enabled only'**
  String get supplierEnabledOnly;

  /// No description provided for @supplierFixedAmount.
  ///
  /// In en, this message translates to:
  /// **'Fixed Amount'**
  String get supplierFixedAmount;

  /// No description provided for @supplierMaxDiscount.
  ///
  /// In en, this message translates to:
  /// **'Max discount'**
  String get supplierMaxDiscount;

  /// No description provided for @supplierSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort Order *'**
  String get supplierSortOrder;

  /// No description provided for @supplierTargetUrl.
  ///
  /// In en, this message translates to:
  /// **'Target URL *'**
  String get supplierTargetUrl;

  /// No description provided for @supplierTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Tax Rate % *'**
  String get supplierTaxRate;

  /// No description provided for @supplierUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get supplierUploadImage;

  /// No description provided for @supplierUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get supplierUploading;

  /// No description provided for @supplierAlwaysActive.
  ///
  /// In en, this message translates to:
  /// **'Always active'**
  String get supplierAlwaysActive;

  /// No description provided for @supplierCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code *'**
  String get supplierCouponCode;

  /// No description provided for @supplierCreateBanner.
  ///
  /// In en, this message translates to:
  /// **'Create Banner'**
  String get supplierCreateBanner;

  /// No description provided for @supplierCreateCoupon.
  ///
  /// In en, this message translates to:
  /// **'Create Coupon'**
  String get supplierCreateCoupon;

  /// No description provided for @supplierCreateMethod.
  ///
  /// In en, this message translates to:
  /// **'Create Method'**
  String get supplierCreateMethod;

  /// No description provided for @supplierDeleteBanner.
  ///
  /// In en, this message translates to:
  /// **'Delete Banner'**
  String get supplierDeleteBanner;

  /// No description provided for @supplierDeleteCoupon.
  ///
  /// In en, this message translates to:
  /// **'Delete Coupon'**
  String get supplierDeleteCoupon;

  /// No description provided for @supplierDisabledOnly.
  ///
  /// In en, this message translates to:
  /// **'Disabled only'**
  String get supplierDisabledOnly;

  /// No description provided for @supplierDisplayRules.
  ///
  /// In en, this message translates to:
  /// **'Display Rules'**
  String get supplierDisplayRules;

  /// No description provided for @supplierEditTaxRule.
  ///
  /// In en, this message translates to:
  /// **'Edit Tax Rule'**
  String get supplierEditTaxRule;

  /// No description provided for @supplierFreeShipping.
  ///
  /// In en, this message translates to:
  /// **'Free Shipping'**
  String get supplierFreeShipping;

  /// No description provided for @supplierMethodName.
  ///
  /// In en, this message translates to:
  /// **'Method Name *'**
  String get supplierMethodName;

  /// No description provided for @supplierMethodType.
  ///
  /// In en, this message translates to:
  /// **'Method Type *'**
  String get supplierMethodType;

  /// No description provided for @searchRegionHint.
  ///
  /// In en, this message translates to:
  /// **'Search region'**
  String get searchRegionHint;

  /// No description provided for @selectRegionHint.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get selectRegionHint;

  /// No description provided for @supplierShippingCost.
  ///
  /// In en, this message translates to:
  /// **'Shipping Cost'**
  String get supplierShippingCost;

  /// No description provided for @supplierTargetType.
  ///
  /// In en, this message translates to:
  /// **'Target Type *'**
  String get supplierTargetType;

  /// No description provided for @supplierTaxRuleList.
  ///
  /// In en, this message translates to:
  /// **'Tax Rule List'**
  String get supplierTaxRuleList;

  /// No description provided for @supplierUpdateBanner.
  ///
  /// In en, this message translates to:
  /// **'Update Banner'**
  String get supplierUpdateBanner;

  /// No description provided for @supplierUpdateCoupon.
  ///
  /// In en, this message translates to:
  /// **'Update Coupon'**
  String get supplierUpdateCoupon;

  /// No description provided for @supplierUpdateMethod.
  ///
  /// In en, this message translates to:
  /// **'Update Method'**
  String get supplierUpdateMethod;

  /// No description provided for @supplierBannerImage2.
  ///
  /// In en, this message translates to:
  /// **'Banner Image *'**
  String get supplierBannerImage2;

  /// No description provided for @supplierEditPromotion.
  ///
  /// In en, this message translates to:
  /// **'Edit Promotion'**
  String get supplierEditPromotion;

  /// No description provided for @supplierManageBanners.
  ///
  /// In en, this message translates to:
  /// **'Manage Banners'**
  String get supplierManageBanners;

  /// No description provided for @supplierManageCoupons.
  ///
  /// In en, this message translates to:
  /// **'Manage Coupons'**
  String get supplierManageCoupons;

  /// No description provided for @supplierNoBannersYet.
  ///
  /// In en, this message translates to:
  /// **'No banners yet'**
  String get supplierNoBannersYet;

  /// No description provided for @supplierNoCouponsYet.
  ///
  /// In en, this message translates to:
  /// **'No coupons yet'**
  String get supplierNoCouponsYet;

  /// No description provided for @supplierPickupIsFree.
  ///
  /// In en, this message translates to:
  /// **'Pickup is free'**
  String get supplierPickupIsFree;

  /// No description provided for @supplierPromotionList.
  ///
  /// In en, this message translates to:
  /// **'Promotion List'**
  String get supplierPromotionList;

  /// No description provided for @searchCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountryHint;

  /// No description provided for @selectCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountryHint;

  /// No description provided for @supplierStatusNotes.
  ///
  /// In en, this message translates to:
  /// **'Status & Notes'**
  String get supplierStatusNotes;

  /// No description provided for @supplierCreateTaxRule.
  ///
  /// In en, this message translates to:
  /// **'Create Tax Rule'**
  String get supplierCreateTaxRule;

  /// No description provided for @supplierDeleteTaxRule.
  ///
  /// In en, this message translates to:
  /// **'Delete Tax Rule'**
  String get supplierDeleteTaxRule;

  /// No description provided for @supplierDiscountType.
  ///
  /// In en, this message translates to:
  /// **'Discount Type *'**
  String get supplierDiscountType;

  /// No description provided for @supplierOrderLevelTax.
  ///
  /// In en, this message translates to:
  /// **'Order-level tax'**
  String get supplierOrderLevelTax;

  /// No description provided for @supplierPromotionRules.
  ///
  /// In en, this message translates to:
  /// **'Promotion Rules'**
  String get supplierPromotionRules;

  /// No description provided for @supplierSelectBranches.
  ///
  /// In en, this message translates to:
  /// **'Select Branches'**
  String get supplierSelectBranches;

  /// No description provided for @supplierWholesaleDeals.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Deals'**
  String get supplierWholesaleDeals;

  /// No description provided for @supplierDeletePromotion.
  ///
  /// In en, this message translates to:
  /// **'Delete Promotion'**
  String get supplierDeletePromotion;

  /// No description provided for @supplierDiscountValue.
  ///
  /// In en, this message translates to:
  /// **'Discount Value *'**
  String get supplierDiscountValue;

  /// No description provided for @supplierExpressDelivery.
  ///
  /// In en, this message translates to:
  /// **'Express Delivery'**
  String get supplierExpressDelivery;

  /// No description provided for @supplierManageTaxRules.
  ///
  /// In en, this message translates to:
  /// **'Manage Tax Rules'**
  String get supplierManageTaxRules;

  /// No description provided for @supplierMinOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'Min Order Amount'**
  String get supplierMinOrderAmount;

  /// No description provided for @supplierNoResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get supplierNoResultsFound;

  /// No description provided for @supplierNoTaxRulesYet.
  ///
  /// In en, this message translates to:
  /// **'No tax rules yet'**
  String get supplierNoTaxRulesYet;

  /// No description provided for @supplierPleaseSelectA.
  ///
  /// In en, this message translates to:
  /// **'Please select a '**
  String get supplierPleaseSelectA;

  /// No description provided for @supplierPricingTiming.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Timing'**
  String get supplierPricingTiming;

  /// No description provided for @supplierPromotionName.
  ///
  /// In en, this message translates to:
  /// **'Promotion Name *'**
  String get supplierPromotionName;

  /// No description provided for @supplierPromotionTarget.
  ///
  /// In en, this message translates to:
  /// **'Promotion Target'**
  String get supplierPromotionTarget;

  /// No description provided for @supplierSearchTaxRules.
  ///
  /// In en, this message translates to:
  /// **'Search tax rules'**
  String get supplierSearchTaxRules;

  /// No description provided for @supplierSelectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product *'**
  String get supplierSelectProduct;

  /// No description provided for @supplierUpdatePromotion.
  ///
  /// In en, this message translates to:
  /// **'Update Promotion'**
  String get supplierUpdatePromotion;

  /// No description provided for @supplierManagePromotions.
  ///
  /// In en, this message translates to:
  /// **'Manage Promotions'**
  String get supplierManagePromotions;

  /// No description provided for @supplierNoPromotionsYet.
  ///
  /// In en, this message translates to:
  /// **'No promotions yet'**
  String get supplierNoPromotionsYet;

  /// No description provided for @supplierScheduleStatus.
  ///
  /// In en, this message translates to:
  /// **'Schedule & Status'**
  String get supplierScheduleStatus;

  /// No description provided for @supplierSearchPromotions.
  ///
  /// In en, this message translates to:
  /// **'Search promotions'**
  String get supplierSearchPromotions;

  /// No description provided for @supplierSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category *'**
  String get supplierSelectCategory;

  /// No description provided for @supplierSelectedBranches.
  ///
  /// In en, this message translates to:
  /// **'Selected Branches'**
  String get supplierSelectedBranches;

  /// No description provided for @supplierStandardDelivery.
  ///
  /// In en, this message translates to:
  /// **'Standard Delivery'**
  String get supplierStandardDelivery;

  /// No description provided for @supplierTaxApplicability.
  ///
  /// In en, this message translates to:
  /// **'Tax Applicability'**
  String get supplierTaxApplicability;

  /// No description provided for @supplierTaxConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Tax Configuration'**
  String get supplierTaxConfiguration;

  /// No description provided for @supplierAutoGenerateName.
  ///
  /// In en, this message translates to:
  /// **'Auto-generate name'**
  String get supplierAutoGenerateName;

  /// No description provided for @supplierBannerInformation.
  ///
  /// In en, this message translates to:
  /// **'Banner Information'**
  String get supplierBannerInformation;

  /// No description provided for @supplierCouponInformation.
  ///
  /// In en, this message translates to:
  /// **'Coupon Information'**
  String get supplierCouponInformation;

  /// No description provided for @supplierMethodInformation.
  ///
  /// In en, this message translates to:
  /// **'Method Information'**
  String get supplierMethodInformation;

  /// No description provided for @supplierPickupFromBranch.
  ///
  /// In en, this message translates to:
  /// **'Pickup from Branch'**
  String get supplierPickupFromBranch;

  /// No description provided for @supplierPickupFromBranch2.
  ///
  /// In en, this message translates to:
  /// **'Pickup from branch'**
  String get supplierPickupFromBranch2;

  /// No description provided for @supplierCountryIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get supplierCountryIsRequired;

  /// No description provided for @supplierMaxDiscountAmount.
  ///
  /// In en, this message translates to:
  /// **'Max Discount Amount'**
  String get supplierMaxDiscountAmount;

  /// No description provided for @supplierNoMatchingBanners.
  ///
  /// In en, this message translates to:
  /// **'No matching banners'**
  String get supplierNoMatchingBanners;

  /// No description provided for @supplierBranchApplicability.
  ///
  /// In en, this message translates to:
  /// **'Branch Applicability'**
  String get supplierBranchApplicability;

  /// No description provided for @supplierDiscountValue2.
  ///
  /// In en, this message translates to:
  /// **'Discount Value (%) *'**
  String get supplierDiscountValue2;

  /// No description provided for @supplierEditShippingMethod.
  ///
  /// In en, this message translates to:
  /// **'Edit Shipping Method'**
  String get supplierEditShippingMethod;

  /// No description provided for @supplierMinimumOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Amount'**
  String get supplierMinimumOrderAmount;

  /// No description provided for @supplierSelectSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Select SubCategory *'**
  String get supplierSelectSubcategory;

  /// No description provided for @supplierShippingMethodList.
  ///
  /// In en, this message translates to:
  /// **'Shipping Method List'**
  String get supplierShippingMethodList;

  /// No description provided for @supplierTaxRuleInformation.
  ///
  /// In en, this message translates to:
  /// **'Tax Rule Information'**
  String get supplierTaxRuleInformation;

  /// No description provided for @supplierNoMatchingTaxRules.
  ///
  /// In en, this message translates to:
  /// **'No matching tax rules'**
  String get supplierNoMatchingTaxRules;

  /// No description provided for @supplierPromotionInformation.
  ///
  /// In en, this message translates to:
  /// **'Promotion Information'**
  String get supplierPromotionInformation;

  /// No description provided for @supplierFieldnameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'\$fieldName is required'**
  String get supplierFieldnameIsRequired;

  /// No description provided for @supplierCouldNotLoadBanners.
  ///
  /// In en, this message translates to:
  /// **'Could not load banners'**
  String get supplierCouldNotLoadBanners;

  /// No description provided for @supplierCouldNotLoadCoupons.
  ///
  /// In en, this message translates to:
  /// **'Could not load coupons'**
  String get supplierCouldNotLoadCoupons;

  /// No description provided for @supplierCreateShippingMethod.
  ///
  /// In en, this message translates to:
  /// **'Create Shipping Method'**
  String get supplierCreateShippingMethod;

  /// No description provided for @supplierDeleteShippingMethod.
  ///
  /// In en, this message translates to:
  /// **'Delete Shipping Method'**
  String get supplierDeleteShippingMethod;

  /// No description provided for @supplierNoMatchingPromotions.
  ///
  /// In en, this message translates to:
  /// **'No matching promotions'**
  String get supplierNoMatchingPromotions;

  /// No description provided for @supplierPromotionTitleCopied.
  ///
  /// In en, this message translates to:
  /// **'Promotion title copied'**
  String get supplierPromotionTitleCopied;

  /// No description provided for @supplierSortOrderIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Sort order is required'**
  String get supplierSortOrderIsRequired;

  /// No description provided for @supplierEstimatedDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery Time'**
  String get supplierEstimatedDeliveryTime;

  /// No description provided for @supplierFreeShippingThreshold.
  ///
  /// In en, this message translates to:
  /// **'Free Shipping Threshold'**
  String get supplierFreeShippingThreshold;

  /// No description provided for @supplierManageShippingMethods.
  ///
  /// In en, this message translates to:
  /// **'Manage Shipping Methods'**
  String get supplierManageShippingMethods;

  /// No description provided for @supplierNoShippingMethodsYet.
  ///
  /// In en, this message translates to:
  /// **'No shipping methods yet'**
  String get supplierNoShippingMethodsYet;

  /// No description provided for @supplierPleaseSelectACountry.
  ///
  /// In en, this message translates to:
  /// **'Please select a country'**
  String get supplierPleaseSelectACountry;

  /// No description provided for @supplierSearchShippingMethods.
  ///
  /// In en, this message translates to:
  /// **'Search shipping methods'**
  String get supplierSearchShippingMethods;

  /// No description provided for @supplierCouldNotLoadTaxRules.
  ///
  /// In en, this message translates to:
  /// **'Could not load tax rules'**
  String get supplierCouldNotLoadTaxRules;

  /// No description provided for @supplierCouldNotLoadPromotions.
  ///
  /// In en, this message translates to:
  /// **'Could not load promotions'**
  String get supplierCouldNotLoadPromotions;

  /// No description provided for @supplierApplyTaxToShippingCost.
  ///
  /// In en, this message translates to:
  /// **'Apply tax to shipping cost'**
  String get supplierApplyTaxToShippingCost;

  /// No description provided for @supplierBannerCopiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Banner copied successfully'**
  String get supplierBannerCopiedSuccessfully;

  /// No description provided for @supplierNoMatchingShippingMethods.
  ///
  /// In en, this message translates to:
  /// **'No matching shipping methods'**
  String get supplierNoMatchingShippingMethods;

  /// No description provided for @supplierSpecialOffersForRetailers.
  ///
  /// In en, this message translates to:
  /// **'Special offers for retailers'**
  String get supplierSpecialOffersForRetailers;

  /// No description provided for @supplierCouldNotLoadTargetOptions.
  ///
  /// In en, this message translates to:
  /// **'Could not load target options'**
  String get supplierCouldNotLoadTargetOptions;

  /// No description provided for @supplierPleaseSelectACategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a category first'**
  String get supplierPleaseSelectACategoryFirst;

  /// No description provided for @supplierRegionIsRequiredForLebanon.
  ///
  /// In en, this message translates to:
  /// **'Region is required for Lebanon'**
  String get supplierRegionIsRequiredForLebanon;

  /// No description provided for @supplierCouldNotLoadShippingMethods.
  ///
  /// In en, this message translates to:
  /// **'Could not load shipping methods'**
  String get supplierCouldNotLoadShippingMethods;

  /// No description provided for @supplierTaxRateMustBeGreaterThan0.
  ///
  /// In en, this message translates to:
  /// **'Tax rate must be greater than 0'**
  String get supplierTaxRateMustBeGreaterThan0;

  /// No description provided for @supplierFieldnameMustBeAValidNumber.
  ///
  /// In en, this message translates to:
  /// **'\$fieldName must be a valid number'**
  String get supplierFieldnameMustBeAValidNumber;

  /// No description provided for @supplierFieldnameMustBeGreaterThan0.
  ///
  /// In en, this message translates to:
  /// **'\$fieldName must be greater than 0'**
  String get supplierFieldnameMustBeGreaterThan0;

  /// No description provided for @supplierPleaseSelectAtLeastOneBranch.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one branch'**
  String get supplierPleaseSelectAtLeastOneBranch;

  /// No description provided for @supplierBannerImageUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Banner image uploaded successfully'**
  String get supplierBannerImageUploadedSuccessfully;

  /// No description provided for @supplierOptionalNotesAboutThisTaxRule.
  ///
  /// In en, this message translates to:
  /// **'Optional notes about this tax rule'**
  String get supplierOptionalNotesAboutThisTaxRule;

  /// No description provided for @supplierPleaseSelectARegionForLebanon.
  ///
  /// In en, this message translates to:
  /// **'Please select a region for Lebanon'**
  String get supplierPleaseSelectARegionForLebanon;

  /// No description provided for @supplierValidFromMustBeBeforeValidTo.
  ///
  /// In en, this message translates to:
  /// **'Valid From must be before Valid To'**
  String get supplierValidFromMustBeBeforeValidTo;

  /// No description provided for @supplierTaxRateCannotBeGreaterThan100.
  ///
  /// In en, this message translates to:
  /// **'Tax rate cannot be greater than 100'**
  String get supplierTaxRateCannotBeGreaterThan100;

  /// No description provided for @supplierUploadedImageUrlWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Uploaded image URL will appear here'**
  String get supplierUploadedImageUrlWillAppearHere;

  /// No description provided for @supplierNoRegionsAvailableForThisCountry.
  ///
  /// In en, this message translates to:
  /// **'No regions available for this country.'**
  String get supplierNoRegionsAvailableForThisCountry;

  /// No description provided for @supplierUrlMustStartWithHttpOrHttps.
  ///
  /// In en, this message translates to:
  /// **'URL must start with http:// or https://'**
  String get supplierUrlMustStartWithHttpOrHttps;

  /// No description provided for @supplierOptionalNotesAboutThisShippingMethod.
  ///
  /// In en, this message translates to:
  /// **'Optional notes about this shipping method'**
  String get supplierOptionalNotesAboutThisShippingMethod;

  /// No description provided for @supplierSortOrderMustBeAValidPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Sort order must be a valid positive number'**
  String get supplierSortOrderMustBeAValidPositiveNumber;

  /// No description provided for @supplierPercentDiscountCannotBeGreaterThan100.
  ///
  /// In en, this message translates to:
  /// **'Percent discount cannot be greater than 100'**
  String get supplierPercentDiscountCannotBeGreaterThan100;

  /// No description provided for @supplierFieldnameMustBeGreaterThanOrEqualTo0.
  ///
  /// In en, this message translates to:
  /// **'\$fieldName must be greater than or equal to 0'**
  String get supplierFieldnameMustBeGreaterThanOrEqualTo0;

  /// No description provided for @supplierChooseAPresetOrKeepCustomAndEnterYourOwnOrderLevelTaxRule.
  ///
  /// In en, this message translates to:
  /// **'Choose a preset or keep Custom and enter your own order-level tax rule.'**
  String get supplierChooseAPresetOrKeepCustomAndEnterYourOwnOrderLevelTaxRule;

  /// No description provided for @supplierSelectedBranchesAreLoadedFromTheBackendBranchManagementModule.
  ///
  /// In en, this message translates to:
  /// **'Selected branches are loaded from the backend Branch Management module.'**
  String
  get supplierSelectedBranchesAreLoadedFromTheBackendBranchManagementModule;

  /// No description provided for @supplierNoActiveBranchesAvailableAddBranchesFromBranchManagementFirst.
  ///
  /// In en, this message translates to:
  /// **'No active branches available. Add branches from Branch Management first.'**
  String
  get supplierNoActiveBranchesAvailableAddBranchesFromBranchManagementFirst;

  /// No description provided for @supplierCountryIsRequiredBecauseTaxIsCalculatedFromTheRetailerDeliveryCountry.
  ///
  /// In en, this message translates to:
  /// **'Country is required because tax is calculated from the retailer delivery country.'**
  String
  get supplierCountryIsRequiredBecauseTaxIsCalculatedFromTheRetailerDeliveryCountry;

  /// No description provided for @supplierTheSelectedItemNameIsShownHereButTheBackendSavesItsIdInTargetvalue.
  ///
  /// In en, this message translates to:
  /// **'The selected item name is shown here, but the backend saves its ID in targetValue.'**
  String
  get supplierTheSelectedItemNameIsShownHereButTheBackendSavesItsIdInTargetvalue;

  /// No description provided for @supplierCreateTaxRulesFromTheSupplierDashboardQuickActionOrTapThePlusIconAbove.
  ///
  /// In en, this message translates to:
  /// **'Create tax rules from the supplier dashboard quick action or tap the plus icon above.'**
  String
  get supplierCreateTaxRulesFromTheSupplierDashboardQuickActionOrTapThePlusIconAbove;

  /// No description provided for @supplierExampleEnter11For11TaxIsAppliedToTheWholeOrderBasedOnCountryAndRegion.
  ///
  /// In en, this message translates to:
  /// **'Example: enter 11 for 11%. Tax is applied to the whole order based on country and region.'**
  String
  get supplierExampleEnter11For11TaxIsAppliedToTheWholeOrderBasedOnCountryAndRegion;

  /// No description provided for @supplierCountryAndRegionAreUsedLaterByRetailerCheckoutToShowTheCorrectShippingOptions.
  ///
  /// In en, this message translates to:
  /// **'Country and region are used later by retailer checkout to show the correct shipping options.'**
  String
  get supplierCountryAndRegionAreUsedLaterByRetailerCheckoutToShowTheCorrectShippingOptions;

  /// No description provided for @supplierCreateShippingMethodsFromTheSupplierDashboardQuickActionOrTapThePlusIconAbove.
  ///
  /// In en, this message translates to:
  /// **'Create shipping methods from the supplier dashboard quick action or tap the plus icon above.'**
  String
  get supplierCreateShippingMethodsFromTheSupplierDashboardQuickActionOrTapThePlusIconAbove;

  /// No description provided for @supplierChooseNoRegionForACountryLevelRuleOrChooseASpecificRegionForAMoreSpecificRule.
  ///
  /// In en, this message translates to:
  /// **'Choose No region for a country-level rule, or choose a specific region for a more specific rule.'**
  String
  get supplierChooseNoRegionForACountryLevelRuleOrChooseASpecificRegionForAMoreSpecificRule;

  /// No description provided for @supplierCreateAndManageDeliveryOrPickupOptionsByCountryRegionBranchScopeCostAndAvailability.
  ///
  /// In en, this message translates to:
  /// **'Create and manage delivery or pickup options by country, region, branch scope, cost, and availability.'**
  String
  get supplierCreateAndManageDeliveryOrPickupOptionsByCountryRegionBranchScopeCostAndAvailability;

  /// No description provided for @supplierUploadAnImageFromYourDeviceTheBackendReturnsAUrlAndStoresItInTheBannerImageurlField.
  ///
  /// In en, this message translates to:
  /// **'Upload an image from your device. The backend returns a URL and stores it in the banner imageUrl field.'**
  String
  get supplierUploadAnImageFromYourDeviceTheBackendReturnsAUrlAndStoresItInTheBannerImageurlField;

  /// No description provided for @supplierConfigureOrderLevelTaxByCountryAndRegionRetailerCheckoutWillUseTheseRulesToCalculateTax.
  ///
  /// In en, this message translates to:
  /// **'Configure order-level tax by country and region. Retailer checkout will use these rules to calculate tax.'**
  String
  get supplierConfigureOrderLevelTaxByCountryAndRegionRetailerCheckoutWillUseTheseRulesToCalculateTax;

  /// No description provided for @supplierIfEnabledCheckoutTaxWillIncludeShippingCostIfDisabledTaxAppliesOnlyToItemsAfterPromotionDiscount.
  ///
  /// In en, this message translates to:
  /// **'If enabled, checkout tax will include shipping cost. If disabled, tax applies only to items after promotion discount.'**
  String
  get supplierIfEnabledCheckoutTaxWillIncludeShippingCostIfDisabledTaxAppliesOnlyToItemsAfterPromotionDiscount;

  /// No description provided for @supplierBranchesDefineWhereThisShippingMethodIsValidRetailerCheckoutWillLaterMatchShippingWithFulfillmentBranch.
  ///
  /// In en, this message translates to:
  /// **'Branches define where this shipping method is valid. Retailer checkout will later match shipping with fulfillment branch.'**
  String
  get supplierBranchesDefineWhereThisShippingMethodIsValidRetailerCheckoutWillLaterMatchShippingWithFulfillmentBranch;

  /// No description provided for @supplierFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String supplierFieldRequired(Object fieldName);

  /// No description provided for @supplierFieldGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} must be greater than 0'**
  String supplierFieldGreaterThanZero(Object fieldName);

  /// No description provided for @supplierFieldGreaterThanOrEqualZero.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} must be greater than or equal to 0'**
  String supplierFieldGreaterThanOrEqualZero(Object fieldName);

  /// No description provided for @supplierFieldValidNumber.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} must be a valid number'**
  String supplierFieldValidNumber(Object fieldName);

  /// No description provided for @supplierBranchesValue.
  ///
  /// In en, this message translates to:
  /// **'Branches: {value}'**
  String supplierBranchesValue(Object value);

  /// No description provided for @supplierTargetValue.
  ///
  /// In en, this message translates to:
  /// **'Target: {value}'**
  String supplierTargetValue(Object value);

  /// No description provided for @supplierOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Order: {value}'**
  String supplierOrderValue(Object value);

  /// No description provided for @supplierVisibleNowValue.
  ///
  /// In en, this message translates to:
  /// **'Visible now: {value}'**
  String supplierVisibleNowValue(Object value);

  /// No description provided for @supplierValidNowValue.
  ///
  /// In en, this message translates to:
  /// **'Valid now: {value}'**
  String supplierValidNowValue(Object value);

  /// No description provided for @notRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Not required'**
  String get notRequiredLabel;

  /// No description provided for @pickButton.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get pickButton;

  /// No description provided for @uploadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploadingLabel;

  /// No description provided for @supplierBannerImagePlain.
  ///
  /// In en, this message translates to:
  /// **'Banner Image'**
  String get supplierBannerImagePlain;

  /// No description provided for @supplierBannersDescription.
  ///
  /// In en, this message translates to:
  /// **'View, create, edit, and delete supplier banners saved in the backend database. These banners will later appear for retailers on the home screen.'**
  String get supplierBannersDescription;

  /// No description provided for @supplierBusinessDaysHint.
  ///
  /// In en, this message translates to:
  /// **'2-3 business days'**
  String get supplierBusinessDaysHint;

  /// No description provided for @supplierChooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose category'**
  String get supplierChooseCategory;

  /// No description provided for @supplierCouponCodePlain.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code'**
  String get supplierCouponCodePlain;

  /// No description provided for @supplierCouponCopied.
  ///
  /// In en, this message translates to:
  /// **'{couponCode} copied'**
  String supplierCouponCopied(Object couponCode);

  /// No description provided for @supplierCouponDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe this coupon'**
  String get supplierCouponDescriptionHint;

  /// No description provided for @supplierCouponsDescription.
  ///
  /// In en, this message translates to:
  /// **'View, create, edit, and delete supplier coupons saved in the backend database. These coupons can later be consumed by the retailer cart and checkout flow.'**
  String get supplierCouponsDescription;

  /// No description provided for @supplierCreateBannersFromDashboard.
  ///
  /// In en, this message translates to:
  /// **'Create banners from the supplier dashboard quick action or tap the plus icon above.'**
  String get supplierCreateBannersFromDashboard;

  /// No description provided for @supplierCreateCouponsFromDashboard.
  ///
  /// In en, this message translates to:
  /// **'Create coupons from the supplier dashboard quick action or tap the plus icon above.'**
  String get supplierCreateCouponsFromDashboard;

  /// No description provided for @supplierCreatePromotionsFromDashboard.
  ///
  /// In en, this message translates to:
  /// **'Create promotions from the supplier dashboard quick action or tap the plus icon above.'**
  String get supplierCreatePromotionsFromDashboard;

  /// No description provided for @supplierDeleteBannerConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{bannerTitle}\"?'**
  String supplierDeleteBannerConfirmation(Object bannerTitle);

  /// No description provided for @supplierDeleteCouponConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete coupon \"{couponCode}\"?'**
  String supplierDeleteCouponConfirmation(Object couponCode);

  /// No description provided for @supplierDeletePromotionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{promotionTitle}\"?'**
  String supplierDeletePromotionConfirmation(Object promotionTitle);

  /// No description provided for @supplierDeleteShippingMethodConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{methodName}\"?'**
  String supplierDeleteShippingMethodConfirmation(Object methodName);

  /// No description provided for @supplierDeleteTaxRuleConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{ruleName}\"?'**
  String supplierDeleteTaxRuleConfirmation(Object ruleName);

  /// No description provided for @supplierDiscountValuePercent.
  ///
  /// In en, this message translates to:
  /// **'Discount Value (%) *'**
  String get supplierDiscountValuePercent;

  /// No description provided for @supplierDiscountValuePlain.
  ///
  /// In en, this message translates to:
  /// **'Discount Value'**
  String get supplierDiscountValuePlain;

  /// No description provided for @supplierEndDateAfterStartDate.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get supplierEndDateAfterStartDate;

  /// No description provided for @supplierEstimatedDeliveryTimePlain.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery Time'**
  String get supplierEstimatedDeliveryTimePlain;

  /// No description provided for @supplierFixedDiscountHelp.
  ///
  /// In en, this message translates to:
  /// **'Fixed discount means a fixed amount off, for example \$20 off.'**
  String get supplierFixedDiscountHelp;

  /// No description provided for @supplierFreeShippingThresholdPlain.
  ///
  /// In en, this message translates to:
  /// **'Free Shipping Threshold'**
  String get supplierFreeShippingThresholdPlain;

  /// No description provided for @supplierManageHomeBanners.
  ///
  /// In en, this message translates to:
  /// **'Manage Home Banners'**
  String get supplierManageHomeBanners;

  /// No description provided for @supplierMaxDiscountFixedHelp.
  ///
  /// In en, this message translates to:
  /// **'Maximum discount amount is not needed for fixed promotions.'**
  String get supplierMaxDiscountFixedHelp;

  /// No description provided for @supplierMaxDiscountPercentHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. It limits the total discount when using percent promotions.'**
  String get supplierMaxDiscountPercentHelp;

  /// No description provided for @supplierMaximumDiscountAmount.
  ///
  /// In en, this message translates to:
  /// **'Maximum Discount Amount'**
  String get supplierMaximumDiscountAmount;

  /// No description provided for @supplierMaximumDiscountAmountPlain.
  ///
  /// In en, this message translates to:
  /// **'Maximum Discount Amount'**
  String get supplierMaximumDiscountAmountPlain;

  /// No description provided for @supplierMethodNamePlain.
  ///
  /// In en, this message translates to:
  /// **'Method Name'**
  String get supplierMethodNamePlain;

  /// No description provided for @supplierMethodsShown.
  ///
  /// In en, this message translates to:
  /// **'{count} methods shown'**
  String supplierMethodsShown(Object count);

  /// No description provided for @supplierMinimumOrderAmountPlain.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Amount'**
  String get supplierMinimumOrderAmountPlain;

  /// No description provided for @supplierNoActiveBranchesAvailableAddBranchesFirst.
  ///
  /// In en, this message translates to:
  /// **'No active branches available. Add branches from Branch Management first.'**
  String get supplierNoActiveBranchesAvailableAddBranchesFirst;

  /// No description provided for @supplierNoActiveCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No active categories available.'**
  String get supplierNoActiveCategoriesAvailable;

  /// No description provided for @supplierNoActiveProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No active products available.'**
  String get supplierNoActiveProductsAvailable;

  /// No description provided for @supplierNoActiveSubcategoriesForCategory.
  ///
  /// In en, this message translates to:
  /// **'No active subcategories for this category.'**
  String get supplierNoActiveSubcategoriesForCategory;

  /// No description provided for @supplierNoRegionsAvailableForCountry.
  ///
  /// In en, this message translates to:
  /// **'No regions available for this country.'**
  String get supplierNoRegionsAvailableForCountry;

  /// No description provided for @supplierOnlyForPercentCoupons.
  ///
  /// In en, this message translates to:
  /// **'Only for percent coupons'**
  String get supplierOnlyForPercentCoupons;

  /// No description provided for @supplierOnlyForPercentDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Only for percent discounts'**
  String get supplierOnlyForPercentDiscounts;

  /// No description provided for @supplierPercentDiscountHelp.
  ///
  /// In en, this message translates to:
  /// **'Percent discount means percentage off, for example 10% off. Maximum discount amount can limit supplier loss.'**
  String get supplierPercentDiscountHelp;

  /// No description provided for @supplierPleaseSelectTarget.
  ///
  /// In en, this message translates to:
  /// **'Please select {targetLabel}'**
  String supplierPleaseSelectTarget(Object targetLabel);

  /// No description provided for @supplierPromotionBranchesHelp.
  ///
  /// In en, this message translates to:
  /// **'Branches define where the promotion is valid. Product/category selection above is not filtered by branch.'**
  String get supplierPromotionBranchesHelp;

  /// No description provided for @supplierPromotionDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Short description shown later to retailer side'**
  String get supplierPromotionDescriptionHint;

  /// No description provided for @supplierPromotionTargetHelp.
  ///
  /// In en, this message translates to:
  /// **'The target defines which products are included in the promotion. Branch availability is selected separately below.'**
  String get supplierPromotionTargetHelp;

  /// No description provided for @supplierPromotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Promotion Title *'**
  String get supplierPromotionTitle;

  /// No description provided for @supplierPromotionTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Food category wholesale deal'**
  String get supplierPromotionTitleHint;

  /// No description provided for @supplierPromotionTitlePlain.
  ///
  /// In en, this message translates to:
  /// **'Promotion Title'**
  String get supplierPromotionTitlePlain;

  /// No description provided for @supplierPromotionsDescription.
  ///
  /// In en, this message translates to:
  /// **'View, search, create, edit, and delete supplier wholesale promotions for products, categories, subcategories, or all products.'**
  String get supplierPromotionsDescription;

  /// No description provided for @supplierPromotionsShown.
  ///
  /// In en, this message translates to:
  /// **'{count} promotions shown'**
  String supplierPromotionsShown(Object count);

  /// No description provided for @supplierRuleNamePlain.
  ///
  /// In en, this message translates to:
  /// **'Rule Name'**
  String get supplierRuleNamePlain;

  /// No description provided for @supplierRulesShown.
  ///
  /// In en, this message translates to:
  /// **'{count} rules shown'**
  String supplierRulesShown(Object count);

  /// No description provided for @supplierSelectCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a category first.'**
  String get supplierSelectCategoryFirst;

  /// No description provided for @supplierSelectTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Select {targetLabel}'**
  String supplierSelectTargetHint(Object targetLabel);

  /// No description provided for @supplierSelectTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Select {targetLabel} *'**
  String supplierSelectTargetLabel(Object targetLabel);

  /// No description provided for @supplierSelectedBranchesLoadedFromBackendBranchManagement.
  ///
  /// In en, this message translates to:
  /// **'Selected branches are loaded from the backend Branch Management module.'**
  String get supplierSelectedBranchesLoadedFromBackendBranchManagement;

  /// No description provided for @supplierSelectedItemNameShownHere.
  ///
  /// In en, this message translates to:
  /// **'The selected item name is shown here, but the backend saves its ID in targetValue.'**
  String get supplierSelectedItemNameShownHere;

  /// No description provided for @supplierShippingCostPlain.
  ///
  /// In en, this message translates to:
  /// **'Shipping Cost'**
  String get supplierShippingCostPlain;

  /// No description provided for @supplierShippingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Beirut Standard Delivery'**
  String get supplierShippingNameHint;

  /// No description provided for @supplierSortOrderPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Sort order must be a valid positive number'**
  String get supplierSortOrderPositiveNumber;

  /// No description provided for @supplierSortOrderRequired.
  ///
  /// In en, this message translates to:
  /// **'Sort order is required'**
  String get supplierSortOrderRequired;

  /// No description provided for @supplierTargetUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Target URL is required'**
  String get supplierTargetUrlRequired;

  /// No description provided for @supplierTaxRatePlain.
  ///
  /// In en, this message translates to:
  /// **'Tax Rate'**
  String get supplierTaxRatePlain;

  /// No description provided for @supplierTitlePlain.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get supplierTitlePlain;

  /// No description provided for @supplierValidFromBeforeValidTo.
  ///
  /// In en, this message translates to:
  /// **'Valid From must be before Valid To'**
  String get supplierValidFromBeforeValidTo;

  /// No description provided for @supplierScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get supplierScheduled;

  /// No description provided for @supplierExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get supplierExpired;

  /// No description provided for @supplierUsageLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Usage limit reached'**
  String get supplierUsageLimitReached;

  /// No description provided for @supplierFreePickup.
  ///
  /// In en, this message translates to:
  /// **'Free pickup'**
  String get supplierFreePickup;

  /// No description provided for @supplierNoMinimum.
  ///
  /// In en, this message translates to:
  /// **'No minimum'**
  String get supplierNoMinimum;

  /// No description provided for @supplierMinimumValue.
  ///
  /// In en, this message translates to:
  /// **'{value} minimum'**
  String supplierMinimumValue(Object value);

  /// No description provided for @supplierNoFreeShipping.
  ///
  /// In en, this message translates to:
  /// **'No free shipping'**
  String get supplierNoFreeShipping;

  /// No description provided for @supplierFreeAboveValue.
  ///
  /// In en, this message translates to:
  /// **'Free above {value}'**
  String supplierFreeAboveValue(Object value);

  /// No description provided for @supplierNoLocationSelected.
  ///
  /// In en, this message translates to:
  /// **'No location selected'**
  String get supplierNoLocationSelected;

  /// No description provided for @supplierNoBranchesSelected.
  ///
  /// In en, this message translates to:
  /// **'No branches selected'**
  String get supplierNoBranchesSelected;

  /// No description provided for @supplierNoTarget.
  ///
  /// In en, this message translates to:
  /// **'No target'**
  String get supplierNoTarget;

  /// No description provided for @supplierDrawerRfqs.
  ///
  /// In en, this message translates to:
  /// **'RFQ Requests'**
  String get supplierDrawerRfqs;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @calculatedAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'Calculated at checkout'**
  String get calculatedAtCheckout;

  /// No description provided for @totalBeforeShipping.
  ///
  /// In en, this message translates to:
  /// **'Total before shipping'**
  String get totalBeforeShipping;

  /// No description provided for @productAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'Product AI Assistant'**
  String get productAiAssistant;

  /// No description provided for @askAi.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAi;

  /// No description provided for @askAboutThisProduct.
  ///
  /// In en, this message translates to:
  /// **'Ask about this product...'**
  String get askAboutThisProduct;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get aiThinking;

  /// No description provided for @aiWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about this product. I can help with MOQ, stock, price, and whether it fits your store.'**
  String get aiWelcomeMessage;

  /// No description provided for @aiSuggestionFitStore.
  ///
  /// In en, this message translates to:
  /// **'Is this product good for my store?'**
  String get aiSuggestionFitStore;

  /// No description provided for @aiSuggestionOrderQuantity.
  ///
  /// In en, this message translates to:
  /// **'How many units should I order?'**
  String get aiSuggestionOrderQuantity;

  /// No description provided for @aiSuggestionMoqStock.
  ///
  /// In en, this message translates to:
  /// **'Explain the MOQ and stock.'**
  String get aiSuggestionMoqStock;

  /// No description provided for @aiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI assistant is temporarily unavailable. Please try again later.'**
  String get aiUnavailable;

  /// No description provided for @aiTimeout.
  ///
  /// In en, this message translates to:
  /// **'The AI assistant took too long. Please try again.'**
  String get aiTimeout;

  /// No description provided for @aiEmptyAnswer.
  ///
  /// In en, this message translates to:
  /// **'I could not generate an answer. Please try again.'**
  String get aiEmptyAnswer;

  /// No description provided for @rfqMyRfqs.
  ///
  /// In en, this message translates to:
  /// **'My RFQs'**
  String get rfqMyRfqs;

  /// No description provided for @rfqCreate.
  ///
  /// In en, this message translates to:
  /// **'Create RFQ'**
  String get rfqCreate;

  /// No description provided for @rfqEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit RFQ'**
  String get rfqEdit;

  /// No description provided for @rfqDetails.
  ///
  /// In en, this message translates to:
  /// **'RFQ Details'**
  String get rfqDetails;

  /// No description provided for @rfqRequestsYouPosted.
  ///
  /// In en, this message translates to:
  /// **'Requests you posted'**
  String get rfqRequestsYouPosted;

  /// No description provided for @rfqHowWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How RFQ works'**
  String get rfqHowWorksTitle;

  /// No description provided for @rfqHowWorksMessage.
  ///
  /// In en, this message translates to:
  /// **'Post a product request when you cannot find what you need. Suppliers will review it and send quotations with price, quantity, and delivery details.'**
  String get rfqHowWorksMessage;

  /// No description provided for @rfqNoRfqsYet.
  ///
  /// In en, this message translates to:
  /// **'No RFQs yet'**
  String get rfqNoRfqsYet;

  /// No description provided for @rfqNoRfqsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Create your first request and let suppliers send you quotations.'**
  String get rfqNoRfqsYetMessage;

  /// No description provided for @rfqProductRequest.
  ///
  /// In en, this message translates to:
  /// **'Product request'**
  String get rfqProductRequest;

  /// No description provided for @rfqProductName.
  ///
  /// In en, this message translates to:
  /// **'Product name *'**
  String get rfqProductName;

  /// No description provided for @rfqProductNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Organic milk cartons'**
  String get rfqProductNameHint;

  /// No description provided for @rfqProductNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get rfqProductNameRequired;

  /// No description provided for @rfqProductNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Product name must be at least 2 characters'**
  String get rfqProductNameTooShort;

  /// No description provided for @rfqUploadProductImage.
  ///
  /// In en, this message translates to:
  /// **'Upload product image'**
  String get rfqUploadProductImage;

  /// No description provided for @rfqUploadProductImageHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. This photo will also appear for suppliers when they view your RFQ.'**
  String get rfqUploadProductImageHint;

  /// No description provided for @rfqCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get rfqCategory;

  /// No description provided for @rfqCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Food, Electronics...'**
  String get rfqCategoryHint;

  /// No description provided for @rfqSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get rfqSubcategory;

  /// No description provided for @rfqSubcategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Dairy, Phones...'**
  String get rfqSubcategoryHint;

  /// No description provided for @rfqDetailedRequirements.
  ///
  /// In en, this message translates to:
  /// **'Detailed requirements'**
  String get rfqDetailedRequirements;

  /// No description provided for @rfqRequirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements *'**
  String get rfqRequirements;

  /// No description provided for @rfqRequirementsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe specs, quality, packaging, preferred brands, size, color, standards...'**
  String get rfqRequirementsHint;

  /// No description provided for @rfqRequirementsRequired.
  ///
  /// In en, this message translates to:
  /// **'Requirements are required'**
  String get rfqRequirementsRequired;

  /// No description provided for @rfqRequirementsTooShort.
  ///
  /// In en, this message translates to:
  /// **'Requirements must be at least 10 characters'**
  String get rfqRequirementsTooShort;

  /// No description provided for @rfqWriteWithAi.
  ///
  /// In en, this message translates to:
  /// **'Write requirements with AI'**
  String get rfqWriteWithAi;

  /// No description provided for @rfqWritingWithAi.
  ///
  /// In en, this message translates to:
  /// **'Writing...'**
  String get rfqWritingWithAi;

  /// No description provided for @rfqAiProductNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Write the product name first.'**
  String get rfqAiProductNameRequired;

  /// No description provided for @rfqAiReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace requirements?'**
  String get rfqAiReplaceTitle;

  /// No description provided for @rfqAiReplaceMessage.
  ///
  /// In en, this message translates to:
  /// **'The requirements field already has text. Do you want to replace it with AI-generated requirements?'**
  String get rfqAiReplaceMessage;

  /// No description provided for @rfqAiReplaceAction.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get rfqAiReplaceAction;

  /// No description provided for @rfqAiKeepAction.
  ///
  /// In en, this message translates to:
  /// **'Keep current text'**
  String get rfqAiKeepAction;

  /// No description provided for @rfqQuantityAndDelivery.
  ///
  /// In en, this message translates to:
  /// **'Quantity and delivery'**
  String get rfqQuantityAndDelivery;

  /// No description provided for @rfqMinimumQuantity.
  ///
  /// In en, this message translates to:
  /// **'Minimum quantity *'**
  String get rfqMinimumQuantity;

  /// No description provided for @rfqMinimumQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'500'**
  String get rfqMinimumQuantityHint;

  /// No description provided for @rfqEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter valid quantity'**
  String get rfqEnterValidQuantity;

  /// No description provided for @rfqUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get rfqUnit;

  /// No description provided for @rfqUnitHint.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get rfqUnitHint;

  /// No description provided for @rfqTargetUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Target unit price'**
  String get rfqTargetUnitPrice;

  /// No description provided for @rfqOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get rfqOptional;

  /// No description provided for @rfqPreferredDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred delivery time'**
  String get rfqPreferredDeliveryTime;

  /// No description provided for @rfqChooseDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Choose delivery time'**
  String get rfqChooseDeliveryTime;

  /// No description provided for @rfqDeliveryWithin24Hours.
  ///
  /// In en, this message translates to:
  /// **'Within 24 hours'**
  String get rfqDeliveryWithin24Hours;

  /// No description provided for @rfqDelivery2To3Days.
  ///
  /// In en, this message translates to:
  /// **'Within 2-3 days'**
  String get rfqDelivery2To3Days;

  /// No description provided for @rfqDeliveryWithin1Week.
  ///
  /// In en, this message translates to:
  /// **'Within 1 week'**
  String get rfqDeliveryWithin1Week;

  /// No description provided for @rfqDeliveryWithin2Weeks.
  ///
  /// In en, this message translates to:
  /// **'Within 2 weeks'**
  String get rfqDeliveryWithin2Weeks;

  /// No description provided for @rfqDeliveryFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get rfqDeliveryFlexible;

  /// No description provided for @rfqSelectDeadlineDate.
  ///
  /// In en, this message translates to:
  /// **'Select deadline date'**
  String get rfqSelectDeadlineDate;

  /// No description provided for @rfqDeliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery location'**
  String get rfqDeliveryLocation;

  /// No description provided for @rfqCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get rfqCity;

  /// No description provided for @rfqCityHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Beirut'**
  String get rfqCityHint;

  /// No description provided for @rfqDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get rfqDeliveryAddress;

  /// No description provided for @rfqDeliveryAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, building, area, notes...'**
  String get rfqDeliveryAddressHint;

  /// No description provided for @rfqPost.
  ///
  /// In en, this message translates to:
  /// **'Post your RFQ'**
  String get rfqPost;

  /// No description provided for @rfqPosting.
  ///
  /// In en, this message translates to:
  /// **'Posting RFQ...'**
  String get rfqPosting;

  /// No description provided for @rfqSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get rfqSaveChanges;

  /// No description provided for @rfqSavingChanges.
  ///
  /// In en, this message translates to:
  /// **'Saving changes...'**
  String get rfqSavingChanges;

  /// No description provided for @rfqNotFound.
  ///
  /// In en, this message translates to:
  /// **'RFQ not found'**
  String get rfqNotFound;

  /// No description provided for @rfqCannotEditTitle.
  ///
  /// In en, this message translates to:
  /// **'This RFQ cannot be edited'**
  String get rfqCannotEditTitle;

  /// No description provided for @rfqCannotEditSupplierMessage.
  ///
  /// In en, this message translates to:
  /// **'A supplier has already interacted with this request. To keep quotations fair and valid, cancel the RFQ and create a new one if you need changes.'**
  String get rfqCannotEditSupplierMessage;

  /// No description provided for @rfqCannotEditStatusMessage.
  ///
  /// In en, this message translates to:
  /// **'This RFQ status does not allow editing.'**
  String get rfqCannotEditStatusMessage;

  /// No description provided for @rfqBackToDetails.
  ///
  /// In en, this message translates to:
  /// **'Back to details'**
  String get rfqBackToDetails;

  /// No description provided for @rfqSupplierQuotations.
  ///
  /// In en, this message translates to:
  /// **'Supplier quotations'**
  String get rfqSupplierQuotations;

  /// No description provided for @rfqNoQuotesYet.
  ///
  /// In en, this message translates to:
  /// **'No supplier quotations yet. You will see offers here when suppliers respond.'**
  String get rfqNoQuotesYet;

  /// No description provided for @rfqCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel RFQ'**
  String get rfqCancel;

  /// No description provided for @rfqCancelQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel RFQ?'**
  String get rfqCancelQuestion;

  /// No description provided for @rfqCancelMessage.
  ///
  /// In en, this message translates to:
  /// **'This will cancel your RFQ and suppliers will not be able to quote it.'**
  String get rfqCancelMessage;

  /// No description provided for @rfqCancelWithQuotesMessage.
  ///
  /// In en, this message translates to:
  /// **'This RFQ already has supplier quotations. Cancelling keeps the history but prevents new supplier actions.'**
  String get rfqCancelWithQuotesMessage;

  /// No description provided for @rfqKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep RFQ'**
  String get rfqKeep;

  /// No description provided for @rfqDeleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete RFQ?'**
  String get rfqDeleteQuestion;

  /// No description provided for @rfqDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This RFQ has no supplier quotations yet, so it can be safely deleted. This action cannot be undone.'**
  String get rfqDeleteMessage;

  /// No description provided for @rfqDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get rfqDelete;

  /// No description provided for @rfqEditRequest.
  ///
  /// In en, this message translates to:
  /// **'Edit request'**
  String get rfqEditRequest;

  /// No description provided for @rfqCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get rfqCancelRequest;

  /// No description provided for @rfqDeleteRequest.
  ///
  /// In en, this message translates to:
  /// **'Delete request'**
  String get rfqDeleteRequest;

  /// No description provided for @rfqViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get rfqViewDetails;

  /// No description provided for @rfqOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get rfqOpen;

  /// No description provided for @rfqQuoted.
  ///
  /// In en, this message translates to:
  /// **'Quoted'**
  String get rfqQuoted;

  /// No description provided for @rfqAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get rfqAccepted;

  /// No description provided for @rfqClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get rfqClosed;

  /// No description provided for @rfqCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get rfqCancelled;

  /// No description provided for @rfqExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get rfqExpired;

  /// No description provided for @rfqQuotesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 quotes} =1{1 quote} other{{count} quotes}}'**
  String rfqQuotesCount(int count);

  /// No description provided for @rfqQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'{quantity} {unit}'**
  String rfqQuantityLabel(int quantity, String unit);

  /// No description provided for @rfqNoDeliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'No delivery location added'**
  String get rfqNoDeliveryLocation;

  /// No description provided for @rfqLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get rfqLocation;

  /// No description provided for @rfqDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get rfqDelivery;

  /// No description provided for @rfqQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get rfqQuantity;

  /// No description provided for @rfqTargetPrice.
  ///
  /// In en, this message translates to:
  /// **'Target price'**
  String get rfqTargetPrice;

  /// No description provided for @rfqUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get rfqUnitPrice;

  /// No description provided for @rfqTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get rfqTotal;

  /// No description provided for @rfqShippingNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Shipping not specified'**
  String get rfqShippingNotSpecified;

  /// No description provided for @rfqShippingCost.
  ///
  /// In en, this message translates to:
  /// **'Shipping {amount}'**
  String rfqShippingCost(String amount);

  /// No description provided for @rfqAcceptQuotation.
  ///
  /// In en, this message translates to:
  /// **'Accept quotation'**
  String get rfqAcceptQuotation;

  /// No description provided for @rfqAcceptQuotationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Accept quotation?'**
  String get rfqAcceptQuotationQuestion;

  /// No description provided for @rfqAcceptQuotationMessage.
  ///
  /// In en, this message translates to:
  /// **'This will mark the selected supplier quotation as accepted and close the RFQ.'**
  String get rfqAcceptQuotationMessage;

  /// No description provided for @rfqReviewMore.
  ///
  /// In en, this message translates to:
  /// **'Review more'**
  String get rfqReviewMore;

  /// No description provided for @rfqAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get rfqAccept;

  /// No description provided for @rfqPostedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'RFQ posted successfully'**
  String get rfqPostedSuccessfully;

  /// No description provided for @rfqUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'RFQ updated successfully'**
  String get rfqUpdatedSuccessfully;

  /// No description provided for @rfqCancelledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'RFQ cancelled successfully'**
  String get rfqCancelledSuccessfully;

  /// No description provided for @rfqDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'RFQ deleted successfully'**
  String get rfqDeletedSuccessfully;

  /// No description provided for @rfqQuotationAcceptedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Quotation accepted successfully'**
  String get rfqQuotationAcceptedSuccessfully;

  /// No description provided for @rfqAiGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'AI requirements generated successfully'**
  String get rfqAiGeneratedSuccessfully;

  /// No description provided for @completeRetailerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Retailer Profile'**
  String get completeRetailerProfileTitle;

  /// No description provided for @completeRetailerProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide your business information to continue.'**
  String get completeRetailerProfileSubtitle;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enterStoreName.
  ///
  /// In en, this message translates to:
  /// **'Enter store name'**
  String get enterStoreName;

  /// No description provided for @enterStoreAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter store address'**
  String get enterStoreAddress;

  /// No description provided for @retailerProfileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Retailer profile saved successfully'**
  String get retailerProfileSavedSuccessfully;

  /// No description provided for @loadingCities.
  ///
  /// In en, this message translates to:
  /// **'Loading cities...'**
  String get loadingCities;

  /// No description provided for @noCitiesFoundForCountry.
  ///
  /// In en, this message translates to:
  /// **'No cities found for this country'**
  String get noCitiesFoundForCountry;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search city...'**
  String get searchCity;

  /// No description provided for @cityRequiredError.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get cityRequiredError;

  /// No description provided for @couldNotLoadCountries.
  ///
  /// In en, this message translates to:
  /// **'Could not load countries. Please try again.'**
  String get couldNotLoadCountries;

  /// No description provided for @couldNotLoadCities.
  ///
  /// In en, this message translates to:
  /// **'Could not load cities. Please try again.'**
  String get couldNotLoadCities;

  /// No description provided for @verifyNewEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify new email'**
  String get verifyNewEmail;

  /// No description provided for @sixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get sixDigitCode;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get verificationCodeSent;

  /// No description provided for @couldNotResendCode.
  ///
  /// In en, this message translates to:
  /// **'Could not resend code.'**
  String get couldNotResendCode;

  /// No description provided for @invalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code.'**
  String get invalidVerificationCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verifyPasswordChange.
  ///
  /// In en, this message translates to:
  /// **'Verify password change'**
  String get verifyPasswordChange;

  /// No description provided for @enterCodeSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {email}'**
  String enterCodeSentToEmail(String email);

  /// No description provided for @couldNotUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Could not update password.'**
  String get couldNotUpdatePassword;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequired;

  /// No description provided for @passwordNotUpdatedCodeNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Password was not updated because the verification code was not confirmed.'**
  String get passwordNotUpdatedCodeNotConfirmed;

  /// No description provided for @emailVerificationRequiredBeforeUpdating.
  ///
  /// In en, this message translates to:
  /// **'Email verification is required before updating the email.'**
  String get emailVerificationRequiredBeforeUpdating;

  /// No description provided for @emailNotUpdatedCodeNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Email was not updated because the verification code was not confirmed.'**
  String get emailNotUpdatedCodeNotConfirmed;

  /// No description provided for @rfqCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category is required'**
  String get rfqCategoryRequired;

  /// No description provided for @rfqSubcategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Subcategory is required'**
  String get rfqSubcategoryRequired;

  /// No description provided for @rfqUnitRequired.
  ///
  /// In en, this message translates to:
  /// **'Unit is required'**
  String get rfqUnitRequired;

  /// No description provided for @rfqTargetUnitPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter target unit price'**
  String get rfqTargetUnitPriceHint;

  /// No description provided for @rfqTargetUnitPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Target unit price is required'**
  String get rfqTargetUnitPriceRequired;

  /// No description provided for @rfqEnterValidTargetUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid target unit price'**
  String get rfqEnterValidTargetUnitPrice;

  /// No description provided for @rfqPreferredDeliveryTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Preferred delivery time is required'**
  String get rfqPreferredDeliveryTimeRequired;

  /// No description provided for @rfqDeadlineRequired.
  ///
  /// In en, this message translates to:
  /// **'Deadline date is required'**
  String get rfqDeadlineRequired;

  /// No description provided for @rfqCityRequired.
  ///
  /// In en, this message translates to:
  /// **'Delivery city is required'**
  String get rfqCityRequired;

  /// No description provided for @rfqDeliveryAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Delivery address is required'**
  String get rfqDeliveryAddressRequired;

  /// No description provided for @wholesaleOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Opportunities'**
  String get wholesaleOpportunities;

  /// No description provided for @bulkOrders.
  ///
  /// In en, this message translates to:
  /// **'Bulk Orders'**
  String get bulkOrders;

  /// No description provided for @bulkOrdersDescription.
  ///
  /// In en, this message translates to:
  /// **'Save more when ordering larger quantities from suppliers.'**
  String get bulkOrdersDescription;

  /// No description provided for @viewAvailableOffers.
  ///
  /// In en, this message translates to:
  /// **'View available offers'**
  String get viewAvailableOffers;

  /// No description provided for @groupDeliveryAvailable.
  ///
  /// In en, this message translates to:
  /// **'Group Delivery Available'**
  String get groupDeliveryAvailable;

  /// No description provided for @groupDeliveryDescription.
  ///
  /// In en, this message translates to:
  /// **'Join other retailers in your area and save on shipping costs.'**
  String get groupDeliveryDescription;

  /// No description provided for @groupDeliveryDynamicDescription.
  ///
  /// In en, this message translates to:
  /// **'{retailersJoined} retailers joined nearby. Save up to {savingsPercent}% on shipping costs.'**
  String groupDeliveryDynamicDescription(
    int retailersJoined,
    num savingsPercent,
  );

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccessfully;

  /// No description provided for @stockAssignedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Stock assigned successfully'**
  String get stockAssignedSuccessfully;

  /// No description provided for @stockUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Stock updated successfully'**
  String get stockUpdatedSuccessfully;

  /// No description provided for @inventoryItemRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Inventory item removed successfully'**
  String get inventoryItemRemovedSuccessfully;

  /// No description provided for @categoryAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get categoryAddedSuccessfully;

  /// No description provided for @categoryUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccessfully;

  /// No description provided for @categoryStatusUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category status updated successfully'**
  String get categoryStatusUpdatedSuccessfully;

  /// No description provided for @categoryDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get categoryDeletedSuccessfully;

  /// No description provided for @subCategoryAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Subcategory added successfully'**
  String get subCategoryAddedSuccessfully;

  /// No description provided for @subCategoryUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Subcategory updated successfully'**
  String get subCategoryUpdatedSuccessfully;

  /// No description provided for @subCategoryStatusUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Subcategory status updated successfully'**
  String get subCategoryStatusUpdatedSuccessfully;

  /// No description provided for @subCategoryDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Subcategory deleted successfully'**
  String get subCategoryDeletedSuccessfully;

  /// No description provided for @branchDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Branch deleted successfully'**
  String get branchDeletedSuccessfully;

  /// No description provided for @productAssignedToBranchSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product assigned to branch successfully'**
  String get productAssignedToBranchSuccessfully;

  /// No description provided for @orderUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order updated successfully'**
  String get orderUpdatedSuccessfully;

  /// No description provided for @orderMarkedAsStatus.
  ///
  /// In en, this message translates to:
  /// **'Order marked as {status}'**
  String orderMarkedAsStatus(String status);

  /// No description provided for @paymentCashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get paymentCashOnDelivery;

  /// No description provided for @paymentCard.
  ///
  /// In en, this message translates to:
  /// **'Card payment'**
  String get paymentCard;

  /// No description provided for @paymentBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get paymentBankTransfer;

  /// No description provided for @verifyPhoneChange.
  ///
  /// In en, this message translates to:
  /// **'Verify phone number change'**
  String get verifyPhoneChange;

  /// No description provided for @enterStaticPhoneCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to {phoneNumber}'**
  String enterStaticPhoneCode(String phoneNumber);

  /// No description provided for @staticPhoneCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Phone verification code sent'**
  String get staticPhoneCodeSent;

  /// No description provided for @invalidPhoneVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone verification code.'**
  String get invalidPhoneVerificationCode;

  /// No description provided for @phoneNotUpdatedCodeNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Phone number was not updated because the verification code was not confirmed.'**
  String get phoneNotUpdatedCodeNotConfirmed;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @paymentMethodsHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment methods offered to retailers'**
  String get paymentMethodsHeaderTitle;

  /// No description provided for @paymentMethodsHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable the methods retailers can choose at checkout. Cash is fully ready; Stripe requires credentials setup first.'**
  String get paymentMethodsHeaderSubtitle;

  /// No description provided for @paymentMethodEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get paymentMethodEnabled;

  /// No description provided for @paymentMethodDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get paymentMethodDisabled;

  /// No description provided for @paymentMethodComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get paymentMethodComingSoon;

  /// No description provided for @paymentMethodCredentialsRequired.
  ///
  /// In en, this message translates to:
  /// **'Credentials required'**
  String get paymentMethodCredentialsRequired;

  /// No description provided for @paymentMethodsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payment methods are available yet.'**
  String get paymentMethodsEmpty;

  /// No description provided for @paymentMethodConfigureStripe.
  ///
  /// In en, this message translates to:
  /// **'Configure Stripe'**
  String get paymentMethodConfigureStripe;

  /// No description provided for @paymentMethodEditStripe.
  ///
  /// In en, this message translates to:
  /// **'Edit Stripe Settings'**
  String get paymentMethodEditStripe;

  /// No description provided for @stripeConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure Stripe'**
  String get stripeConfigTitle;

  /// No description provided for @stripeInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Keys are stored securely on the server and never exposed to retailers. Use test keys now and switch to live keys before going live.'**
  String get stripeInfoBanner;

  /// No description provided for @stripeEnableLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable Stripe for retailers'**
  String get stripeEnableLabel;

  /// No description provided for @stripeEnableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Retailers will be able to choose card payment via Stripe at checkout.'**
  String get stripeEnableSubtitle;

  /// No description provided for @stripeCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get stripeCredentialsTitle;

  /// No description provided for @stripeSecretKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Secret Key'**
  String get stripeSecretKeyLabel;

  /// No description provided for @stripeSecretKeyHelper.
  ///
  /// In en, this message translates to:
  /// **'Server-side key — never share this with anyone.'**
  String get stripeSecretKeyHelper;

  /// No description provided for @stripeSecretKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Secret key is required.'**
  String get stripeSecretKeyRequired;

  /// No description provided for @stripeSecretKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Must start with sk_'**
  String get stripeSecretKeyInvalid;

  /// No description provided for @stripePublishableKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Publishable Key'**
  String get stripePublishableKeyLabel;

  /// No description provided for @stripePublishableKeyHelper.
  ///
  /// In en, this message translates to:
  /// **'Sent to the app to complete the payment flow.'**
  String get stripePublishableKeyHelper;

  /// No description provided for @stripePublishableKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Publishable key is required.'**
  String get stripePublishableKeyRequired;

  /// No description provided for @stripePublishableKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Must start with pk_'**
  String get stripePublishableKeyInvalid;

  /// No description provided for @stripeWebhookSecretLabel.
  ///
  /// In en, this message translates to:
  /// **'Webhook Secret (optional)'**
  String get stripeWebhookSecretLabel;

  /// No description provided for @stripeWebhookSecretHelper.
  ///
  /// In en, this message translates to:
  /// **'Required later to receive payment confirmations from Stripe.'**
  String get stripeWebhookSecretHelper;

  /// No description provided for @stripeTestButton.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get stripeTestButton;

  /// No description provided for @stripeTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get stripeTesting;

  /// No description provided for @stripeSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get stripeSaveButton;

  /// No description provided for @stripeSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get stripeSaving;

  /// No description provided for @stripeConfigSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Stripe configuration saved successfully.'**
  String get stripeConfigSavedSuccessfully;

  /// No description provided for @paymentMethodConfigurePayPal.
  ///
  /// In en, this message translates to:
  /// **'Configure PayPal'**
  String get paymentMethodConfigurePayPal;

  /// No description provided for @paymentMethodEditPayPal.
  ///
  /// In en, this message translates to:
  /// **'Edit PayPal Settings'**
  String get paymentMethodEditPayPal;

  /// No description provided for @payPalConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure PayPal'**
  String get payPalConfigTitle;

  /// No description provided for @payPalInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'PayPal is prepared for checkout, but real sandbox testing requires PayPal Developer credentials. If PayPal is not available in your country, keep it disabled or use credentials provided by the doctor.'**
  String get payPalInfoBanner;

  /// No description provided for @payPalEnableLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable PayPal for retailers'**
  String get payPalEnableLabel;

  /// No description provided for @payPalEnableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Retailers will be able to choose PayPal at checkout once credentials are valid.'**
  String get payPalEnableSubtitle;

  /// No description provided for @payPalCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get payPalCredentialsTitle;

  /// No description provided for @payPalModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get payPalModeLabel;

  /// No description provided for @payPalModeSandbox.
  ///
  /// In en, this message translates to:
  /// **'Sandbox'**
  String get payPalModeSandbox;

  /// No description provided for @payPalModeLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get payPalModeLive;

  /// No description provided for @payPalModeHelper.
  ///
  /// In en, this message translates to:
  /// **'Use Sandbox for testing and Live only before production.'**
  String get payPalModeHelper;

  /// No description provided for @payPalClientIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get payPalClientIdLabel;

  /// No description provided for @payPalClientIdHint.
  ///
  /// In en, this message translates to:
  /// **'PayPal sandbox client ID'**
  String get payPalClientIdHint;

  /// No description provided for @payPalClientIdHelper.
  ///
  /// In en, this message translates to:
  /// **'Create it from PayPal Developer Dashboard > Apps & Credentials.'**
  String get payPalClientIdHelper;

  /// No description provided for @payPalClientIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Client ID is required.'**
  String get payPalClientIdRequired;

  /// No description provided for @payPalClientSecretLabel.
  ///
  /// In en, this message translates to:
  /// **'Client Secret'**
  String get payPalClientSecretLabel;

  /// No description provided for @payPalClientSecretHint.
  ///
  /// In en, this message translates to:
  /// **'PayPal sandbox client secret'**
  String get payPalClientSecretHint;

  /// No description provided for @payPalClientSecretHelper.
  ///
  /// In en, this message translates to:
  /// **'Server-side secret. Do not share it or commit it.'**
  String get payPalClientSecretHelper;

  /// No description provided for @payPalClientSecretRequired.
  ///
  /// In en, this message translates to:
  /// **'Client secret is required.'**
  String get payPalClientSecretRequired;

  /// No description provided for @payPalReturnUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Return URL'**
  String get payPalReturnUrlLabel;

  /// No description provided for @payPalReturnUrlHelper.
  ///
  /// In en, this message translates to:
  /// **'For testing you can keep https://example.com/paypal/return.'**
  String get payPalReturnUrlHelper;

  /// No description provided for @payPalCancelUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel URL'**
  String get payPalCancelUrlLabel;

  /// No description provided for @payPalCancelUrlHelper.
  ///
  /// In en, this message translates to:
  /// **'For testing you can keep https://example.com/paypal/cancel.'**
  String get payPalCancelUrlHelper;

  /// No description provided for @payPalBrandNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand Name'**
  String get payPalBrandNameLabel;

  /// No description provided for @payPalBrandNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional name shown during PayPal checkout.'**
  String get payPalBrandNameHelper;

  /// No description provided for @payPalUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'URL is required.'**
  String get payPalUrlRequired;

  /// No description provided for @payPalUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL.'**
  String get payPalUrlInvalid;

  /// No description provided for @payPalTestButton.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get payPalTestButton;

  /// No description provided for @payPalTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get payPalTesting;

  /// No description provided for @payPalSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get payPalSaveButton;

  /// No description provided for @payPalSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get payPalSaving;

  /// No description provided for @paymentMethodConfigureCard.
  ///
  /// In en, this message translates to:
  /// **'Configure Credit / Debit Card'**
  String get paymentMethodConfigureCard;

  /// No description provided for @paymentMethodEditCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card Settings'**
  String get paymentMethodEditCard;

  /// No description provided for @paymentMethodCreditDebitCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Credit / Debit Card (Visa / Mastercard)'**
  String get paymentMethodCreditDebitCardTitle;

  /// No description provided for @mpgsConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure Credit / Debit Card'**
  String get mpgsConfigTitle;

  /// No description provided for @mpgsInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Configure MPGS hosted checkout for Visa and Mastercard payments. Retailers will use this through checkout when they select Credit / Debit Card.'**
  String get mpgsInfoBanner;

  /// No description provided for @mpgsEnableLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable Credit / Debit Card for retailers'**
  String get mpgsEnableLabel;

  /// No description provided for @mpgsEnableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Retailers will be able to pay by Visa or Mastercard through hosted checkout.'**
  String get mpgsEnableSubtitle;

  /// No description provided for @mpgsCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Gateway Credentials'**
  String get mpgsCredentialsTitle;

  /// No description provided for @mpgsModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mpgsModeLabel;

  /// No description provided for @mpgsModeTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get mpgsModeTest;

  /// No description provided for @mpgsModeLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get mpgsModeLive;

  /// No description provided for @mpgsModeHelper.
  ///
  /// In en, this message translates to:
  /// **'Use Test for sandbox credentials and Live only before production.'**
  String get mpgsModeHelper;

  /// No description provided for @mpgsMerchantIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Merchant ID'**
  String get mpgsMerchantIdLabel;

  /// No description provided for @mpgsMerchantIdHint.
  ///
  /// In en, this message translates to:
  /// **'MPGS merchant ID'**
  String get mpgsMerchantIdHint;

  /// No description provided for @mpgsMerchantIdHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the merchant ID provided by the doctor or acquiring bank.'**
  String get mpgsMerchantIdHelper;

  /// No description provided for @mpgsMerchantIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Merchant ID is required.'**
  String get mpgsMerchantIdRequired;

  /// No description provided for @mpgsApiPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'API Password'**
  String get mpgsApiPasswordLabel;

  /// No description provided for @mpgsApiPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'MPGS API password'**
  String get mpgsApiPasswordHint;

  /// No description provided for @mpgsApiPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'Server-side gateway password. Do not share it or commit it.'**
  String get mpgsApiPasswordHelper;

  /// No description provided for @mpgsApiPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'API password is required.'**
  String get mpgsApiPasswordRequired;

  /// No description provided for @mpgsApiBaseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'API Base URL'**
  String get mpgsApiBaseUrlLabel;

  /// No description provided for @mpgsApiBaseUrlHelper.
  ///
  /// In en, this message translates to:
  /// **'For testing, use https://test-bobsal.gateway.mastercard.com.'**
  String get mpgsApiBaseUrlHelper;

  /// No description provided for @mpgsCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get mpgsCurrencyLabel;

  /// No description provided for @mpgsCurrencyHelper.
  ///
  /// In en, this message translates to:
  /// **'Use a 3-letter ISO code such as USD.'**
  String get mpgsCurrencyHelper;

  /// No description provided for @mpgsCurrencyRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 3-letter currency code.'**
  String get mpgsCurrencyRequired;

  /// No description provided for @mpgsReturnUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Return URL'**
  String get mpgsReturnUrlLabel;

  /// No description provided for @mpgsReturnUrlHelper.
  ///
  /// In en, this message translates to:
  /// **'For local testing, keep http://localhost:8083/api/public/mpgs/return.'**
  String get mpgsReturnUrlHelper;

  /// No description provided for @mpgsBrandNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand Name'**
  String get mpgsBrandNameLabel;

  /// No description provided for @mpgsBrandNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional name shown on the hosted checkout page.'**
  String get mpgsBrandNameHelper;

  /// No description provided for @mpgsUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'URL is required.'**
  String get mpgsUrlRequired;

  /// No description provided for @mpgsUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL.'**
  String get mpgsUrlInvalid;

  /// No description provided for @mpgsTestButton.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get mpgsTestButton;

  /// No description provided for @mpgsTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get mpgsTesting;

  /// No description provided for @mpgsSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get mpgsSaveButton;

  /// No description provided for @mpgsSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get mpgsSaving;
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

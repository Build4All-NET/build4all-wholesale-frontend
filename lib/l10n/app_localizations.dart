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
  /// **'A password verification code was sent to your email.'**
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

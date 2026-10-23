import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Padmashali Vidya Sethu'**
  String get appTitle;

  /// No description provided for @sponsoredBy.
  ///
  /// In en, this message translates to:
  /// **'Sponsored by:'**
  String get sponsoredBy;

  /// No description provided for @poweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by'**
  String get poweredBy;

  /// No description provided for @technologyPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Technology Powered by'**
  String get technologyPoweredBy;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Connecting Our Young Padmashalis for a Brighter Future'**
  String get appTagline;

  /// No description provided for @organisationName.
  ///
  /// In en, this message translates to:
  /// **'D K Jilla Padmashali Vidyavardhaka Sangha (R), Udupi'**
  String get organisationName;

  /// No description provided for @welcomeHeading.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeHeading;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Create your education and career profile with the D. K. Jilla Padmashali Vidyavardhaka Sangha (R), Udupi. Registration takes only a few minutes — you can complete the rest of your profile later.'**
  String get welcomeBody;

  /// No description provided for @welcomeFeatureEducation.
  ///
  /// In en, this message translates to:
  /// **'Education & achievements'**
  String get welcomeFeatureEducation;

  /// No description provided for @welcomeFeatureCareer.
  ///
  /// In en, this message translates to:
  /// **'Skills & career guidance'**
  String get welcomeFeatureCareer;

  /// No description provided for @welcomeFeatureOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Scholarships & opportunities'**
  String get welcomeFeatureOpportunities;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @phoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneTitle;

  /// No description provided for @phoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number. We will send a 4-digit Phone Number Verification Code to it.'**
  String get phoneSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get phoneHint;

  /// No description provided for @phoneFamilyNote.
  ///
  /// In en, this message translates to:
  /// **'Parents can use their own mobile number to register their children. One number can register several family members.'**
  String get phoneFamilyNote;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendVerificationCode;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your mobile number.'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number.'**
  String get phoneInvalid;

  /// No description provided for @phoneInvalidInternational.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number for the selected country code.'**
  String get phoneInvalidInternational;

  /// No description provided for @phoneHintInternational.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get phoneHintInternational;

  /// No description provided for @codeViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Outside India, the verification code is sent to this number on WhatsApp.'**
  String get codeViaWhatsApp;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get emailInvalid;

  /// No description provided for @memberEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address (optional)'**
  String get memberEmailLabel;

  /// No description provided for @memberEmailHelp.
  ///
  /// In en, this message translates to:
  /// **'If you add an email address, we will send a separate code to it to confirm it.'**
  String get memberEmailHelp;

  /// No description provided for @memberEmailCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code sent to {email}.'**
  String memberEmailCodeSent(String email);

  /// No description provided for @memberEmailNeedsVerification.
  ///
  /// In en, this message translates to:
  /// **'Verify this email address, or leave it empty.'**
  String get memberEmailNeedsVerification;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Number Verification'**
  String get verifyTitle;

  /// No description provided for @verifyInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit Phone Number Verification Code sent to {number}.'**
  String verifyInstruction(String number);

  /// No description provided for @codeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'4-digit Phone Number Verification Code'**
  String get codeFieldLabel;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds} s'**
  String resendIn(int seconds);

  /// No description provided for @changeMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Change Mobile Number'**
  String get changeMobileNumber;

  /// No description provided for @codeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 4 digits of the verification code.'**
  String get codeIncomplete;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'A new verification code has been sent.'**
  String get codeResent;

  /// No description provided for @developmentCodeBanner.
  ///
  /// In en, this message translates to:
  /// **'Development mode: your verification code is {code}'**
  String developmentCodeBanner(String code);

  /// No description provided for @registrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registrationTitle;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @stepPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get stepPersonal;

  /// No description provided for @stepStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get stepStatus;

  /// No description provided for @stepCommunity.
  ///
  /// In en, this message translates to:
  /// **'Temple & Organisation'**
  String get stepCommunity;

  /// No description provided for @stepAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get stepAddress;

  /// No description provided for @stepDisability.
  ///
  /// In en, this message translates to:
  /// **'Disability Information'**
  String get stepDisability;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get completeRegistration;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father Name'**
  String get fatherName;

  /// No description provided for @motherName.
  ///
  /// In en, this message translates to:
  /// **'Mother Name'**
  String get motherName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'Age: {age} years'**
  String ageYears(int age);

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// No description provided for @currentStatusHelp.
  ///
  /// In en, this message translates to:
  /// **'What are you doing at present?'**
  String get currentStatusHelp;

  /// No description provided for @classStudying.
  ///
  /// In en, this message translates to:
  /// **'Class Studying'**
  String get classStudying;

  /// No description provided for @highestEducation.
  ///
  /// In en, this message translates to:
  /// **'Highest Education'**
  String get highestEducation;

  /// No description provided for @temple.
  ///
  /// In en, this message translates to:
  /// **'Temple'**
  String get temple;

  /// No description provided for @templeHelp.
  ///
  /// In en, this message translates to:
  /// **'Select the Padmashali temple your family belongs to.'**
  String get templeHelp;

  /// No description provided for @organisationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you linked to any Padmashali Organisation?'**
  String get organisationQuestion;

  /// No description provided for @organisationLabel.
  ///
  /// In en, this message translates to:
  /// **'Organisation'**
  String get organisationLabel;

  /// No description provided for @leaveRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave registration?'**
  String get leaveRegistrationTitle;

  /// No description provided for @leaveRegistrationBody.
  ///
  /// In en, this message translates to:
  /// **'The details you have entered will not be saved.'**
  String get leaveRegistrationBody;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @permanentAddress.
  ///
  /// In en, this message translates to:
  /// **'Permanent Address'**
  String get permanentAddress;

  /// No description provided for @currentAddress.
  ///
  /// In en, this message translates to:
  /// **'Current Address'**
  String get currentAddress;

  /// No description provided for @sameAsPermanent.
  ///
  /// In en, this message translates to:
  /// **'Current address is same as Permanent Address'**
  String get sameAsPermanent;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'House / Building / Street'**
  String get addressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Area / Landmark (optional)'**
  String get addressLine2;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'PIN Code'**
  String get pinCode;

  /// No description provided for @pinCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'City, district and state are filled in automatically.'**
  String get pinCodeHelp;

  /// No description provided for @lookingUpPin.
  ///
  /// In en, this message translates to:
  /// **'Finding PIN code details…'**
  String get lookingUpPin;

  /// No description provided for @pinNotFound.
  ///
  /// In en, this message translates to:
  /// **'We could not find this PIN code. Please check it, or select the state and district below.'**
  String get pinNotFound;

  /// No description provided for @cityVillage.
  ///
  /// In en, this message translates to:
  /// **'City / Village'**
  String get cityVillage;

  /// No description provided for @cityVillageHelp.
  ///
  /// In en, this message translates to:
  /// **'Places under this PIN code'**
  String get cityVillageHelp;

  /// No description provided for @cityNotListed.
  ///
  /// In en, this message translates to:
  /// **'My place is not listed'**
  String get cityNotListed;

  /// No description provided for @taluk.
  ///
  /// In en, this message translates to:
  /// **'Taluk'**
  String get taluk;

  /// No description provided for @talukNotListed.
  ///
  /// In en, this message translates to:
  /// **'My taluk is not listed'**
  String get talukNotListed;

  /// No description provided for @talukName.
  ///
  /// In en, this message translates to:
  /// **'Taluk Name'**
  String get talukName;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @countryHelp.
  ///
  /// In en, this message translates to:
  /// **'Select the country first. For India, the PIN code fills in the rest.'**
  String get countryHelp;

  /// No description provided for @cityTown.
  ///
  /// In en, this message translates to:
  /// **'City / Town'**
  String get cityTown;

  /// No description provided for @stateProvince.
  ///
  /// In en, this message translates to:
  /// **'State / Province / Region'**
  String get stateProvince;

  /// No description provided for @stateNotListed.
  ///
  /// In en, this message translates to:
  /// **'My state / province is not listed'**
  String get stateNotListed;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code (optional)'**
  String get postalCode;

  /// No description provided for @isDisabled.
  ///
  /// In en, this message translates to:
  /// **'Is Disabled?'**
  String get isDisabled;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @typeOfDisability.
  ///
  /// In en, this message translates to:
  /// **'Type of Disability'**
  String get typeOfDisability;

  /// No description provided for @typeOfDisabilityHelp.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply.'**
  String get typeOfDisabilityHelp;

  /// No description provided for @pleaseSpecify.
  ///
  /// In en, this message translates to:
  /// **'Please Specify'**
  String get pleaseSpecify;

  /// No description provided for @disabilityPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'This information is kept confidential. It is used only to plan support and accessibility for programs.'**
  String get disabilityPrivacyNote;

  /// No description provided for @consentHeading.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get consentHeading;

  /// No description provided for @privacyAgree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the Privacy Policy and the Terms and Conditions.'**
  String get privacyAgree;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @agreeByContinuing.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms and Conditions and Privacy Policy.'**
  String get agreeByContinuing;

  /// No description provided for @legalLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String legalLastUpdated(String date);

  /// No description provided for @legalDraftNote.
  ///
  /// In en, this message translates to:
  /// **'Draft - this text is being reviewed and may change before the app is published.'**
  String get legalDraftNote;

  /// No description provided for @guardianConsent.
  ///
  /// In en, this message translates to:
  /// **'I am the parent or guardian of this member and I consent to this registration.'**
  String get guardianConsent;

  /// No description provided for @registrationSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful!'**
  String get registrationSuccessTitle;

  /// No description provided for @studentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get studentIdLabel;

  /// No description provided for @registrationIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration ID'**
  String get registrationIdLabel;

  /// No description provided for @welcomeToPvs.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Padmashali Vidya Sethu.'**
  String get welcomeToPvs;

  /// No description provided for @basicProfileCreated.
  ///
  /// In en, this message translates to:
  /// **'Your basic profile has been created.'**
  String get basicProfileCreated;

  /// No description provided for @continueToProfile.
  ///
  /// In en, this message translates to:
  /// **'Continue to My Profile'**
  String get continueToProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your profile up to date so the Sangha can connect you with the right opportunities.'**
  String get homeSubtitle;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @profileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile Completion'**
  String get profileCompletion;

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String percentComplete(int percent);

  /// No description provided for @statusComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get statusComplete;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String statusInProgress(int percent);

  /// No description provided for @statusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get statusNotStarted;

  /// No description provided for @statusNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'Not Applicable'**
  String get statusNotApplicable;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @sectionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This section will be available in an upcoming update.'**
  String get sectionComingSoon;

  /// No description provided for @quickLinks.
  ///
  /// In en, this message translates to:
  /// **'Quick Links'**
  String get quickLinks;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @addFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Add Family Member'**
  String get addFamilyMember;

  /// No description provided for @switchMember.
  ///
  /// In en, this message translates to:
  /// **'Switch Member'**
  String get switchMember;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out of Padmashali Vidya Sethu on this device?'**
  String get signOutConfirm;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountIntro.
  ///
  /// In en, this message translates to:
  /// **'You can delete your Padmashali Vidya Sethu account. Please read what this means:'**
  String get deleteAccountIntro;

  /// No description provided for @deleteAccountPointMembers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Your account is closed.} =1{Your account and the 1 member registered with it are closed.} other{Your account and the {count} members registered with it are closed.}}'**
  String deleteAccountPointMembers(int count);

  /// No description provided for @deleteAccountPointNumber.
  ///
  /// In en, this message translates to:
  /// **'This mobile number cannot sign in or register again.'**
  String get deleteAccountPointNumber;

  /// No description provided for @deleteAccountPointRecords.
  ///
  /// In en, this message translates to:
  /// **'The information you gave is kept in the Sangha\'s records, marked as deleted. It is no longer shown in the app.'**
  String get deleteAccountPointRecords;

  /// No description provided for @deleteAccountPointSignOut.
  ///
  /// In en, this message translates to:
  /// **'You are signed out on this device.'**
  String get deleteAccountPointSignOut;

  /// No description provided for @deleteAccountUnderstood.
  ///
  /// In en, this message translates to:
  /// **'I understand that this cannot be undone.'**
  String get deleteAccountUnderstood;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Your account will be deleted and this mobile number cannot be used to register again.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @accountDeletedNote.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeletedNote;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Updates from the Sangha will appear here.'**
  String get noAnnouncements;

  /// No description provided for @opportunities.
  ///
  /// In en, this message translates to:
  /// **'Opportunities for You'**
  String get opportunities;

  /// No description provided for @noOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Scholarships, training and jobs that match your profile will appear here.'**
  String get noOpportunities;

  /// No description provided for @upcomingPrograms.
  ///
  /// In en, this message translates to:
  /// **'Upcoming PVS Programs'**
  String get upcomingPrograms;

  /// No description provided for @noPrograms.
  ///
  /// In en, this message translates to:
  /// **'No upcoming programs right now.'**
  String get noPrograms;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @educationStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status & Education'**
  String get educationStatus;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Temple & Organisation'**
  String get community;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @disabilityInformation.
  ///
  /// In en, this message translates to:
  /// **'Disability Information'**
  String get disabilityInformation;

  /// No description provided for @notApplicableShort.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get notApplicableShort;

  /// No description provided for @registeredOn.
  ///
  /// In en, this message translates to:
  /// **'Registered on {date}'**
  String registeredOn(String date);

  /// No description provided for @dataCorrectionNote.
  ///
  /// In en, this message translates to:
  /// **'To correct any of this information, please contact the Sangha office. Online editing will be available soon.'**
  String get dataCorrectionNote;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequired;

  /// No description provided for @validationSelect.
  ///
  /// In en, this message translates to:
  /// **'Please make a selection.'**
  String get validationSelect;

  /// No description provided for @validationNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least 2 characters.'**
  String get validationNameTooShort;

  /// No description provided for @validationNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use letters, spaces, dots and hyphens only.'**
  String get validationNameInvalid;

  /// No description provided for @validationAddressTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please enter a complete address.'**
  String get validationAddressTooShort;

  /// No description provided for @validationPinInvalid.
  ///
  /// In en, this message translates to:
  /// **'PIN code must be exactly 6 digits.'**
  String get validationPinInvalid;

  /// No description provided for @validationPostalCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please check the postal code.'**
  String get validationPostalCodeInvalid;

  /// No description provided for @validationDobRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select the date of birth.'**
  String get validationDobRequired;

  /// No description provided for @validationMinAge.
  ///
  /// In en, this message translates to:
  /// **'Members must be at least {age} years old.'**
  String validationMinAge(int age);

  /// No description provided for @validationDisabilityType.
  ///
  /// In en, this message translates to:
  /// **'Please select the type of disability.'**
  String get validationDisabilityType;

  /// No description provided for @validationPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Please accept the privacy policy to continue.'**
  String get validationPrivacy;

  /// No description provided for @validationGuardian.
  ///
  /// In en, this message translates to:
  /// **'Parent or guardian consent is required for members under 18.'**
  String get validationGuardian;

  /// No description provided for @fixHighlightedFields.
  ///
  /// In en, this message translates to:
  /// **'Please correct the highlighted fields.'**
  String get fixHighlightedFields;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the server. Please check your internet connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'A new version of Padmashali Vidya Sethu is available. Please update the app to continue.'**
  String get updateRequiredBody;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available.'**
  String get updateAvailable;

  /// No description provided for @updateVersions.
  ///
  /// In en, this message translates to:
  /// **'Your version: {installed}   Latest: {latest}'**
  String updateVersions(String installed, String latest);

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @updateStoreHint.
  ///
  /// In en, this message translates to:
  /// **'Open the Play Store or App Store and update Padmashali Vidya Sethu.'**
  String get updateStoreHint;

  /// No description provided for @updateCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get updateCheckAgain;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @memberMobileLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number (optional)'**
  String get memberMobileLabel;

  /// No description provided for @memberMobileHelp.
  ///
  /// In en, this message translates to:
  /// **'If this person has their own mobile number, add it. We will send a verification code to it.'**
  String get memberMobileHelp;

  /// No description provided for @memberMobileVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get memberMobileVerify;

  /// No description provided for @memberMobileCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code sent to {number}.'**
  String memberMobileCodeSent(String number);

  /// No description provided for @memberMobileVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get memberMobileVerified;

  /// No description provided for @memberMobileNeedsVerification.
  ///
  /// In en, this message translates to:
  /// **'Verify this mobile number, or leave it empty.'**
  String get memberMobileNeedsVerification;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

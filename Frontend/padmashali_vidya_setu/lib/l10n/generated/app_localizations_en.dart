// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Padmashali Vidya Sethu';

  @override
  String get sponsoredBy => 'Sponsored by:';

  @override
  String get poweredBy => 'Powered by';

  @override
  String get appTagline =>
      'Connecting Our Young Padmashalis for a Brighter Future';

  @override
  String get organisationName =>
      'D K Jilla Padmashali Vidyavardhaka Sangha (R), Udupi';

  @override
  String get welcomeHeading => 'Welcome';

  @override
  String get welcomeBody =>
      'Create your education and career profile with the D. K. Jilla Padmashali Vidyavardhaka Sangha (R), Udupi. Registration takes only a few minutes — you can complete the rest of your profile later.';

  @override
  String get welcomeFeatureEducation => 'Education & achievements';

  @override
  String get welcomeFeatureCareer => 'Skills & career guidance';

  @override
  String get welcomeFeatureOpportunities => 'Scholarships & opportunities';

  @override
  String get getStarted => 'Get Started';

  @override
  String get phoneTitle => 'Phone Number';

  @override
  String get phoneSubtitle =>
      'Enter your mobile number. We will send a 4-digit Phone Number Verification Code to it.';

  @override
  String get phoneLabel => 'Mobile Number';

  @override
  String get phoneHint => '10-digit mobile number';

  @override
  String get phoneFamilyNote =>
      'Parents can use their own mobile number to register their children. One number can register several family members.';

  @override
  String get sendVerificationCode => 'Send Verification Code';

  @override
  String get phoneRequired => 'Please enter your mobile number.';

  @override
  String get phoneInvalid => 'Please enter a valid 10-digit mobile number.';

  @override
  String get verifyTitle => 'Phone Number Verification';

  @override
  String verifyInstruction(String number) {
    return 'Enter the 4-digit Phone Number Verification Code sent to $number.';
  }

  @override
  String get codeFieldLabel => '4-digit Phone Number Verification Code';

  @override
  String get verifyButton => 'Verify';

  @override
  String get resendCode => 'Resend Code';

  @override
  String resendIn(int seconds) {
    return 'Resend code in $seconds s';
  }

  @override
  String get changeMobileNumber => 'Change Mobile Number';

  @override
  String get codeIncomplete =>
      'Please enter all 4 digits of the verification code.';

  @override
  String get codeResent => 'A new verification code has been sent.';

  @override
  String developmentCodeBanner(String code) {
    return 'Development mode: your verification code is $code';
  }

  @override
  String get registrationTitle => 'Registration';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get stepPersonal => 'Personal Details';

  @override
  String get stepStatus => 'Current Status';

  @override
  String get stepCommunity => 'Temple & Organisation';

  @override
  String get stepAddress => 'Address';

  @override
  String get stepDisability => 'Disability Information';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get completeRegistration => 'Complete Registration';

  @override
  String get fullName => 'Full Name';

  @override
  String get fatherName => 'Father Name';

  @override
  String get motherName => 'Mother Name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get selectDateOfBirth => 'Select date of birth';

  @override
  String ageYears(int age) {
    return 'Age: $age years';
  }

  @override
  String get gender => 'Gender';

  @override
  String get age => 'Age';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get currentStatusHelp => 'What are you doing at present?';

  @override
  String get classStudying => 'Class Studying';

  @override
  String get highestEducation => 'Highest Education';

  @override
  String get temple => 'Temple';

  @override
  String get templeHelp =>
      'Select the Padmashali temple your family belongs to.';

  @override
  String get organisationQuestion =>
      'Are you linked to any Padmashali Organisation?';

  @override
  String get organisationLabel => 'Organisation';

  @override
  String get leaveRegistrationTitle => 'Leave registration?';

  @override
  String get leaveRegistrationBody =>
      'The details you have entered will not be saved.';

  @override
  String get leave => 'Leave';

  @override
  String get permanentAddress => 'Permanent Address';

  @override
  String get currentAddress => 'Current Address';

  @override
  String get sameAsPermanent => 'Current address is same as Permanent Address';

  @override
  String get addressLine1 => 'House / Building / Street';

  @override
  String get addressLine2 => 'Area / Landmark (optional)';

  @override
  String get pinCode => 'PIN Code';

  @override
  String get pinCodeHelp =>
      'City, district and state are filled in automatically.';

  @override
  String get lookingUpPin => 'Finding PIN code details…';

  @override
  String get pinNotFound =>
      'We could not find this PIN code. Please check it, or select the state and district below.';

  @override
  String get cityVillage => 'City / Village';

  @override
  String get cityVillageHelp => 'Places under this PIN code';

  @override
  String get cityNotListed => 'My place is not listed';

  @override
  String get taluk => 'Taluk';

  @override
  String get talukNotListed => 'My taluk is not listed';

  @override
  String get talukName => 'Taluk Name';

  @override
  String get district => 'District';

  @override
  String get state => 'State';

  @override
  String get country => 'Country';

  @override
  String get isDisabled => 'Is Disabled?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get typeOfDisability => 'Type of Disability';

  @override
  String get typeOfDisabilityHelp => 'Select all that apply.';

  @override
  String get pleaseSpecify => 'Please Specify';

  @override
  String get disabilityPrivacyNote =>
      'This information is kept confidential. It is used only to plan support and accessibility for programs.';

  @override
  String get consentHeading => 'Consent';

  @override
  String get privacyAgree => 'I have read and agree to the Privacy Policy.';

  @override
  String get viewPrivacyPolicy => 'View Privacy Policy';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyBody =>
      'This is a placeholder. The D. K. Jilla Padmashali Vidyavardhaka Sangha (R), Udupi will publish the final privacy policy here.\n\nSummary of current practice:\n• We collect only the information needed for education, career and support programs.\n• Information is never shown in any public directory.\n• Disability information is visible only to you and specifically authorised Sangha staff.\n• You can ask the Sangha to correct or delete your information.\n• Communication from the Sangha will be sent only on the channels and topics you choose.';

  @override
  String get guardianConsent =>
      'I am the parent or guardian of this member and I consent to this registration.';

  @override
  String get registrationSuccessTitle => 'Registration Successful!';

  @override
  String get studentIdLabel => 'Student ID';

  @override
  String get registrationIdLabel => 'Registration ID';

  @override
  String get welcomeToPvs => 'Welcome to Padmashali Vidya Sethu.';

  @override
  String get basicProfileCreated => 'Your basic profile has been created.';

  @override
  String get continueToProfile => 'Continue to My Profile';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeSubtitle =>
      'Keep your profile up to date so the Sangha can connect you with the right opportunities.';

  @override
  String get yourProfile => 'Your Profile';

  @override
  String get profileCompletion => 'Profile Completion';

  @override
  String percentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String get statusComplete => 'Complete';

  @override
  String statusInProgress(int percent) {
    return '$percent%';
  }

  @override
  String get statusNotStarted => 'Not Started';

  @override
  String get statusNotApplicable => 'Not Applicable';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get sectionComingSoon =>
      'This section will be available in an upcoming update.';

  @override
  String get quickLinks => 'Quick Links';

  @override
  String get myProfile => 'My Profile';

  @override
  String get addFamilyMember => 'Add Family Member';

  @override
  String get switchMember => 'Switch Member';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm =>
      'Sign out of Padmashali Vidya Sethu on this device?';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet.';

  @override
  String get announcements => 'Announcements';

  @override
  String get noAnnouncements => 'Updates from the Sangha will appear here.';

  @override
  String get opportunities => 'Opportunities for You';

  @override
  String get noOpportunities =>
      'Scholarships, training and jobs that match your profile will appear here.';

  @override
  String get upcomingPrograms => 'Upcoming PVS Programs';

  @override
  String get noPrograms => 'No upcoming programs right now.';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get educationStatus => 'Current Status & Education';

  @override
  String get community => 'Temple & Organisation';

  @override
  String get addresses => 'Addresses';

  @override
  String get disabilityInformation => 'Disability Information';

  @override
  String get notApplicableShort => '—';

  @override
  String registeredOn(String date) {
    return 'Registered on $date';
  }

  @override
  String get dataCorrectionNote =>
      'To correct any of this information, please contact the Sangha office. Online editing will be available soon.';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationSelect => 'Please make a selection.';

  @override
  String get validationNameTooShort => 'Please enter at least 2 characters.';

  @override
  String get validationNameInvalid =>
      'Use letters, spaces, dots and hyphens only.';

  @override
  String get validationAddressTooShort => 'Please enter a complete address.';

  @override
  String get validationPinInvalid => 'PIN code must be exactly 6 digits.';

  @override
  String get validationDobRequired => 'Please select the date of birth.';

  @override
  String validationMinAge(int age) {
    return 'Members must be at least $age years old.';
  }

  @override
  String get validationDisabilityType =>
      'Please select the type of disability.';

  @override
  String get validationPrivacy =>
      'Please accept the privacy policy to continue.';

  @override
  String get validationGuardian =>
      'Parent or guardian consent is required for members under 18.';

  @override
  String get fixHighlightedFields => 'Please correct the highlighted fields.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'Unable to reach the server. Please check your internet connection and try again.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading…';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateRequiredBody =>
      'A new version of Padmashali Vidya Sethu is available. Please update the app to continue.';

  @override
  String get updateAvailable => 'A new version of the app is available.';

  @override
  String updateVersions(String installed, String latest) {
    return 'Your version: $installed   Latest: $latest';
  }

  @override
  String get updateNow => 'Update now';

  @override
  String get updateStoreHint =>
      'Open the Play Store or App Store and update Padmashali Vidya Sethu.';

  @override
  String get updateCheckAgain => 'Check again';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get memberMobileLabel => 'Mobile number (optional)';

  @override
  String get memberMobileHelp =>
      'If this person has their own mobile number, add it. We will send a verification code to it.';

  @override
  String get memberMobileVerify => 'Verify';

  @override
  String memberMobileCodeSent(String number) {
    return 'Enter the 4-digit code sent to $number.';
  }

  @override
  String get memberMobileVerified => 'Verified';

  @override
  String get memberMobileNeedsVerification =>
      'Verify this mobile number, or leave it empty.';
}

/// Privacy Policy and Terms and Conditions shown in the app (Settings menu, sign-in and registration).
///
/// DRAFT - must be reviewed by a qualified adviser before the app is published. Items in [square brackets] are for
/// the Sangha to fill in. When a document changes, update [LegalDocument.lastUpdated] (and, for the privacy policy,
/// the API setting `Registration:PrivacyPolicyVersion`, which is recorded with each member's consent).
library;

class LegalSection {
  const LegalSection(this.heading, this.paragraphs);
  final String heading;
  final List<String> paragraphs;
}

class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.lastUpdated,
    required this.intro,
    required this.sections,
  });
  final String title;
  final String lastUpdated;
  final String intro;
  final List<LegalSection> sections;
}

abstract final class LegalDocuments {
  /// Shown on both pages until the texts are approved for publication.
  static const draft = false;

  static const privacyPolicy = LegalDocument(
    title: 'Privacy Policy',
    lastUpdated: '23 October 2026 (draft)',
    intro:
        'This policy explains how the Padmashali Vidya Sethu app collects, uses, shares and keeps personal '
        'information. Please read it before you register yourself or a family member.',
    sections: [
      LegalSection('Who we are', [
        'The app is run by the D. K. Jilla Padmashali Vidyavardhaka Sangha (R), Udupi ("the Sangha", "we", "us") to '
            'support the education, careers and welfare of the community. Technology and hosting are provided to the '
            'Sangha by Swaprajna Technologies (OPC) Private Limited, which acts only on the Sangha\'s instructions.',
        'Contact: Padmashali Suvarna Mahotsava Bhavana, Adi-Udupi, Udupi - 576103.',
        'Phone: 9741413165',
        'Email: vidyavardhaka@padmashalimahasabha.com',
      ]),
      LegalSection('Information we collect', [
        'Account: your mobile number, which you verify with a one-time code. One number can register several family '
            'members.',
        'Member details: full name, father\'s and mother\'s names, date of birth, gender, temple, current status '
            '(student, working or unemployed), class studying or highest education, and organisation.',
        'Optional contact details: a member\'s own mobile number and email address, each verified with its own code.',
        'Addresses: permanent and current address, including PIN or postal code, city or village, taluk, district, '
            'state and country.',
        'Disability information, if you choose to give it: whether the member has a disability and its type. This is '
            'sensitive information and is treated with extra care (see below).',
        'Consent records: when you accepted this policy and, for members under 18, the parent or guardian consent.',
        'Technical information: the IP address and time of sign-ins and verification requests, and a record of '
            'important actions (an audit log), used for security. If you allow notifications, a notification token '
            'for your device.',
      ]),
      LegalSection('How we use it', [
        'To create and manage member profiles; to plan and offer the Sangha\'s education, scholarship, career and '
            'employment programs; to contact members about those programs; to prepare statistics (for example the '
            'number of students by district); and to keep the app secure and prevent misuse.',
        'We do not sell personal information and do not use it for advertising. Member information is never shown in '
            'any public directory.',
      ]),
      LegalSection('Disability information', [
        'Disability information is optional. It is visible only to you and to Sangha staff who are specifically '
            'authorised to see it, and it is used only to plan support and accessibility for programs.',
      ]),
      LegalSection('Children', [
        'Members can be as young as 5. Members under 18 must be registered by, or with the consent of, a parent or '
            'guardian, who confirms that consent in the app. A parent or guardian can ask us about, correct or close '
            'a child\'s registration at any time.',
      ]),
      LegalSection('Who we share it with', [
        'Authorised Sangha office-bearers and staff, only as far as their role needs.',
        'Service providers that run parts of the app for us, only for that purpose: Microsoft Azure (hosting and '
            'database, in India), SMS Gateway Hub (verification codes by SMS in India), Meta WhatsApp Business '
            '(verification codes for numbers outside India), Zoho Mail (email verification codes), Google '
            'Firebase (app notifications) and India Post\'s PIN code service (only the PIN code you enter).',
        'Authorities, when the law requires it.',
      ]),
      LegalSection('How long we keep it, and deleting your account', [
        'You can delete your account in the app (menu > Delete Account). Your account and the members registered with '
            'it are then closed and no longer shown in the app, and the mobile number cannot be used to sign in or '
            'register again.',
        'The information is kept in the Sangha\'s records, marked as deleted, for record-keeping and to prevent '
            'misuse, in line with the Digital '
            'Personal Data Protection Act, 2023.',
      ]),
      LegalSection('Security', [
        'Information is sent over encrypted connections and stored on secured servers. Verification codes are stored '
            'only in scrambled (hashed) form, and access by staff is limited and logged. No system is completely '
            'secure, so please keep your phone and codes to yourself.',
      ]),
      LegalSection('Your rights', [
        'You may ask for a summary of the information we hold about you or your child, ask us to correct or update '
            'it, withdraw consent, or raise a complaint. To correct information, please contact the Sangha office; '
            'online editing will be available soon.',
        'Grievance officer: President, D K Jilla Paddmashali Vidyavardhaka Sangha (R). If you are not satisfied with our response, you may '
            'complain to the Data Protection Board of India.',
      ]),
      LegalSection('Changes to this policy', [
        'We may update this policy. The date at the top shows the latest version; important changes will be shown in '
            'the app before they apply.',
      ]),
    ],
  );

  static const termsAndConditions = LegalDocument(
    title: 'Terms and Conditions',
    lastUpdated: '23 October 2026 (draft)',
    intro:
        'These terms apply when you use the Padmashali Vidya Sethu app. By signing in or registering, you agree to '
        'them and to the Privacy Policy.',
    sections: [
      LegalSection('About the app', [
        'The app is provided by the D. K. Jilla Padmashali Vidyavardhaka Sangha (R), Udupi ("the Sangha") so that '
            'community members can create education and career profiles and hear about the Sangha\'s programs. It is '
            'free to use.',
      ]),
      LegalSection('Your account', [
        'You sign in with your mobile number and a one-time verification code. Keep your phone and codes to yourself - '
            'anyone with your code can use your account.',
        'One mobile number can register several family members (for example a parent registering children). You are '
            'responsible for the members you register and for having their permission, or being their parent or '
            'guardian.',
      ]),
      LegalSection('Accurate information', [
        'Please give true, complete and up-to-date information. The Sangha may check information, and may correct, '
            'deactivate or remove a registration that is false, duplicated or misused.',
      ]),
      LegalSection('Acceptable use', [
        'Do not use the app for anything unlawful, do not register people without their permission, do not try to '
            'access other people\'s information, and do not attempt to disrupt, overload or break the app\'s security.',
      ]),
      LegalSection('Programs and opportunities', [
        'Registering does not by itself make anyone eligible for, or guarantee, a scholarship, program, job or other '
            'benefit. Each program has its own rules, decided by the Sangha.',
      ]),
      LegalSection('Messages', [
        'By registering you agree that the Sangha may contact you about its programs through the app, SMS, WhatsApp '
            'or email. Verification codes are sent only when you ask for them.',
      ]),
      LegalSection('Deleting your account', [
        'You can delete your account at any time in the app (menu > Delete Account). After deletion the mobile number '
            'cannot be used to sign in or register again, and the information is kept in the Sangha\'s records as '
            'described in the Privacy Policy. The Sangha may also close an account that breaks these terms.',
      ]),
      LegalSection('Availability and liability', [
        'We work to keep the app available and correct but cannot promise it will always be uninterrupted or '
            'error-free. To the extent the law allows, the Sangha is not liable for indirect losses arising from use '
            'of the app.',
      ]),
      LegalSection('Changes and governing law', [
        'We may update these terms; the date at the top shows the latest version, and continuing to use the app means '
            'you accept the updated terms. These terms are governed by the laws of India, and courts at Udupi, '
            'Karnataka have jurisdiction.',
      ]),
      LegalSection('Contact', [
        'Padmashali Suvarna Mahotsava Bhavana, Adi-Udupi, Udupi - 576103.',
      ]),
      LegalSection('Phone', ['9741413165']),
      LegalSection('Email', ['vidyavardhaka@padmashalimahasabha.com']),
    ],
  );
}

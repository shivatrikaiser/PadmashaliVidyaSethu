/**
 * Padmashali Vidya Sethu APP documents, published here so Google Play (and anyone without the app) can read them:
 * /organizations/padmashali-vidya-sethu/privacy, /terms and /delete-account.
 *
 * DRAFT - same review as the other legal pages (draft notice while `legalPagesApproved` is false). The privacy
 * policy and terms are the same text as the app's (Frontend/padmashali_vidya_setu/lib/legal/legal_documents.dart):
 * change both together. Items in [square brackets] are for the Sangha to fill in.
 */
import type { LegalDocument } from './legal';

const sangha = 'the D. K. Jilla Padmashali Vidyavardhaka Sangha (R), Udupi';

export const pvsPrivacy: LegalDocument = {
  title: 'Padmashali Vidya Sethu app - Privacy Policy',
  lastUpdated: '23 October 2026',
  intro:
    'This policy explains how the Padmashali Vidya Sethu app collects, uses, shares and keeps personal ' +
    'information. Please read it before you register yourself or a family member.',
  sections: [
    {
      heading: 'Who we are',
      paragraphs: [
        `The app is run by ${sangha} ("the Sangha", "we", "us") to support the education, careers and welfare of ` +
          'the community. Technology and hosting are provided to the Sangha by Swaprajna Technologies (OPC) ' +
          "Private Limited, which acts only on the Sangha's instructions.",
        'Contact: Padmashali Suvarna Mahotsava Bhavana, Adi-Udupi, Udupi - 576103.',
        'Phone: 9741413165',
        'Email: vidyavardhaka@padmashalimahasabha.com',
      ],
    },
    {
      heading: 'Information we collect',
      paragraphs: [
        'Account: your mobile number, which you verify with a one-time code. One number can register several ' +
          'family members.',
        "Member details: full name, father's and mother's names, date of birth, gender, temple, current status " +
          '(student, working or unemployed), class studying or highest education, and organisation.',
        "Optional contact details: a member's own mobile number and email address, each verified with its own code.",
        'Addresses: permanent and current address, including PIN or postal code, city or village, taluk, ' +
          'district, state and country.',
        'Disability information, if you choose to give it: whether the member has a disability and its type. This ' +
          'is sensitive information and is treated with extra care (see below).',
        'Consent records: when you accepted this policy and, for members under 18, the parent or guardian consent.',
        'Technical information: the IP address and time of sign-ins and verification requests, and a record of ' +
          'important actions (an audit log), used for security. If you allow notifications, a notification token ' +
          'for your device.',
      ],
    },
    {
      heading: 'How we use it',
      paragraphs: [
        "To create and manage member profiles; to plan and offer the Sangha's education, scholarship, career and " +
          'employment programs; to contact members about those programs; to prepare statistics (for example the ' +
          'number of students by district); and to keep the app secure and prevent misuse.',
        'We do not sell personal information and do not use it for advertising. Member information is never shown ' +
          'in any public directory.',
      ],
    },
    {
      heading: 'Disability information',
      paragraphs: [
        'Disability information is optional. It is visible only to you and to Sangha staff who are specifically ' +
          'authorised to see it, and it is used only to plan support and accessibility for programs.',
      ],
    },
    {
      heading: 'Children',
      paragraphs: [
        'Members can be as young as 5. Members under 18 must be registered by, or with the consent of, a parent or ' +
          'guardian, who confirms that consent in the app. A parent or guardian can ask us about, correct or close ' +
          "a child's registration at any time.",
      ],
    },
    {
      heading: 'Who we share it with',
      paragraphs: [
        'Authorised Sangha office-bearers and staff, only as far as their role needs.',
        'Service providers that run parts of the app for us, only for that purpose: Microsoft Azure (hosting and ' +
          'database, in India), SMS Gateway Hub (verification codes by SMS in India), Meta WhatsApp Business ' +
          '(verification codes for numbers outside India), Zoho Mail (email verification codes), Google ' +
          "Firebase (app notifications) and India Post's PIN code service (only the PIN code you enter).",
        'Authorities, when the law requires it.',
      ],
    },
    {
      heading: 'How long we keep it, and deleting your account',
      paragraphs: [
        'You can delete your account in the app (menu > Delete Account) - see "Delete your account" on this ' +
          'website. Your account and the members registered with it are then closed and no longer shown in the ' +
          'app, and the mobile number cannot be used to sign in or register again.',
        "The information is kept in the Sangha's records, marked as deleted, for record-keeping and to prevent " +
          'misuse, in line with the Digital ' +
          'Personal Data Protection Act, 2023.',
      ],
    },
    {
      heading: 'Security',
      paragraphs: [
        'Information is sent over encrypted connections and stored on secured servers. Verification codes are ' +
          'stored only in scrambled (hashed) form, and access by staff is limited and logged. No system is ' +
          'completely secure, so please keep your phone and codes to yourself.',
      ],
    },
    {
      heading: 'Your rights',
      paragraphs: [
        'You may ask for a summary of the information we hold about you or your child, ask us to correct or update ' +
          'it, withdraw consent, or raise a complaint. To correct information, please contact the Sangha office; ' +
          'online editing will be available soon.',
        'Grievance officer: President, D K Jilla Paddmashali Vidyavardhaka Sangha®. If you are not satisfied with our response, you ' +
          'may complain to the Data Protection Board of India.',
      ],
    },
    {
      heading: 'Changes to this policy',
      paragraphs: [
        'We may update this policy. The date at the top shows the latest version; important changes will be shown ' +
          'in the app before they apply.',
      ],
    },
  ],
};

export const pvsTerms: LegalDocument = {
  title: 'Padmashali Vidya Sethu app - Terms and Conditions',
  lastUpdated: '23 October 2026',
  intro:
    'These terms apply when you use the Padmashali Vidya Sethu app. By signing in or registering, you agree to ' +
    'them and to the Privacy Policy.',
  sections: [
    {
      heading: 'About the app',
      paragraphs: [
        `The app is provided by ${sangha} ("the Sangha") so that community members can create education and career ` +
          "profiles and hear about the Sangha's programs. It is free to use.",
      ],
    },
    {
      heading: 'Your account',
      paragraphs: [
        'You sign in with your mobile number and a one-time verification code. Keep your phone and codes to ' +
          'yourself - anyone with your code can use your account.',
        'One mobile number can register several family members (for example a parent registering children). You ' +
          'are responsible for the members you register and for having their permission, or being their parent ' +
          'or guardian.',
      ],
    },
    {
      heading: 'Accurate information',
      paragraphs: [
        'Please give true, complete and up-to-date information. The Sangha may check information, and may correct, ' +
          'deactivate or remove a registration that is false, duplicated or misused.',
      ],
    },
    {
      heading: 'Acceptable use',
      paragraphs: [
        'Do not use the app for anything unlawful, do not register people without their permission, do not try to ' +
          "access other people's information, and do not attempt to disrupt, overload or break the app's security.",
      ],
    },
    {
      heading: 'Programs and opportunities',
      paragraphs: [
        'Registering does not by itself make anyone eligible for, or guarantee, a scholarship, program, job or ' +
          'other benefit. Each program has its own rules, decided by the Sangha.',
      ],
    },
    {
      heading: 'Messages',
      paragraphs: [
        'By registering you agree that the Sangha may contact you about its programs through the app, SMS, ' +
          'WhatsApp or email. Verification codes are sent only when you ask for them.',
      ],
    },
    {
      heading: 'Deleting your account',
      paragraphs: [
        'You can delete your account at any time in the app (menu > Delete Account). After deletion the mobile ' +
          "number cannot be used to sign in or register again, and the information is kept in the Sangha's " +
          'records as described in the Privacy Policy. The Sangha may also close an account that breaks these terms.',
      ],
    },
    {
      heading: 'Availability and liability',
      paragraphs: [
        'We work to keep the app available and correct but cannot promise it will always be uninterrupted or ' +
          'error-free. To the extent the law allows, the Sangha is not liable for indirect losses arising from use ' +
          'of the app.',
      ],
    },
    {
      heading: 'Changes and governing law',
      paragraphs: [
        'We may update these terms; the date at the top shows the latest version, and continuing to use the app ' +
          'means you accept the updated terms. These terms are governed by the laws of India, and courts at Udupi, ' +
          'Karnataka have jurisdiction. ',
      ],
    },
    { heading: 'Contact', paragraphs: ['Padmashali Suvarna Mahotsava Bhavana, Adi-Udupi, Udupi - 576103.'] },
    { heading: 'Phone', paragraphs: ['9741413165'] },
    { heading: 'Email', paragraphs: ['vidyavardhaka@padmashalimahasabha.com'] },
  ],
};

export const pvsDeleteAccount: LegalDocument = {
  title: 'Padmashali Vidya Sethu app - Delete your account',
  lastUpdated: '23 October 2026',
  intro:
    'You can delete your Padmashali Vidya Sethu account at any time, in the app or by asking the Sangha. This page ' +
    'explains how, and what happens to your information.',
  sections: [
    {
      heading: 'Delete in the app',
      paragraphs: [
        '1. Open the Padmashali Vidya Sethu app and sign in with your mobile number.',
        '2. On the home screen, open the account menu (top right) and choose "Delete Account".',
        '3. Read what will happen, tick "I understand that this cannot be undone" and tap "Delete My Account", then ' +
          'confirm.',
        'You are signed out straight away.',
      ],
    },
    {
      heading: 'Without the app',
      paragraphs: [
        'If you no longer have the app, contact the Sangha office from the mobile number you registered with and ' +
          'ask for your account to be deleted: Phone: 9741413165 Email: vidyavardhaka@padmashalimahasabha.com. The Sangha will confirm the ' +
          'number belongs to you before deleting the account.',
      ],
    },
    {
      heading: 'What happens when you delete',
      paragraphs: [
        'Your account and every member registered with your mobile number are closed and no longer shown in the app.',
        'Your mobile number cannot be used to sign in or register again.',
        "The information you gave (member details, addresses, contact details and any disability information) is " +
          "not erased: it is kept in the Sangha's records, marked as deleted, for record-keeping and to prevent " +
          'misuse, in line with the Digital Personal Data Protection Act, 2023.',
        'Security records (sign-in and audit logs) are kept as well.',
      ],
    },
    {
      heading: 'Questions',
      paragraphs: [
        'See the app\'s Privacy Policy, or contact the Sangha: Phone: 9741413165, Email: vidyavardhaka@padmashalimahasabha.com',
      ],
    },
  ],
};

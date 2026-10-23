/**
 * DRAFT legal text - must be reviewed by a qualified adviser before production publication.
 * Pages show a draft notice while `legalPagesApproved` is false (src/environments).
 */
import { pvsDeleteAccount, pvsPrivacy, pvsTerms } from './pvs-legal';

export interface LegalDocument {
  title: string;
  lastUpdated: string;
  intro: string;
  sections: readonly { heading: string; paragraphs: readonly string[] }[];
}

const privacy: LegalDocument = {
  title: 'Privacy notice',
  lastUpdated: '13 October 2026 (draft)',
  intro:
    'This notice explains how the VidyaSethu public website (vidyasethu.co.in) handles personal data. It does not ' +
    'cover the portals of the organizations listed on this website - each organization has its own privacy notice.',
  sections: [
    {
      heading: 'Who we are',
      paragraphs: [
        'The VidyaSethu website is operated by Swaprajna Technologies (OPC) Private Limited (“we”, “us”). You can ' +
          'reach us using the details on the Contact page.',
      ],
    },
    {
      heading: 'Organizations are responsible for their own portals',
      paragraphs: [
        'Organizations such as Padmashali Vidya Sethu run their own portals. When you register or sign in there, ' +
          'that organization decides what information is collected and how it is used, under its own privacy ' +
          'notice. This website does not collect member registrations and cannot access organization records.',
      ],
    },
    {
      heading: 'What we collect on this website',
      paragraphs: [
        'Enquiries: if you send an enquiry, we receive what you enter - your name, organization (optional), email ' +
          'address and/or phone number, the category you chose and your message.',
        'Technical data: like any website, our hosting provider processes technical information such as your IP ' +
          'address, browser type and the pages requested, to deliver the website, keep it secure and diagnose ' +
          'problems.',
        'This website does not use advertising or tracking cookies and does not ask you to create an account. If ' +
          'that changes, this notice will be updated first.',
      ],
    },
    {
      heading: 'How we use it',
      paragraphs: [
        'We use enquiry details only to reply to you and to keep a record of the conversation. We do not sell ' +
          'personal data or use it for advertising. With your agreement, we may pass an enquiry to the organization ' +
          'it concerns.',
      ],
    },
    {
      heading: 'Legal basis and your rights',
      paragraphs: [
        'We process enquiry details with your consent, which you give when you send the form. We intend to handle ' +
          'personal data in line with applicable Indian law, including the Digital Personal Data Protection Act, ' +
          '2023. [For review: confirm obligations, grievance-officer details and the process for withdrawing consent.]',
        'You may ask us for a summary of the personal data we hold about you, ask us to correct or erase it, or ' +
          'withdraw your consent, by contacting us. Choose “Privacy or personal data request” on the contact form.',
      ],
    },
    {
      heading: 'How long we keep it',
      paragraphs: [
        'We keep enquiries only as long as needed to respond and follow up. [For review: set a retention period, ' +
          'for example 24 months after the last contact.] Hosting logs are kept for a limited period set by our ' +
          'hosting configuration.',
      ],
    },
    {
      heading: 'Who we share it with',
      paragraphs: [
        'Service providers that host and operate this website and its enquiry service process data on our behalf. ' +
          '[For review: list providers and data locations once hosting is confirmed.] We may disclose data where ' +
          'required by law.',
      ],
    },
    {
      heading: 'Children',
      paragraphs: [
        'This website is for organizations and the public. Students under 18 should ask a parent or guardian to ' +
          'contact us on their behalf, and should register for programs through their organization’s portal.',
      ],
    },
    {
      heading: 'Security',
      paragraphs: [
        'The website is served over an encrypted connection (HTTPS). Enquiry details are transmitted securely and ' +
          'access is limited to people who need it to respond.',
      ],
    },
    {
      heading: 'Changes to this notice',
      paragraphs: ['We will post any changes on this page and update the date above.'],
    },
  ],
};

const terms: LegalDocument = {
  title: 'Terms of use',
  lastUpdated: '13 October 2026 (draft)',
  intro:
    'These terms apply to your use of the VidyaSethu public website (vidyasethu.co.in). Organization portals have ' +
    'their own terms.',
  sections: [
    {
      heading: 'About this website',
      paragraphs: [
        'The website is operated by Swaprajna Technologies (OPC) Private Limited. It describes the VidyaSethu ' +
          'platform and lists organizations that use it. By using the website you accept these terms.',
      ],
    },
    {
      heading: 'Organizations are independent',
      paragraphs: [
        'Each listed organization runs its own programs and portal. Scholarships, job opportunities, guidance and ' +
          'other programs are offered and decided by that organization, not by VidyaSethu. We do not guarantee that ' +
          'any program, scholarship or opportunity will be available to you.',
      ],
    },
    {
      heading: 'Features and availability',
      paragraphs: [
        'Some features described on this website are planned and not yet available; they are labelled as such. ' +
          'Features, content and availability may change.',
      ],
    },
    {
      heading: 'Acceptable use',
      paragraphs: [
        'Do not misuse the website - for example by sending spam or misleading enquiries, trying to gain ' +
          'unauthorised access, disrupting the service or scraping it at scale.',
      ],
    },
    {
      heading: 'Links to other sites',
      paragraphs: [
        'Links to organization portals and other websites are provided for convenience. Those sites are ' +
          'responsible for their own content, terms and privacy practices.',
      ],
    },
    {
      heading: 'Intellectual property',
      paragraphs: [
        'The VidyaSethu name, logo and website content belong to Swaprajna Technologies (OPC) Private Limited. ' +
          'Organization names and logos belong to the respective organizations and are shown with their permission.',
      ],
    },
    {
      heading: 'Disclaimer and liability',
      paragraphs: [
        'The website is provided “as is”. We try to keep the information accurate but do not guarantee that it is ' +
          'complete or current. [For review: limitation-of-liability wording.]',
      ],
    },
    {
      heading: 'Governing law',
      paragraphs: [
        'These terms are governed by the laws of India. [For review: confirm jurisdiction (courts of the relevant ' +
          'city).]',
      ],
    },
    {
      heading: 'Changes',
      paragraphs: ['We may update these terms. The date above shows when they last changed.'],
    },
  ],
};

const accessibility: LegalDocument = {
  title: 'Accessibility',
  lastUpdated: '13 October 2026 (draft)',
  intro:
    'We want everyone, including people with disabilities, to be able to use the VidyaSethu website. We aim to meet ' +
    'the Web Content Accessibility Guidelines (WCAG) 2.2 at level AA. This is our goal - the website has not yet ' +
    'been independently audited.',
  sections: [
    {
      heading: 'What we have done',
      paragraphs: [
        'Pages use headings, landmarks and labels that work with screen readers; all functions can be used with a ' +
          'keyboard, with a visible focus indicator and a “skip to main content” link; text and colours are chosen ' +
          'for readable contrast; pages adapt to small screens and to browser zoom; and motion is reduced when your ' +
          'device asks for it.',
      ],
    },
    {
      heading: 'Known limitations',
      paragraphs: [
        'The website is currently available in English only. Kannada is planned.',
        'Organization portals are separate applications and may differ in accessibility. Please report problems with ' +
          'a portal to that organization as well as to us.',
      ],
    },
    {
      heading: 'Tell us about a problem',
      paragraphs: [
        'If something on this website is hard to use, please tell us using the contact form (choose “Feedback ' +
          'about this website”) and include the page address. We will try to respond and fix the problem.',
      ],
    },
  ],
};

export const legal = { privacy, terms, accessibility, pvsPrivacy, pvsTerms, pvsDeleteAccount };

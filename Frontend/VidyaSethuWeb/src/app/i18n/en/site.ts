/** Site-wide text: navigation, footer, shared labels, page titles and descriptions. */
export const site = {
  siteName: 'VidyaSethu',
  common: {
    skipToContent: 'Skip to main content',
    openMenu: 'Open menu',
    closeMenu: 'Close menu',
    primaryNav: 'Main',
    footerNav: 'Footer',
    learnMore: 'Learn more',
    status: {
      available: 'Implemented in PVS',
      planned: 'Planned',
      future: 'Future',
    },
    draftNotice:
      'Draft for review. This document has not yet been approved for publication and may change before VidyaSethu ' +
      'goes live.',
    lastUpdated: 'Last updated',
  },
  nav: {
    home: 'Home',
    about: 'About',
    features: 'Features',
    organizations: 'Organizations',
    forOrganizations: 'For organizations',
    forStudents: 'For students',
    forJobSeekers: 'For job seekers',
    contact: 'Contact',
    privacy: 'Privacy',
    terms: 'Terms',
    accessibility: 'Accessibility',
  },
  footer: {
    tagline:
      'A configurable digital platform that helps organizations support students, job seekers and communities.',
    platform: 'Platform',
    audiences: 'Who it is for',
    company: 'Company',
    productOf: (company: string) => `VidyaSethu is a product of ${company}.`,
    copyright: (year: number, company: string) => `© ${year} ${company}`,
    orgDisclaimer:
      'Organizations listed on VidyaSethu are independent. Each manages its own members, programs and portal.',
  },
  seo: {
    home: {
      title: 'VidyaSethu - Connecting Communities to a Brighter Future',
      description:
        'VidyaSethu helps organizations empower students, support job seekers and connect communities with ' +
        'educational and career opportunities through a configurable digital platform.',
    },
    about: {
      title: 'About VidyaSethu',
      description:
        'What VidyaSethu is, why it exists and how organizations use it to support their communities.',
    },
    features: {
      title: 'Features | VidyaSethu',
      description:
        'Member registry, scholarships, careers, education information, administration and reporting - what is ' +
        'available today and what is planned.',
    },
    organizations: {
      title: 'Participating organizations | VidyaSethu',
      description:
        'Organizations that use VidyaSethu to support their students, members and job seekers.',
    },
    forOrganizations: {
      title: 'For organizations | VidyaSethu',
      description:
        'Give your Sangha, trust or institution its own portal for member registration, scholarships and career ' +
        'support.',
    },
    forStudents: {
      title: 'For students | VidyaSethu',
      description:
        'Scholarships, guidance and opportunities through the organizations you belong to.',
    },
    forJobSeekers: {
      title: 'For job seekers | VidyaSethu',
      description:
        'Career opportunities, guidance and training through the organizations you belong to.',
    },
    contact: {
      title: 'Contact | VidyaSethu',
      description:
        'Contact the VidyaSethu team about the platform, onboarding your organization or partnerships.',
    },
    privacy: {
      title: 'Privacy notice | VidyaSethu',
      description: 'How the VidyaSethu website handles personal data.',
    },
    terms: {
      title: 'Terms of use | VidyaSethu',
      description: 'Terms for using the VidyaSethu website.',
    },
    accessibility: {
      title: 'Accessibility | VidyaSethu',
      description: 'Our approach to making VidyaSethu accessible, and how to report a problem.',
    },
    notFound: {
      title: 'Page not found | VidyaSethu',
      description: 'The page you are looking for does not exist.',
    },
    organizationPage: (name: string) => `${name} | VidyaSethu`,
  },
  notFound: {
    title: 'Page not found',
    text: 'The page you are looking for does not exist or has moved.',
    home: 'Go to the home page',
    organizations: 'Browse organizations',
  },
};

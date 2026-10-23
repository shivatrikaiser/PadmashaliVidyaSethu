import type { IconName } from '../../shared/icon';

/** Feature status shown as a badge. `available` = built in Padmashali Vidya Sethu today. */
export type FeatureStatus = 'available' | 'planned' | 'future';

export const pages = {
  home: {
    eyebrow: 'Education · Scholarships · Careers · Community',
    title: 'Connecting Communities to a Brighter Future',
    lead:
      'VidyaSethu helps organizations empower students, support job seekers and connect communities with ' +
      'educational and career opportunities through a configurable digital platform.',
    primaryCta: 'Explore Organizations',
    secondaryCta: 'For Organizations',
    productOfLabel: 'Product of',
    pillarsTitle: 'Support for every stage of a young person’s journey',
    pillarsLead:
      'VidyaSethu brings together the help that community organizations already give - in one place, for every ' +
      'member.',
    pillars: [
      {
        icon: 'book' as IconName,
        title: 'Education',
        text: 'Follow each student’s learning journey from school to higher education, and share information about courses and competitive exams.',
      },
      {
        icon: 'award' as IconName,
        title: 'Scholarships',
        text: 'Understand where support is needed most, then plan and manage scholarship programs.',
      },
      {
        icon: 'briefcase' as IconName,
        title: 'Careers',
        text: 'Connect job seekers with opportunities, guidance and training shared by the organizations they belong to.',
      },
      {
        icon: 'community' as IconName,
        title: 'Community support',
        text: 'Give associations, trusts and institutions a simple, secure way to stay connected with their members.',
      },
    ],
    pillarsNote: 'Some capabilities are still being built.',
    pillarsNoteLink: 'See what is available today',
    howTitle: 'How VidyaSethu works',
    howSteps: [
      {
        title: 'An organization joins',
        text: 'It gets its own portal with its own name and branding, and chooses the modules it needs.',
      },
      {
        title: 'Members register with their organization',
        text: 'Students, families and job seekers sign up through that organization’s portal. Their records stay with that organization.',
      },
      {
        title: 'Opportunities reach the right people',
        text: 'The organization uses its members’ profiles to plan and share scholarships, guidance and opportunities.',
      },
    ],
    orgsTitle: 'Participating organizations',
    orgsLead:
      'Each organization on VidyaSethu runs its own portal, with its own members, records and administrators.',
    orgsAll: 'View all organizations',
    joinTitle: 'Does your organization support students or job seekers?',
    joinText:
      'VidyaSethu can give your Sangha, trust or institution its own portal for member registration, scholarships ' +
      'and career support.',
    joinCta: 'Talk to us',
    contactTitle: 'Get in touch',
    contactText:
      'Questions about VidyaSethu, partnerships or bringing your organization on board? We would like to hear from you.',
    contactCta: 'Contact us',
  },

  about: {
    title: 'About VidyaSethu',
    lead:
      'VidyaSethu - “bridge to learning” - is a digital platform that community organizations use to support ' +
      'their students, members and job seekers.',
    sections: [
      {
        heading: 'What VidyaSethu is',
        paragraphs: [
          'VidyaSethu is a configurable platform for organizations that care about education and careers. It gives ' +
            'each organization a portal where members can register and keep their profile up to date, and tools ' +
            'that help the organization plan and deliver support.',
        ],
      },
      {
        heading: 'Why it exists',
        paragraphs: [
          'Community associations, educational trusts and welfare organizations do valuable work for students and ' +
            'young people. Much of it still depends on paper forms, spreadsheets and personal contacts, which makes ' +
            'it hard to know who needs help and to reach everyone who could benefit.',
          'VidyaSethu aims to give these organizations a reliable, well-built digital foundation, so they can spend ' +
            'their time on the support itself.',
        ],
      },
      {
        heading: 'How organizations use it',
        paragraphs: [
          'An organization gets its own portal under its own name. Its members register there, and its ' +
            'administrators use the portal to understand their community - for example how many members are at ' +
            'school, in college or looking for work - and to plan programs such as scholarships, guidance and ' +
            'training.',
        ],
      },
      {
        heading: 'Connecting students and job seekers with opportunities',
        paragraphs: [
          'Because members keep their education and career details in one place, their organization can share the ' +
            'right opportunity with the right people: a scholarship for students in a particular course, guidance ' +
            'before a competitive exam, or a job opening for someone with the matching skills.',
        ],
      },
      {
        heading: 'VidyaSethu and the organizations that use it',
        paragraphs: [
          'VidyaSethu is a product of Swaprajna Technologies (OPC) Private Limited. The organizations listed on this ' +
            'website, such as Padmashali Vidya Sethu, are independent. Each one decides who can register, runs its ' +
            'own programs and manages its own members’ records.',
          'VidyaSethu provides the technology. It does not award scholarships, offer jobs or make decisions on ' +
            'behalf of any organization, and one organization cannot see another organization’s records.',
        ],
      },
    ],
  },

  features: {
    title: 'Features',
    lead:
      'VidyaSethu is being built step by step, starting with what organizations need first. Each module below is ' +
      'marked with its current status.',
    legendTitle: 'What the labels mean',
    legend: {
      available:
        'Built and working in the Padmashali Vidya Sethu application, the first organization on VidyaSethu.',
      planned: 'On the roadmap for a later version of VidyaSethu. Not available yet.',
      future: 'Being explored for the future. Not available yet.',
    },
    modules: [
      {
        icon: 'users' as IconName,
        status: 'available' as FeatureStatus,
        title: 'Student and member registry',
        points: [
          'Registration after mobile-number verification',
          'Several family members under one account',
          'Profile completion dashboard for each member',
        ],
      },
      {
        icon: 'settings' as IconName,
        status: 'available' as FeatureStatus,
        title: 'Organization administration',
        points: [
          'Web portal for the organization’s administrators',
          'Member search and filters',
          'Administrator roles and organization-managed lists',
        ],
      },
      {
        icon: 'chart' as IconName,
        status: 'available' as FeatureStatus,
        title: 'Reporting and analytics',
        points: [
          'Dashboard totals and breakdowns of the membership',
          'Export of member lists to a spreadsheet',
        ],
      },
      {
        icon: 'award' as IconName,
        status: 'planned' as FeatureStatus,
        title: 'Scholarship management',
        points: [
          'Publish scholarship programs with eligibility rules',
          'Online applications and review by the organization',
        ],
      },
      {
        icon: 'briefcase' as IconName,
        status: 'planned' as FeatureStatus,
        title: 'Jobs and career opportunities',
        points: [
          'Career interests and employment details in member profiles',
          'Job opportunities shared with members',
        ],
      },
      {
        icon: 'book' as IconName,
        status: 'planned' as FeatureStatus,
        title: 'Education and competitive-exam information',
        points: ['Courses, colleges and entrance information', 'Competitive-exam guidance'],
      },
      {
        icon: 'layers' as IconName,
        status: 'planned' as FeatureStatus,
        title: 'Multi-organization platform',
        points: [
          'Each organization with its own branding and address',
          'Modules switched on per organization',
          'Separate records for every organization',
        ],
      },
      {
        icon: 'community' as IconName,
        status: 'future' as FeatureStatus,
        title: 'Mentoring and community engagement',
        points: [
          'Connecting students with mentors from their community',
          'Events and announcements',
        ],
      },
    ],
    ctaTitle: 'Want to see whether VidyaSethu fits your organization?',
    ctaButton: 'For organizations',
  },

  organizations: {
    title: 'Participating organizations',
    lead:
      'Organizations that use VidyaSethu to support their students, members and job seekers. Each organization ' +
      'manages its own portal, members and programs.',
    empty: 'No organizations are listed yet.',
    viewOrganization: (name: string) => `View ${name}`,
    categories: {
      communityAssociation: 'Community association',
      educationalTrust: 'Educational trust',
      studentWelfare: 'Student welfare organization',
      educationalInstitution: 'Educational institution',
      other: 'Organization',
    },
    joinTitle: 'Want your organization listed here?',
    joinCta: 'For organizations',
  },

  organization: {
    breadcrumb: 'Organizations',
    breadcrumbLabel: 'Breadcrumb',
    operatedBy: (name: string) => `Run for ${name}`,
    open: (name: string) => `Open ${name}`,
    openNote: (name: string) =>
      `You will continue to the ${name} portal. Registration and sign-in are handled by ${name}, not by VidyaSethu.`,
    developmentLink:
      'Development link: this points to a copy of the application running on this computer. It is never shown in ' +
      'production.',
    notAvailableTitle: 'Portal not yet available online',
    notAvailable: (name: string) =>
      `The ${name} portal is not yet publicly available. This page will link to it as soon as it launches.`,
    linkLabels: {
      application: 'Open portal',
      registration: 'Register',
      scholarships: 'Scholarships',
      jobs: 'Jobs',
    },
    highlightsTitle: 'What members can do',
    highlightStatus: { available: 'Available', planned: 'Planned' },
    aboutTitle: 'About the organization',
    appPoliciesTitle: 'App policies',
    appPolicyLinks: {
      privacy: 'Privacy Policy',
      terms: 'Terms and Conditions',
      deleteAccount: 'Delete your account',
    },
    contactTitle: 'Contact',
    contactNone: (name: string) =>
      `Contact details for ${name} have not been published on VidyaSethu. Members can find them in the ${name} portal.`,
    contactLabels: { email: 'Email', phone: 'Phone', website: 'Website', address: 'Address' },
    independence: (name: string) =>
      `${name} is an independent organization using the VidyaSethu platform. Its programs, scholarships and member ` +
      `records are managed by ${name}.`,
    notFoundTitle: 'Organization not found',
    notFoundText: 'This organization is not listed on VidyaSethu.',
    backToDirectory: 'Back to all organizations',
  },

  forOrganizations: {
    title: 'Give your members a portal of their own',
    lead:
      'VidyaSethu helps Sanghas, associations, trusts and institutions register their students and young members, ' +
      'understand their needs and support them with scholarships, guidance and career opportunities.',
    cta: 'Request a demo',
    benefitsTitle: 'Why organizations choose VidyaSethu',
    benefits: [
      {
        icon: 'building' as IconName,
        title: 'Your organization, your portal',
        text: 'Members see your organization’s name and logo. VidyaSethu stays in the background.',
      },
      {
        icon: 'shield' as IconName,
        title: 'Your records stay yours',
        text: 'Each organization’s members and records are kept separate. Other organizations cannot see them.',
      },
      {
        icon: 'layers' as IconName,
        title: 'Start with what you need',
        text: 'Begin with member registration, then add scholarships, careers and more as you are ready.',
      },
      {
        icon: 'phone' as IconName,
        title: 'Built for mobile',
        text: 'Members register and update their profile from their phone, after verifying their mobile number.',
      },
    ],
    modulesTitle: 'Modules',
    modulesLead: 'See Features for details of each module and its status.',
    brandingTitle: 'Organization-specific branding',
    brandingText:
      'Your portal carries your organization’s name, logo and colours, so members know it is yours. As the ' +
      'platform grows, organizations will also be able to use their own web address, such as ' +
      'yourorganization.vidyasethu.co.in.',
    adminTitle: 'Administration and reporting',
    adminText:
      'Your administrators get a secure web portal to search and review members, manage the lists your forms use ' +
      'and see dashboards of your membership - by current status, location, age group and more - with exports ' +
      'for your own planning.',
    onboardingTitle: 'How onboarding works',
    onboarding: [
      {
        title: 'First conversation',
        text: 'Tell us about your organization, your members and what you want to achieve.',
      },
      {
        title: 'Plan',
        text: 'Together we agree the modules, branding and information your members will provide.',
      },
      { title: 'Set up', text: 'We configure your portal and give your administrators access.' },
      {
        title: 'Launch',
        text: 'You invite your members to register, and we support you as you grow.',
      },
    ],
    enquiryTitle: 'Request a demo or ask a question',
    enquiryLead: 'Tell us a little about your organization and we will get back to you.',
  },

  audience: {
    students: {
      title: 'For students',
      lead: 'Scholarships, guidance and opportunities - through the organizations you belong to.',
      benefitsTitle: 'How VidyaSethu can help you',
      benefits: [
        {
          icon: 'book' as IconName,
          status: 'available' as FeatureStatus,
          title: 'One profile for your education',
          text: 'Keep your school, PUC and college details in one place, so your organization knows how to support you.',
        },
        {
          icon: 'award' as IconName,
          status: 'planned' as FeatureStatus,
          title: 'Scholarships',
          text: 'Find out about scholarships offered by your organization and apply online.',
        },
        {
          icon: 'compass' as IconName,
          status: 'planned' as FeatureStatus,
          title: 'Courses and competitive exams',
          text: 'Information about courses, colleges and competitive exams, shared by your organization.',
        },
        {
          icon: 'community' as IconName,
          status: 'future' as FeatureStatus,
          title: 'Guidance and mentoring',
          text: 'Connect with people from your community who can guide you.',
        },
      ],
    },
    jobSeekers: {
      title: 'For job seekers',
      lead: 'Career opportunities, guidance and training - through the organizations you belong to.',
      benefitsTitle: 'How VidyaSethu can help you',
      benefits: [
        {
          icon: 'users' as IconName,
          status: 'available' as FeatureStatus,
          title: 'Be known to your community',
          text: 'Register with your organization so it knows you are looking for work and what you are qualified for.',
        },
        {
          icon: 'briefcase' as IconName,
          status: 'planned' as FeatureStatus,
          title: 'Job opportunities',
          text: 'Hear about openings shared by your organization and its members.',
        },
        {
          icon: 'compass' as IconName,
          status: 'planned' as FeatureStatus,
          title: 'Career guidance and training',
          text: 'Information about training programs and career guidance arranged by your organization.',
        },
        {
          icon: 'community' as IconName,
          status: 'future' as FeatureStatus,
          title: 'Mentoring',
          text: 'Connect with experienced professionals from your community.',
        },
      ],
    },
    statusNote: 'Labels show what is available today and what is still being built.',
    joinTitle: 'How to join',
    joinText:
      'You join VidyaSethu through your organization: choose it below and register on its portal. There is no ' +
      'separate VidyaSethu sign-up, and your details stay with your organization.',
    noOrganizationTitle: 'Your organization is not listed?',
    noOrganizationText: 'Let your organization know about VidyaSethu, or ask them to contact us.',
    noOrganizationCta: 'For organizations',
  },

  contact: {
    title: 'Contact us',
    lead: 'Questions about VidyaSethu, bringing your organization on board, partnerships or this website.',
    detailsTitle: 'Contact details',
    detailsPending: 'Our contact details will be published here soon.',
    labels: { company: 'Company', email: 'Email', phone: 'Phone', address: 'Address' },
    membersTitle: 'Are you a member of an organization?',
    membersText:
      'For questions about your registration, profile, scholarships or other programs, please contact your ' +
      'organization directly. The VidyaSethu team cannot see or change organization records.',
    formTitle: 'Send us a message',
  },
};

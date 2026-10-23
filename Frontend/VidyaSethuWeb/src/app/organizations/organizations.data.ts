import type { Organization } from './organization.model';

/**
 * Public organization listings (version-controlled; developers add organizations here).
 * Destinations per environment are set in src/environments (`organizationLinks`), not here.
 *
 * To add an organization: append a record, put its logo under public/organizations/{slug}/, set its links in the
 * environment files, add its domain to `allowedLinkHosts` if it is outside vidyasethu.co.in, and set
 * status 'listed' only once the organization has approved the listing.
 */
export const ORGANIZATIONS: readonly Organization[] = [
  {
    organizationId: 'pvs',
    slug: 'padmashali-vidya-sethu',
    displayName: { en: 'Padmashali Vidya Sethu' },
    operatedBy: { en: 'Padmashali Vidyavardhaka Sangha' },
    description: {
      en:
        'An education, skills, career and employment platform for Padmashali children and young people, ' +
        'run for the Padmashali Vidyavardhaka Sangha.',
    },
    about: [
      {
        en:
          'Padmashali Vidya Sethu helps the Padmashali Vidyavardhaka Sangha stay connected with Padmashali children ' +
          'and young people from the age of five. Families register with a few basic details and build each ' +
          "member's profile over the years - from school and PUC to college, higher education and employment.",
      },
      {
        en:
          'These profiles help the Sangha understand the needs of its young members and plan scholarships, ' +
          'guidance, training, mentorship and job programs.',
      },
    ],
    category: 'communityAssociation',
    status: 'listed',
    displayOrder: 1,
    logo: {
      src: 'organizations/padmashali-vidya-sethu/logo.jpg',
      alt: { en: 'Padmashali Vidya Sethu logo' },
      width: 600,
      height: 600,
    },
    links: { application: null, registration: null, scholarships: null, jobs: null },
    // Registration starts on the application's own welcome screen (phone verification first), and the
    // application has no scholarship or job pages yet, so only the application link is published.
    enabledPublicLinks: ['application'],
    publicContact: null,
    appPolicyPages: true,
    highlights: [
      {
        title: { en: 'Student and member registry' },
        description: {
          en:
            'Families register children and young members after verifying their mobile number, and can add ' +
            'more family members later.',
        },
        availability: 'available',
      },
      {
        title: { en: 'Profile that grows with the member' },
        description: {
          en:
            'A dashboard shows how complete each profile is. Education, skills, career and employment ' +
            'sections are being added in phases.',
        },
        availability: 'available',
      },
      {
        title: { en: 'Scholarship support' },
        description: {
          en:
            'Member profiles help the Sangha plan scholarship programs. Online scholarship applications are ' +
            'planned for a later release.',
        },
        availability: 'planned',
      },
      {
        title: { en: 'Jobs and career opportunities' },
        description: {
          en:
            'Career interests and employment details will help the Sangha share relevant job opportunities, ' +
            'guidance and training.',
        },
        availability: 'planned',
      },
    ],
    branding: { useOwnBranding: true, primaryColor: '#1e5aa8', accentColor: '#e08a1e' },
  },
];

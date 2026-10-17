import type { SiteConfig } from '../app/core/site-config';

/** `ng serve` / `npm run build:dev`. Never used for a deployed site. */
export const environment: SiteConfig = {
  environmentName: 'development',
  siteUrl: 'http://localhost:4300',

  allowedLinkHosts: ['vidyasethu.co.in', '*.vidyasethu.co.in'],
  allowLocalhostLinks: true,

  // Development fallback: the PVS Flutter app run as a web app on this PC -
  //   cd Frontend/padmashali_vidya_setu
  //   flutter run -d chrome --web-port 8080 --dart-define-from-file=config/development.json
  // The organization page marks it as a development link.
  organizationLinks: {
    pvs: { application: 'http://localhost:8080/' },
  },

  enquiryEndpoint: null,

  company: {
    legalName: 'Swaprajna Technologies (OPC) Private Limited',
    email: null,
    phone: null,
    address: null,
  },

  legalPagesApproved: false,
};

import type { SiteConfig } from '../app/core/site-config';
import { shared } from './shared';

/**
 * Production build (`npm run build`). Everything here is public - it ships in the browser bundle.
 * Never put secrets, API keys or database details in this file.
 *
 * `scripts/postbuild.mjs` fails the build if the output contains a localhost / private-network URL.
 *
 * Only the data sources live here; everything else (legal approval, company details, allowed link hosts) is in
 * shared.ts, so development shows the site as production does.
 */
export const environment: SiteConfig = {
  ...shared,
  environmentName: 'production',
  siteUrl: 'https://vidyasethu.co.in',
  allowLocalhostLinks: false,

  // Per-environment organization destinations, keyed by organizationId. A value here replaces the link in
  // src/app/organizations/organizations.data.ts. null = not available yet (the page says so, no link is shown).
  //
  // Padmashali Vidya Sethu: its web app has its own address (README "Padmashali Vidya Sethu web app").
  organizationLinks: {
    pvs: { application: 'https://pvs.vidyasethu.co.in/' },
  },

  // Endpoint that accepts enquiry form posts (JSON): the shared enquiry service in the API, used by every
  // organization's forms; enquiries are emailed to the support inbox. null = forms disabled. README "Enquiry endpoint".
  enquiryEndpoint: 'https://api.pvs.vidyasethu.co.in/api/v1/enquiries',
};

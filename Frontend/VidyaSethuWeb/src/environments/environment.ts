import type { SiteConfig } from '../app/core/site-config';

/**
 * Production build (`npm run build`). Everything here is public - it ships in the browser bundle.
 * Never put secrets, API keys or database details in this file.
 *
 * `scripts/postbuild.mjs` fails the build if the output contains a localhost / private-network URL.
 */
export const environment: SiteConfig = {
  environmentName: 'production',
  siteUrl: 'https://vidyasethu.co.in',

  // Only these hosts may appear as organization links (exact host, or "*.domain" for subdomains).
  // Add an organization's own domain here when its destination is outside vidyasethu.co.in.
  allowedLinkHosts: ['vidyasethu.co.in', '*.vidyasethu.co.in'],
  allowLocalhostLinks: false,

  // Per-environment organization destinations, keyed by organizationId. A value here replaces the link in
  // src/app/organizations/organizations.data.ts. null = not available yet (the page says so, no link is shown).
  //
  // When Padmashali Vidya Sethu is deployed, set e.g. application: 'https://pvs.vidyasethu.co.in/'.
  organizationLinks: {
    pvs: { application: null },
  },

  // Endpoint that accepts enquiry form posts (JSON). null = online enquiries are not enabled yet: the forms say so
  // and never report a submission. See README "Enquiry endpoint" for the expected contract.
  enquiryEndpoint: null,

  // Public company contact details. null = not published yet. Only add details approved for publication.
  company: {
    legalName: 'Swaprajna Technologies (OPC) Private Limited',
    email: null,
    phone: null,
    address: null,
  },

  // Privacy / Terms / Accessibility pages show a "draft - under review" notice until legal review approves them.
  legalPagesApproved: false,
};

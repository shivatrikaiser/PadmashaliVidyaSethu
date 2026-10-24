import type { SiteConfig } from '../app/core/site-config';

/**
 * Settings that are the same in every build, so development shows the site exactly as production does. Only the
 * data sources (site address, organization destinations, enquiry endpoint, localhost links) differ per environment
 * and stay in environment.ts / environment.development.ts.
 *
 * Everything here is public - it ships in the browser bundle. Never put secrets here.
 */
export const shared = {
  // Only these hosts may appear as organization links (exact host, or "*.domain" for subdomains).
  // Add an organization's own domain here when its destination is outside vidyasethu.co.in.
  allowedLinkHosts: ['vidyasethu.co.in', '*.vidyasethu.co.in'],

  // Public company contact details. null = not published yet. Only add details approved for publication.
  company: {
    legalName: 'Swaprajna Technologies (OPC) Private Limited',
    email: 'support@iqexplore.com',
    phone: '7795276699',
    address: 'Swaprajna Technologies (OPC) Private Limited, Udupi.',
  },

  // Privacy / Terms / Accessibility pages (and the Padmashali Vidya Sethu app documents) show a
  // "draft - under review" notice while this is false. One switch for every build.
  legalPagesApproved: true,
} satisfies Pick<SiteConfig, 'allowedLinkHosts' | 'company' | 'legalPagesApproved'>;

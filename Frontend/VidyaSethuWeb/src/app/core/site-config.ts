import { InjectionToken } from '@angular/core';

import { environment } from '../../environments/environment';
import type { OrganizationLinks } from '../organizations/organization.model';

/** Build-time site configuration (src/environments). Public - it is part of the browser bundle. */
export interface SiteConfig {
  environmentName: 'development' | 'production';
  /** Canonical origin without a trailing slash, used for canonical / social-sharing URLs and the sitemap. */
  siteUrl: string;
  /** Hosts organization links may point to: exact host, or "*.example.org" for any subdomain. */
  allowedLinkHosts: readonly string[];
  /** Development only: also accept http://localhost / 127.0.0.1 links (shown as development links). */
  allowLocalhostLinks: boolean;
  /** Per-environment organization destinations by organizationId; replaces the links in organizations.data.ts. */
  organizationLinks: Readonly<Record<string, Partial<OrganizationLinks>>>;
  /** HTTPS endpoint accepting enquiry form posts, or null when online enquiries are not enabled. */
  enquiryEndpoint: string | null;
  company: CompanyContact;
  legalPagesApproved: boolean;
}

export interface CompanyContact {
  legalName: string;
  email: string | null;
  phone: string | null;
  address: string | null;
}

/** Injected rather than imported so tests can supply their own configuration. */
export const SITE_CONFIG = new InjectionToken<SiteConfig>('SITE_CONFIG', {
  providedIn: 'root',
  factory: () => environment,
});

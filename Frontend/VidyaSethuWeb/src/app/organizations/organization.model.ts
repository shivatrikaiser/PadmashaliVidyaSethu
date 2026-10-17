import type { LocalizedText } from '../i18n/localized-text';

/**
 * Public listing of an organization that uses VidyaSethu. Mirrors the planned VS_Organization table
 * (Database/vidyasethu/VS_Platform_Schema.sql) so the listings can later move to a secured platform-admin backend.
 *
 * This is NOT the organization's own data (members, records): those stay in the organization's application.
 */
export interface Organization {
  /** Stable identifier, never shown and never changed (e.g. "pvs"). */
  organizationId: string;
  /** URL segment: /organizations/{slug}. Lower-case letters, digits and hyphens. */
  slug: string;
  displayName: LocalizedText;
  /** Body that runs the organization, when different from the display name. */
  operatedBy: LocalizedText | null;
  description: LocalizedText;
  /** Longer text for the organization page; paragraphs. */
  about: readonly LocalizedText[];
  category: OrganizationCategory;
  /** Only "listed" organizations are shown anywhere on the public site. */
  status: OrganizationStatus;
  /** Lower first. */
  displayOrder: number;
  logo: OrganizationLogo | null;
  /** Default destinations; src/environments can replace them per environment. null = not available. */
  links: OrganizationLinks;
  /** Which links may be shown at all. A link is shown only if enabled here AND its URL passes validation. */
  enabledPublicLinks: readonly OrganizationLinkKind[];
  /** Only details the organization approved for publication. null = none published. */
  publicContact: OrganizationContact | null;
  highlights: readonly OrganizationHighlight[];
  branding: OrganizationBranding;
}

export type OrganizationCategory =
  | 'communityAssociation'
  | 'educationalTrust'
  | 'studentWelfare'
  | 'educationalInstitution'
  | 'other';

export type OrganizationStatus = 'listed' | 'unlisted';

export type OrganizationLinkKind = 'application' | 'registration' | 'scholarships' | 'jobs';

export type OrganizationLinks = Record<OrganizationLinkKind, string | null>;

export interface OrganizationLogo {
  /** Path under public/ (site-relative), e.g. "organizations/pvs/logo.jpg". */
  src: string;
  alt: LocalizedText;
  width: number;
  height: number;
}

export interface OrganizationContact {
  email: string | null;
  phone: string | null;
  website: string | null;
  address: LocalizedText | null;
}

/** A capability the organization offers through its portal. `planned` ones are labelled as such. */
export interface OrganizationHighlight {
  title: LocalizedText;
  description: LocalizedText;
  availability: 'available' | 'planned';
}

/**
 * Optional use of the organization's own identity on its page (accent colour around its logo / card).
 * The VidyaSethu layout itself is never re-themed.
 */
export interface OrganizationBranding {
  useOwnBranding: boolean;
  primaryColor: string | null;
  accentColor: string | null;
}

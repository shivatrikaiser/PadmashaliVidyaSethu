import { Injectable, InjectionToken, inject } from '@angular/core';

import { SITE_CONFIG } from '../core/site-config';
import { SafeLink, safeExternalLink } from '../core/safe-url';
import type { Organization, OrganizationLinkKind } from './organization.model';
import { ORGANIZATIONS } from './organizations.data';

export const ORGANIZATION_DATA = new InjectionToken<readonly Organization[]>('ORGANIZATION_DATA', {
  providedIn: 'root',
  factory: () => ORGANIZATIONS,
});

export const SLUG_PATTERN = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const COLOR_PATTERN = /^#[0-9a-fA-F]{6}$/;
const LOGO_PATTERN = /^organizations\/[a-z0-9-]+\/[a-z0-9._-]+\.(?:png|jpe?g|svg|webp)$/;

export interface ResolvedLink {
  kind: OrganizationLinkKind;
  link: SafeLink;
}

/** Public organization directory: listing, lookup and validated destinations. */
@Injectable({ providedIn: 'root' })
export class OrganizationDirectory {
  private readonly config = inject(SITE_CONFIG);
  private readonly all = inject(ORGANIZATION_DATA);

  /** Organizations approved for public listing, in display order. */
  listed(): Organization[] {
    return this.all
      .filter((o) => o.status === 'listed' && validateOrganization(o).length === 0)
      .sort(
        (a, b) =>
          a.displayOrder - b.displayOrder || a.displayName.en.localeCompare(b.displayName.en),
      );
  }

  bySlug(slug: string | null | undefined): Organization | null {
    return this.listed().find((o) => o.slug === slug) ?? null;
  }

  /** The validated destination for one link kind, or null when it is disabled, not configured or not allowed. */
  link(org: Organization, kind: OrganizationLinkKind): SafeLink | null {
    if (!org.enabledPublicLinks.includes(kind)) return null;
    const overrides = this.config.organizationLinks[org.organizationId] ?? {};
    const url = kind in overrides ? overrides[kind] : org.links[kind];
    return safeExternalLink(url, this.config);
  }

  /** Secondary links (registration, scholarships, jobs) that are enabled and valid. */
  deepLinks(org: Organization): ResolvedLink[] {
    const kinds: OrganizationLinkKind[] = ['registration', 'scholarships', 'jobs'];
    return kinds.flatMap((kind) => {
      const link = this.link(org, kind);
      return link ? [{ kind, link }] : [];
    });
  }
}

/** Data problems that keep a record off the public site (also asserted by the unit tests). */
export function validateOrganization(org: Organization): string[] {
  const problems: string[] = [];
  if (!org.organizationId.trim()) problems.push('organizationId is empty');
  if (!SLUG_PATTERN.test(org.slug))
    problems.push(`slug "${org.slug}" is not lower-case-with-hyphens`);
  if (!org.displayName.en.trim()) problems.push('displayName.en is empty');
  if (!org.description.en.trim()) problems.push('description.en is empty');
  if (org.logo && !LOGO_PATTERN.test(org.logo.src))
    problems.push(`logo "${org.logo.src}" is not under organizations/`);
  for (const color of [org.branding.primaryColor, org.branding.accentColor]) {
    if (color !== null && !COLOR_PATTERN.test(color))
      problems.push(`colour "${color}" is not #rrggbb`);
  }
  return problems;
}

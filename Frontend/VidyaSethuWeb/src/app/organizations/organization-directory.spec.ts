import { TestBed } from '@angular/core/testing';

import { environment as production } from '../../environments/environment';
import { environment as development } from '../../environments/environment.development';
import { SITE_CONFIG, SiteConfig } from '../core/site-config';
import type { Organization } from './organization.model';
import {
  ORGANIZATION_DATA,
  OrganizationDirectory,
  validateOrganization,
} from './organization-directory';
import { ORGANIZATIONS } from './organizations.data';

const pvs = ORGANIZATIONS.find((o) => o.organizationId === 'pvs')!;

function directory(
  config: SiteConfig,
  data: readonly Organization[] = ORGANIZATIONS,
): OrganizationDirectory {
  TestBed.resetTestingModule();
  TestBed.configureTestingModule({
    providers: [
      { provide: SITE_CONFIG, useValue: config },
      { provide: ORGANIZATION_DATA, useValue: data },
    ],
  });
  return TestBed.inject(OrganizationDirectory);
}

describe('organization data', () => {
  it('has no validation problems and unique ids and slugs', () => {
    for (const org of ORGANIZATIONS) expect(validateOrganization(org)).toEqual([]);
    expect(new Set(ORGANIZATIONS.map((o) => o.organizationId)).size).toBe(ORGANIZATIONS.length);
    expect(new Set(ORGANIZATIONS.map((o) => o.slug)).size).toBe(ORGANIZATIONS.length);
  });

  it('lists Padmashali Vidya Sethu first, at /organizations/padmashali-vidya-sethu', () => {
    const listed = directory(production).listed();
    expect(listed[0].organizationId).toBe('pvs');
    expect(listed[0].displayName.en).toBe('Padmashali Vidya Sethu');
    expect(listed[0].slug).toBe('padmashali-vidya-sethu');
  });

  it('only publishes the PVS application link (no unverified deep links)', () => {
    expect(pvs.enabledPublicLinks).toEqual(['application']);
  });
});

describe('OrganizationDirectory', () => {
  it('shows only listed, valid organizations, in display order', () => {
    const data: Organization[] = [
      { ...pvs, organizationId: 'b', slug: 'second', displayOrder: 2 },
      { ...pvs, organizationId: 'hidden', slug: 'hidden', status: 'unlisted' },
      { ...pvs, organizationId: 'bad', slug: 'Bad Slug!' },
      { ...pvs, organizationId: 'a', slug: 'first', displayOrder: 1 },
    ];
    const dir = directory(production, data);
    expect(dir.listed().map((o) => o.slug)).toEqual(['first', 'second']);
    expect(dir.bySlug('hidden')).toBeNull();
    expect(dir.bySlug('missing')).toBeNull();
    expect(dir.bySlug('second')?.organizationId).toBe('b');
  });

  it('production: the PVS destination is its web app at vidyasethu.co.in/pvs', () => {
    expect(directory(production).link(pvs, 'application')).toEqual({
      href: 'https://vidyasethu.co.in/pvs/',
      development: false,
    });
  });

  it('without a configured destination no link is offered', () => {
    expect(directory({ ...production, organizationLinks: { pvs: { application: null } } }).link(pvs, 'application')).toBeNull();
  });

  it('development: the PVS destination is the local development fallback, marked as such', () => {
    expect(directory(development).link(pvs, 'application')).toEqual({
      href: 'http://localhost:8080/',
      development: true,
    });
  });

  it('uses a configured production destination once it is set', () => {
    const config: SiteConfig = {
      ...production,
      organizationLinks: { pvs: { application: 'https://pvs.vidyasethu.co.in/' } },
    };
    expect(directory(config).link(pvs, 'application')).toEqual({
      href: 'https://pvs.vidyasethu.co.in/',
      development: false,
    });
  });

  it('never offers a destination that fails validation', () => {
    for (const url of [
      'https://evil.example/',
      'http://pvs.vidyasethu.co.in/',
      'javascript:alert(1)',
      'http://localhost:8080/',
    ]) {
      const config: SiteConfig = {
        ...production,
        organizationLinks: { pvs: { application: url } },
      };
      expect(directory(config).link(pvs, 'application')).toBeNull();
    }
  });

  it('ignores links that are not enabled for the organization', () => {
    const config: SiteConfig = {
      ...production,
      organizationLinks: { pvs: { jobs: 'https://pvs.vidyasethu.co.in/jobs' } },
    };
    const dir = directory(config);
    expect(dir.link(pvs, 'jobs')).toBeNull();
    expect(dir.deepLinks(pvs)).toEqual([]);
  });
});

describe('production environment', () => {
  it('contains no localhost or private-network addresses and does not allow them as links', () => {
    const text = JSON.stringify(production);
    expect(text).not.toMatch(/localhost|127\.0\.0\.1|10\.0\.2\.2|192\.168\./);
    expect(production.allowLocalhostLinks).toBe(false);
    expect(production.siteUrl).toBe('https://vidyasethu.co.in');
  });
});

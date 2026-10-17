import { TestBed } from '@angular/core/testing';
import { DOCUMENT } from '@angular/core';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';

import { environment as production } from '../../../environments/environment';
import { environment as development } from '../../../environments/environment.development';
import { SITE_CONFIG, SiteConfig } from '../../core/site-config';
import { routes } from '../../app.routes';

const PVS_URL = '/organizations/padmashali-vidya-sethu';

async function open(config: SiteConfig, url = PVS_URL): Promise<HTMLElement> {
  TestBed.configureTestingModule({
    providers: [
      provideRouter(routes, withComponentInputBinding()),
      { provide: SITE_CONFIG, useValue: config },
    ],
  });
  const harness = await RouterTestingHarness.create();
  await harness.navigateByUrl(url);
  await harness.fixture.whenStable();
  return harness.routeNativeElement!;
}

describe('OrganizationPage (Padmashali Vidya Sethu)', () => {
  it('shows the organization name, operator, logo and highlights', async () => {
    const el = await open(production);
    expect(el.querySelector('h1')?.textContent).toContain('Padmashali Vidya Sethu');
    expect(el.textContent).toContain('Run for Padmashali Vidyavardhaka Sangha');
    const logo = el.querySelector<HTMLImageElement>('img.logo');
    expect(logo?.getAttribute('src')).toBe('/organizations/padmashali-vidya-sethu/logo.jpg');
    expect(logo?.alt).toBe('Padmashali Vidya Sethu logo');
    expect(el.textContent).toContain('Student and member registry');
    expect(el.textContent).toContain('Scholarship support');
    expect(el.textContent).toContain('Jobs and career opportunities');
  });

  it('production without a configured destination: explains the portal is not available and shows no link', async () => {
    const el = await open(production);
    expect(el.querySelector('[data-testid="portal-unavailable"]')?.textContent).toContain(
      'not yet publicly available',
    );
    expect(el.querySelector('[data-testid="open-portal"]')).toBeNull();
    expect(el.querySelector('[data-testid="dev-link"]')).toBeNull();
  });

  it('with a configured destination: "Open Padmashali Vidya Sethu" goes there', async () => {
    const el = await open({
      ...production,
      organizationLinks: { pvs: { application: 'https://pvs.vidyasethu.co.in/' } },
    });
    const button = el.querySelector<HTMLAnchorElement>('[data-testid="open-portal"]');
    expect(button?.textContent).toContain('Open Padmashali Vidya Sethu');
    expect(button?.getAttribute('href')).toBe('https://pvs.vidyasethu.co.in/');
    expect(el.querySelector('[data-testid="dev-link"]')).toBeNull();
    expect(el.querySelector('[data-testid="portal-unavailable"]')).toBeNull();
  });

  it('development: links to the local application and labels it as a development link', async () => {
    const el = await open(development);
    const button = el.querySelector<HTMLAnchorElement>('[data-testid="open-portal"]');
    expect(button?.getAttribute('href')).toBe('http://localhost:8080/');
    expect(el.querySelector('[data-testid="dev-link"]')).toBeTruthy();
  });

  it('an invalid destination is treated as not configured', async () => {
    const el = await open({
      ...production,
      organizationLinks: { pvs: { application: 'javascript:alert(1)' } },
    });
    expect(el.querySelector('[data-testid="open-portal"]')).toBeNull();
    expect(el.querySelector('[data-testid="portal-unavailable"]')).toBeTruthy();
  });

  it('sets the page title, description and canonical URL from the organization', async () => {
    await open(production);
    const doc = TestBed.inject(DOCUMENT);
    expect(doc.title).toBe('Padmashali Vidya Sethu | VidyaSethu');
    expect(doc.querySelector('link[rel="canonical"]')?.getAttribute('href')).toBe(
      'https://vidyasethu.co.in/organizations/padmashali-vidya-sethu',
    );
    expect(doc.querySelector('meta[name="description"]')?.getAttribute('content')).toContain(
      'Padmashali',
    );
  });

  it('an unknown organization shows "Organization not found"', async () => {
    const el = await open(production, '/organizations/unknown-org');
    expect(el.querySelector('h1')?.textContent).toContain('Organization not found');
  });
});

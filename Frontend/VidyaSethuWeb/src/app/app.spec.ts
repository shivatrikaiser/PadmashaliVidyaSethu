import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { Router, provideRouter, withComponentInputBinding } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';
import { Meta, Title } from '@angular/platform-browser';

import { App } from './app';
import { routes } from './app.routes';
import { NAV_LINKS } from './layout/nav-links';

const PAGES: [path: string, heading: RegExp][] = [
  ['/', /Connecting Communities to a Brighter Future/],
  ['/about', /About VidyaSethu/],
  ['/features', /Features/],
  ['/organizations', /Participating organizations/],
  ['/organizations/padmashali-vidya-sethu', /Padmashali Vidya Sethu/],
  ['/for-organizations', /Give your members a portal of their own/],
  ['/for-students', /For students/],
  ['/for-job-seekers', /For job seekers/],
  ['/contact', /Contact us/],
  ['/privacy', /Privacy notice/],
  ['/terms', /Terms of use/],
  ['/accessibility', /Accessibility/],
  ['/no-such-page', /Page not found/],
];

describe('App', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        provideRouter(routes, withComponentInputBinding()),
        provideHttpClient(),
        provideHttpClientTesting(),
      ],
    });
  });

  it('renders header, main landmark and footer', async () => {
    const fixture = TestBed.createComponent(App);
    await fixture.whenStable();
    const el = fixture.nativeElement as HTMLElement;
    expect(el.querySelector('header nav')).toBeTruthy();
    expect(el.querySelector('main#main')).toBeTruthy();
    expect(el.querySelector('footer')).toBeTruthy();
    expect(el.querySelector('.skip-link')?.textContent).toContain('Skip to main content');
  });

  it('has a link for every main navigation entry, in header and footer', async () => {
    const fixture = TestBed.createComponent(App);
    await fixture.whenStable();
    const el = fixture.nativeElement as HTMLElement;
    for (const link of NAV_LINKS) {
      expect(el.querySelector(`header a[href="${link.path}"]`), `header ${link.path}`).toBeTruthy();
      expect(el.querySelector(`footer a[href="${link.path}"]`), `footer ${link.path}`).toBeTruthy();
    }
    for (const legal of ['/privacy', '/terms', '/accessibility']) {
      expect(el.querySelector(`footer a[href="${legal}"]`), legal).toBeTruthy();
    }
  });

  it('every internal link on every page leads to a real page (not the 404 page)', async () => {
    const harness = await RouterTestingHarness.create();
    const router = TestBed.inject(Router);
    const linked = new Set<string>();
    for (const [path] of PAGES.slice(0, -1)) {
      await harness.navigateByUrl(path);
      harness.routeNativeElement!.querySelectorAll('a[href^="/"]').forEach((a) => {
        linked.add(a.getAttribute('href')!.split('#')[0]);
      });
    }
    for (const href of linked) {
      await router.navigateByUrl(href);
      harness.detectChanges();
      expect(harness.routeNativeElement!.textContent, href).not.toContain('Page not found');
    }
  });

  it('home page states that VidyaSethu is a product of Swaprajna Technologies', async () => {
    const harness = await RouterTestingHarness.create();
    await harness.navigateByUrl('/');
    expect(
      harness
        .routeNativeElement!.querySelector('[data-testid="product-of"]')
        ?.textContent?.replace(/\s+/g, ' ')
        .trim(),
    ).toBe('Product of Swaprajna Technologies (OPC) Private Limited');
  });

  it.each(PAGES)('%s renders its heading, title and description', async (path, heading) => {
    const harness = await RouterTestingHarness.create();
    TestBed.createComponent(App); // starts the Seo service, as in the real app
    await harness.navigateByUrl(path);
    await harness.fixture.whenStable();
    const h1 = harness.routeNativeElement!.querySelector('h1');
    expect(h1?.textContent).toMatch(heading);
    expect(harness.routeNativeElement!.querySelectorAll('h1').length).toBe(1);
    expect(TestBed.inject(Title).getTitle()).not.toBe('');
    expect(TestBed.inject(Meta).getTag('name="description"')?.content).toBeTruthy();
  });
});

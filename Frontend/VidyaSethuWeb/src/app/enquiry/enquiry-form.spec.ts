import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { environment as production } from '../../environments/environment';
import { SITE_CONFIG, SiteConfig } from '../core/site-config';
import { EnquiryForm } from './enquiry-form';
import { ENQUIRY_MIN_FILL_MS, EnquiryPayload } from './enquiry.service';

const ENDPOINT = 'https://api.vidyasethu.co.in/enquiries';

function setup(
  config: SiteConfig,
  minFillMs = 0,
): { fixture: ComponentFixture<EnquiryForm>; http: HttpTestingController } {
  TestBed.configureTestingModule({
    imports: [EnquiryForm],
    providers: [
      provideRouter([]),
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: SITE_CONFIG, useValue: config },
      { provide: ENQUIRY_MIN_FILL_MS, useValue: minFillMs },
    ],
  });
  const fixture = TestBed.createComponent(EnquiryForm);
  fixture.detectChanges();
  return { fixture, http: TestBed.inject(HttpTestingController) };
}

function el(fixture: ComponentFixture<EnquiryForm>): HTMLElement {
  return fixture.nativeElement as HTMLElement;
}

function type(fixture: ComponentFixture<EnquiryForm>, selector: string, value: string): void {
  const input = el(fixture).querySelector<HTMLInputElement | HTMLTextAreaElement>(selector)!;
  input.value = value;
  input.dispatchEvent(new Event('input'));
}

function fillValid(fixture: ComponentFixture<EnquiryForm>): void {
  type(fixture, '#enquiry-name', 'Asha Rao');
  type(fixture, '#enquiry-email', 'asha@example.in');
  type(fixture, '#enquiry-message', 'We would like a demo for our trust.');
  const consent = el(fixture).querySelector<HTMLInputElement>('#enquiry-consent')!;
  consent.click();
  fixture.detectChanges();
}

function submit(fixture: ComponentFixture<EnquiryForm>): void {
  el(fixture).querySelector('form')!.dispatchEvent(new Event('submit'));
  fixture.detectChanges();
}

describe('EnquiryForm', () => {
  describe('without a configured endpoint (current production)', () => {
    it('says online enquiries are not open, disables the form and never reports success', () => {
      const { fixture, http } = setup(production);
      expect(el(fixture).querySelector('[data-testid="enquiry-disabled"]')?.textContent).toContain(
        'Online enquiries are not open yet',
      );
      expect(
        el(fixture).querySelector<HTMLButtonElement>('[data-testid="enquiry-submit"]')!.disabled,
      ).toBe(true);
      expect(el(fixture).querySelector<HTMLInputElement>('#enquiry-name')!.disabled).toBe(true);
      submit(fixture);
      expect(el(fixture).querySelector('[data-testid="enquiry-success"]')).toBeNull();
      http.expectNone(() => true);
    });
  });

  describe('with an endpoint', () => {
    const config: SiteConfig = { ...production, enquiryEndpoint: ENDPOINT };

    it('validates required fields and sends nothing when invalid', () => {
      const { fixture, http } = setup(config);
      submit(fixture);
      const text = el(fixture).textContent!;
      expect(el(fixture).querySelector('[data-testid="enquiry-invalid"]')).toBeTruthy();
      expect(text).toContain('Please enter your name');
      expect(text).toContain('Please give an email address or a phone number.');
      expect(text).toContain('Please write between 10 and 2000 characters.');
      expect(text).toContain('Please confirm that we may use your details to reply.');
      expect(el(fixture).querySelector('#enquiry-name')!.getAttribute('aria-invalid')).toBe('true');
      http.expectNone(ENDPOINT);
    });

    it('rejects a malformed email and phone', () => {
      const { fixture } = setup(config);
      fillValid(fixture);
      type(fixture, '#enquiry-email', 'not-an-email');
      type(fixture, '#enquiry-phone', 'abc');
      submit(fixture);
      expect(el(fixture).textContent).toContain('Please enter a valid email address.');
      expect(el(fixture).textContent).toContain('Please enter a valid phone number');
    });

    it('accepts a phone number instead of an email', () => {
      const { fixture, http } = setup(config);
      fillValid(fixture);
      type(fixture, '#enquiry-email', '');
      type(fixture, '#enquiry-phone', '+91 98450 12345');
      submit(fixture);
      const req = http.expectOne(ENDPOINT);
      expect((req.request.body as EnquiryPayload).phone).toBe('+91 98450 12345');
      expect((req.request.body as EnquiryPayload).email).toBeNull();
      req.flush({});
    });

    it('reports success only after the endpoint confirms', () => {
      const { fixture, http } = setup(config);
      fillValid(fixture);
      submit(fixture);

      const req = http.expectOne(ENDPOINT);
      expect(req.request.method).toBe('POST');
      expect(req.request.body).toMatchObject({
        category: 'general',
        name: 'Asha Rao',
        email: 'asha@example.in',
        phone: null,
        message: 'We would like a demo for our trust.',
        consent: true,
        locale: 'en',
      });
      fixture.detectChanges();
      expect(el(fixture).querySelector('[data-testid="enquiry-success"]')).toBeNull();
      expect(el(fixture).querySelector('[data-testid="enquiry-submit"]')!.textContent).toContain(
        'Sending',
      );

      req.flush({ ok: true }, { status: 201, statusText: 'Created' });
      fixture.detectChanges();
      expect(el(fixture).querySelector('[data-testid="enquiry-success"]')?.textContent).toContain(
        'your enquiry has been sent',
      );
    });

    it('shows an error, not success, when the endpoint fails', () => {
      const { fixture, http } = setup(config);
      fillValid(fixture);
      submit(fixture);
      http.expectOne(ENDPOINT).flush('nope', { status: 500, statusText: 'Server Error' });
      fixture.detectChanges();
      expect(el(fixture).querySelector('[data-testid="enquiry-error"]')).toBeTruthy();
      expect(el(fixture).querySelector('[data-testid="enquiry-success"]')).toBeNull();
    });

    it('does not send when the honeypot field is filled', () => {
      const { fixture, http } = setup(config);
      fillValid(fixture);
      type(fixture, '#enquiry-website', 'http://spam.example');
      submit(fixture);
      http.expectNone(ENDPOINT);
      expect(el(fixture).querySelector('[data-testid="enquiry-success"]')).toBeNull();
    });

    it('does not send a form completed faster than a person could', () => {
      const { fixture, http } = setup(config, 60_000);
      fillValid(fixture);
      submit(fixture);
      http.expectNone(ENDPOINT);
      expect(el(fixture).querySelector('[data-testid="enquiry-too-fast"]')).toBeTruthy();
    });

    it('ignores an endpoint that is not https on an allowed host', () => {
      const { fixture } = setup({ ...production, enquiryEndpoint: 'http://evil.example/collect' });
      expect(el(fixture).querySelector('[data-testid="enquiry-disabled"]')).toBeTruthy();
    });
  });
});

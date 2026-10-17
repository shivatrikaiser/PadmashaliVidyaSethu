import { HttpClient } from '@angular/common/http';
import { Injectable, InjectionToken, inject } from '@angular/core';
import { Observable, map, timeout } from 'rxjs';

import { SITE_CONFIG } from '../core/site-config';
import { safeExternalLink } from '../core/safe-url';
import type { Locale } from '../i18n/localized-text';

export type EnquiryCategory = 'organization' | 'general' | 'partnership' | 'feedback' | 'privacy';

export const ENQUIRY_CATEGORIES: readonly EnquiryCategory[] = [
  'organization',
  'general',
  'partnership',
  'feedback',
  'privacy',
];

/** JSON body posted to the enquiry endpoint. The endpoint must validate every field again. */
export interface EnquiryPayload {
  category: EnquiryCategory;
  name: string;
  organization: string | null;
  email: string | null;
  phone: string | null;
  message: string;
  consent: true;
  locale: Locale;
  /** Page the form was sent from, e.g. "/contact". */
  page: string;
  /** Time between the form appearing and being sent - a spam signal for the endpoint. */
  elapsedMs: number;
}

/** A person needs at least this long to fill the form; faster submissions are treated as automated. */
export const ENQUIRY_MIN_FILL_MS = new InjectionToken<number>('ENQUIRY_MIN_FILL_MS', {
  providedIn: 'root',
  factory: () => 3000,
});

@Injectable({ providedIn: 'root' })
export class EnquiryService {
  private readonly http = inject(HttpClient);
  private readonly config = inject(SITE_CONFIG);

  /**
   * The configured endpoint if it is usable: a same-site path ("/api/enquiries") or an https URL on an allowed host
   * (localhost in development). null = online enquiries are not enabled.
   */
  readonly endpoint: string | null = this.resolveEndpoint();

  /** Completes only when the endpoint answered with a 2xx status; any other outcome is an error. */
  submit(payload: EnquiryPayload): Observable<void> {
    if (!this.endpoint) throw new Error('Enquiry endpoint is not configured.');
    return this.http.post(this.endpoint, payload, { observe: 'response' }).pipe(
      timeout(20000),
      map(() => undefined),
    );
  }

  private resolveEndpoint(): string | null {
    const value = this.config.enquiryEndpoint?.trim();
    if (!value) return null;
    if (/^\/(?!\/)/.test(value)) return value;
    return safeExternalLink(value, this.config)?.href ?? null;
  }
}

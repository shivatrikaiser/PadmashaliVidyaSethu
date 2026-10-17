import { DOCUMENT, Injectable, computed, effect, inject, signal } from '@angular/core';

import { en } from './en';
import { Locale, LocalizedText, localize } from './localized-text';

/** Every catalog has the English catalog's shape, so a missing translation is a compile error. */
export type Messages = typeof en;

/**
 * Catalogs available to visitors. To add Kannada: create i18n/kn/index.ts exporting `kn: Messages`
 * (font stack already includes Noto Sans Kannada), add it here, then show a language switch in the header.
 */
const CATALOGS: Partial<Record<Locale, Messages>> = { en };

export const SUPPORTED_LOCALES = Object.keys(CATALOGS) as Locale[];

@Injectable({ providedIn: 'root' })
export class I18n {
  private readonly document = inject(DOCUMENT);

  readonly locale = signal<Locale>('en');
  readonly messages = computed<Messages>(() => CATALOGS[this.locale()] ?? en);

  constructor() {
    effect(() => this.document.documentElement.setAttribute('lang', this.locale()));
  }

  /** Text stored with data (organization listings) in the current locale, falling back to English. */
  text(value: LocalizedText): string {
    return localize(value, this.locale());
  }
}

/** Locales the site can be translated into. Add a catalog in i18n/ and list it in SUPPORTED_LOCALES to enable one. */
export type Locale = 'en' | 'kn';

/** Text stored with data (organization listings). English is required; other locales fall back to it. */
export type LocalizedText = { en: string } & Partial<Record<Exclude<Locale, 'en'>, string>>;

export function localize(text: LocalizedText, locale: Locale): string {
  return (locale !== 'en' ? text[locale] : undefined) ?? text.en;
}

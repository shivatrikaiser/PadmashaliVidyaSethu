import { DOCUMENT, Injectable, inject } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
import { ActivatedRoute, NavigationEnd, Router } from '@angular/router';
import { filter } from 'rxjs';

import { I18n, Messages } from '../i18n/i18n';
import { SITE_CONFIG } from './site-config';

/** Page keys with a fixed title/description in the catalog (route data `seo`). */
export type SeoPage = Exclude<keyof Messages['seo'], 'organizationPage'>;

export interface PageMeta {
  title: string;
  description: string;
  /** Default: the current path. */
  path?: string;
  /** Default: the VidyaSethu sharing image. Site-relative path. */
  image?: string;
  noIndex?: boolean;
}

/**
 * Title, description, canonical URL and social-sharing tags. Runs during prerendering too, so every generated page
 * carries its own tags. Routes with `data.seo` are handled here on navigation; pages with dynamic content (an
 * organization) call `set()` themselves.
 */
@Injectable({ providedIn: 'root' })
export class Seo {
  private readonly title = inject(Title);
  private readonly meta = inject(Meta);
  private readonly document = inject(DOCUMENT);
  private readonly router = inject(Router);
  private readonly config = inject(SITE_CONFIG);
  private readonly i18n = inject(I18n);

  init(): void {
    this.router.events.pipe(filter((e) => e instanceof NavigationEnd)).subscribe(() => {
      let route: ActivatedRoute = this.router.routerState.root;
      while (route.firstChild) route = route.firstChild;
      const page = route.snapshot.data['seo'] as SeoPage | undefined;
      if (!page) return;
      const text = this.i18n.messages().seo[page];
      this.set({ ...text, noIndex: page === 'notFound' });
    });
  }

  set(page: PageMeta): void {
    const path = page.path ?? this.router.url.split(/[?#]/)[0];
    const url = this.config.siteUrl + (path === '/' ? '/' : path.replace(/\/$/, ''));
    const image = `${this.config.siteUrl}/${(page.image ?? 'og-image.png').replace(/^\//, '')}`;

    this.title.setTitle(page.title);
    this.meta.updateTag({ name: 'description', content: page.description });
    this.meta.updateTag({ name: 'robots', content: page.noIndex ? 'noindex' : 'index, follow' });
    this.meta.updateTag({ property: 'og:type', content: 'website' });
    this.meta.updateTag({ property: 'og:site_name', content: this.i18n.messages().siteName });
    this.meta.updateTag({ property: 'og:title', content: page.title });
    this.meta.updateTag({ property: 'og:description', content: page.description });
    this.meta.updateTag({ property: 'og:url', content: url });
    this.meta.updateTag({ property: 'og:image', content: image });
    // A page-specific image (an organization logo) is square: use the small card for it.
    this.meta.updateTag({
      name: 'twitter:card',
      content: page.image ? 'summary' : 'summary_large_image',
    });
    this.meta.updateTag({ name: 'twitter:title', content: page.title });
    this.meta.updateTag({ name: 'twitter:description', content: page.description });
    this.meta.updateTag({ name: 'twitter:image', content: image });
    this.canonical(page.noIndex ? null : url);
  }

  private canonical(url: string | null): void {
    let link = this.document.head.querySelector<HTMLLinkElement>('link[rel="canonical"]');
    if (!url) {
      link?.remove();
      return;
    }
    if (!link) {
      link = this.document.createElement('link');
      link.setAttribute('rel', 'canonical');
      this.document.head.appendChild(link);
    }
    link.setAttribute('href', url);
  }
}

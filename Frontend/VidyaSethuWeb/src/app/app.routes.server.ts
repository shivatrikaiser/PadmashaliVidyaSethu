import { inject } from '@angular/core';
import { RenderMode, ServerRoute } from '@angular/ssr';

import { OrganizationDirectory } from './organizations/organization-directory';

/** Build-time prerendering: one static HTML file per route. No server runs in production. */
export const serverRoutes: ServerRoute[] = [
  {
    path: 'organizations/:slug',
    renderMode: RenderMode.Prerender,
    // Only organizations approved for listing get a page.
    getPrerenderParams: async () =>
      inject(OrganizationDirectory)
        .listed()
        .map((org) => ({ slug: org.slug })),
  },
  { path: '**', renderMode: RenderMode.Prerender },
];

import { Routes } from '@angular/router';

import type { SeoPage } from './core/seo';
import { Home } from './pages/home/home';
import { NotFound } from './pages/not-found/not-found';

const seo = (page: SeoPage) => ({ seo: page });

/**
 * Every route is prerendered to its own HTML file (app.routes.server.ts), so it works on direct refresh without a
 * server. Page titles / descriptions come from the `seo` key (i18n catalog), applied by core/seo.ts.
 */
export const routes: Routes = [
  { path: '', component: Home, data: seo('home') },
  {
    path: 'about',
    loadComponent: () => import('./pages/about/about').then((m) => m.About),
    data: seo('about'),
  },
  {
    path: 'features',
    loadComponent: () => import('./pages/features/features').then((m) => m.Features),
    data: seo('features'),
  },
  {
    path: 'organizations',
    loadComponent: () => import('./pages/organizations/organizations').then((m) => m.Organizations),
    data: seo('organizations'),
  },
  // Padmashali Vidya Sethu app documents (linked from Google Play and from the app).
  {
    path: 'organizations/padmashali-vidya-sethu/privacy',
    loadComponent: () => import('./pages/legal/legal').then((m) => m.Legal),
    data: { ...seo('pvsPrivacy'), document: 'pvsPrivacy' },
  },
  {
    path: 'organizations/padmashali-vidya-sethu/terms',
    loadComponent: () => import('./pages/legal/legal').then((m) => m.Legal),
    data: { ...seo('pvsTerms'), document: 'pvsTerms' },
  },
  {
    path: 'organizations/padmashali-vidya-sethu/delete-account',
    loadComponent: () => import('./pages/legal/legal').then((m) => m.Legal),
    data: { ...seo('pvsDeleteAccount'), document: 'pvsDeleteAccount' },
  },
  {
    // Title and description come from the organization record (set by the page).
    path: 'organizations/:slug',
    loadComponent: () =>
      import('./pages/organization/organization-page').then((m) => m.OrganizationPage),
  },
  {
    path: 'for-organizations',
    loadComponent: () =>
      import('./pages/for-organizations/for-organizations').then((m) => m.ForOrganizations),
    data: seo('forOrganizations'),
  },
  {
    path: 'for-students',
    loadComponent: () => import('./pages/audience/audience').then((m) => m.Audience),
    data: { ...seo('forStudents'), audience: 'students' },
  },
  {
    path: 'for-job-seekers',
    loadComponent: () => import('./pages/audience/audience').then((m) => m.Audience),
    data: { ...seo('forJobSeekers'), audience: 'jobSeekers' },
  },
  {
    path: 'contact',
    loadComponent: () => import('./pages/contact/contact').then((m) => m.Contact),
    data: seo('contact'),
  },
  {
    path: 'privacy',
    loadComponent: () => import('./pages/legal/legal').then((m) => m.Legal),
    data: { ...seo('privacy'), document: 'privacy' },
  },
  {
    path: 'terms',
    loadComponent: () => import('./pages/legal/legal').then((m) => m.Legal),
    data: { ...seo('terms'), document: 'terms' },
  },
  {
    path: 'accessibility',
    loadComponent: () => import('./pages/legal/legal').then((m) => m.Legal),
    data: { ...seo('accessibility'), document: 'accessibility' },
  },
  // Prerendered as /404/index.html - the host serves it, with status 404, for any unknown address.
  { path: '404', component: NotFound, data: seo('notFound') },
  { path: '**', component: NotFound, data: seo('notFound') },
];

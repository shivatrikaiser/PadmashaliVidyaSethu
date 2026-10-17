import type { Messages } from '../i18n/i18n';

export interface NavLink {
  path: string;
  label: keyof Messages['nav'];
}

/** Main navigation (header). The footer adds the legal pages. */
export const NAV_LINKS: readonly NavLink[] = [
  { path: '/about', label: 'about' },
  { path: '/features', label: 'features' },
  { path: '/organizations', label: 'organizations' },
  { path: '/for-organizations', label: 'forOrganizations' },
  { path: '/for-students', label: 'forStudents' },
  { path: '/for-job-seekers', label: 'forJobSeekers' },
  { path: '/contact', label: 'contact' },
];

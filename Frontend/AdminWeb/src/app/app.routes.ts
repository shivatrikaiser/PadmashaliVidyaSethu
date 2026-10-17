import { Routes } from '@angular/router';

import { adminGuard, superAdminGuard } from './core/admin.guard';
import { Shell } from './layout/shell';
import { Login } from './pages/login/login';

/** Pages are loaded on first visit, so e.g. the chart library only downloads with the dashboard. */
export const routes: Routes = [
  { path: 'login', component: Login, title: 'Sign in | PVS Admin' },
  {
    path: '',
    component: Shell,
    canActivate: [adminGuard],
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
      {
        path: 'dashboard',
        loadComponent: () => import('./pages/dashboard/dashboard').then((m) => m.Dashboard),
        title: 'Dashboard | PVS Admin',
      },
      {
        path: 'members',
        loadComponent: () => import('./pages/members/members').then((m) => m.Members),
        title: 'Members | PVS Admin',
      },
      {
        path: 'members/:registrationId',
        loadComponent: () => import('./pages/members/member-detail').then((m) => m.MemberDetail),
        title: 'Member | PVS Admin',
      },
      {
        path: 'other-values',
        canActivate: [superAdminGuard],
        loadComponent: () => import('./pages/other-values/other-values').then((m) => m.OtherValues),
        title: '"Other" values | PVS Admin',
      },
      {
        path: 'lists',
        canActivate: [superAdminGuard],
        loadComponent: () => import('./pages/lists/lists').then((m) => m.Lists),
        title: 'Master lists | PVS Admin',
      },
      {
        path: 'locations',
        loadComponent: () => import('./pages/locations/locations').then((m) => m.Locations),
        title: 'Locations | PVS Admin',
      },
      {
        path: 'branding',
        canActivate: [superAdminGuard],
        loadComponent: () => import('./pages/branding/branding').then((m) => m.Branding),
        title: 'Splash sponsor | PVS Admin',
      },
      {
        path: 'admin-users',
        canActivate: [superAdminGuard],
        loadComponent: () => import('./pages/admin-users/admin-users').then((m) => m.AdminUsers),
        title: 'Admin users | PVS Admin',
      },
    ],
  },
  { path: '**', redirectTo: '' },
];

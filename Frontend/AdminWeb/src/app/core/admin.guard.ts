import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { catchError, map, of } from 'rxjs';

import { AuthService } from './auth.service';

/** Admin pages: requires a signed-in account that the API confirms as Admin / Super Admin. */
export const adminGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (!auth.isSignedIn()) return router.createUrlTree(['/login']);
  if (auth.admin()) return true;
  return auth.loadAdmin().pipe(
    map(() => true),
    catchError(() => of(router.createUrlTree(['/login']))),
  );
};

/** Super Admin pages ("Other" values, master lists, admin users). Runs after adminGuard, so the profile is loaded. */
export const superAdminGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  return auth.isSuperAdmin() || inject(Router).createUrlTree(['/dashboard']);
};

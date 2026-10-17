import { HttpErrorResponse, HttpInterceptorFn, HttpRequest } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, switchMap, throwError } from 'rxjs';

import { environment } from '../../environments/environment';
import { AuthService } from './auth.service';

const ANONYMOUS = ['/api/v1/auth/verification-codes', '/api/v1/auth/token/refresh'];

/** Adds the bearer token to API calls; on 401 refreshes once and retries, otherwise returns to sign-in. */
export const authInterceptor: HttpInterceptorFn = (request, next) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (!isApi(request) || ANONYMOUS.some((path) => request.url.includes(path))) return next(request);

  const withToken = (token: string | null) =>
    token ? request.clone({ setHeaders: { Authorization: `Bearer ${token}` } }) : request;

  return next(withToken(auth.accessToken)).pipe(
    catchError((error: unknown) => {
      if (!(error instanceof HttpErrorResponse) || error.status !== 401 || !auth.isSignedIn()) {
        return throwError(() => error);
      }
      return auth.refresh().pipe(
        switchMap((token) => next(withToken(token))),
        catchError((refreshError: unknown) => {
          void router.navigate(['/login']);
          return throwError(() => refreshError);
        }),
      );
    }),
  );
};

function isApi(request: HttpRequest<unknown>): boolean {
  return request.url.startsWith(`${environment.apiBaseUrl}/api/`);
}

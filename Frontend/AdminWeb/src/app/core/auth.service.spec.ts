import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { environment } from '../../environments/environment';
import { authInterceptor } from './auth.interceptor';
import { AuthService, NO_ADMIN_ACCESS } from './auth.service';

const api = `${environment.apiBaseUrl}/api/v1`;
const tokens = { accessToken: 'access-1', refreshToken: 'refresh-1' };

describe('AuthService', () => {
  let auth: AuthService;
  let http: HttpTestingController;

  beforeEach(() => {
    sessionStorage.clear();
    TestBed.configureTestingModule({
      providers: [
        provideRouter([]),
        provideHttpClient(withInterceptors([authInterceptor])),
        provideHttpClientTesting(),
      ],
    });
    auth = TestBed.inject(AuthService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  function verify(): { result: unknown; error: unknown } {
    const outcome: { result: unknown; error: unknown } = { result: null, error: null };
    auth.signIn('9876500011', 'Secret#2026').subscribe({
      next: (admin) => (outcome.result = admin),
      error: (e: unknown) => (outcome.error = e),
    });
    const signIn = http.expectOne(`${api}/auth/admin/sign-in`);
    expect(signIn.request.body).toEqual({ mobileNumber: '9876500011', password: 'Secret#2026' });
    expect(signIn.request.headers.has('Authorization')).toBe(false);
    signIn.flush({ success: true, data: tokens });
    return outcome;
  }

  it('signs in an administrator and sends the token to admin endpoints', () => {
    const outcome = verify();

    const me = http.expectOne(`${api}/admin/me`);
    expect(me.request.headers.get('Authorization')).toBe('Bearer access-1');
    me.flush({ success: true, data: { maskedMobileNumber: '+91******0011', roles: ['ADMIN', 'MEMBER'] } });

    expect(outcome.result).toEqual({ maskedMobileNumber: '+91******0011', roles: ['ADMIN', 'MEMBER'] });
    expect(auth.isSignedIn()).toBe(true);
    expect(auth.admin()?.roles).toContain('ADMIN');
  });

  it('rejects an account without an admin role and signs it out', () => {
    const outcome = verify();

    http.expectOne(`${api}/admin/me`).flush({ success: false, message: 'Forbidden' }, { status: 403, statusText: 'Forbidden' });

    expect((outcome.error as Error).message).toBe(NO_ADMIN_ACCESS);
    expect(auth.isSignedIn()).toBe(false);
    expect(sessionStorage.length).toBe(0);
  });

  it('reports a wrong password without trying to refresh', () => {
    let error: unknown;
    auth.signIn('9876500011', 'wrong').subscribe({ error: (e: unknown) => (error = e) });
    http
      .expectOne(`${api}/auth/admin/sign-in`)
      .flush({ success: false, message: 'The mobile number or password is incorrect.' }, { status: 401, statusText: 'Unauthorized' });

    expect(error).toBeTruthy();
    expect(auth.isSignedIn()).toBe(false);
  });

  it('refreshes an expired access token once and retries the request', () => {
    verify();
    http.expectOne(`${api}/admin/me`).flush({ success: true, data: { maskedMobileNumber: 'x', roles: ['ADMIN'] } });

    let admin: unknown;
    auth.loadAdmin().subscribe((a) => (admin = a));
    http.expectOne(`${api}/admin/me`).flush(null, { status: 401, statusText: 'Unauthorized' });
    http.expectOne(`${api}/auth/token/refresh`).flush({ success: true, data: { accessToken: 'access-2', refreshToken: 'refresh-2' } });
    const retry = http.expectOne(`${api}/admin/me`);
    expect(retry.request.headers.get('Authorization')).toBe('Bearer access-2');
    retry.flush({ success: true, data: { maskedMobileNumber: 'x', roles: ['ADMIN'] } });

    expect(admin).toBeTruthy();
  });
});

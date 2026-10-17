import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { Observable, catchError, finalize, map, of, shareReplay, switchMap, tap, throwError } from 'rxjs';

import { environment } from '../../environments/environment';
import { ApiResponse } from './api';

export interface CodeIssued {
  challengeId: string;
  maskedMobileNumber: string;
  codeLength: number;
  expiresInSeconds: number;
  resendAfterSeconds: number;
  /** Only returned by the API in Development. */
  developmentCode: string | null;
}

export interface AdminProfile {
  maskedMobileNumber: string;
  roles: string[];
}

interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

const SESSION_KEY = 'pvs-admin-session';
export const NO_ADMIN_ACCESS = 'This mobile number does not have admin access. Ask a Super Admin to grant it.';

/**
 * Phone-number sign-in (same API as the mobile app) plus a server-side admin check (GET /api/v1/admin/me).
 * Tokens live in sessionStorage, so closing the browser signs the administrator out.
 */
@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly api = `${environment.apiBaseUrl}/api/v1`;

  private readonly tokens = signal<AuthTokens | null>(readSession());
  private refreshInFlight: Observable<string> | null = null;

  /** The verified administrator; null until /admin/me succeeds. */
  readonly admin = signal<AdminProfile | null>(null);
  readonly isSignedIn = computed(() => this.tokens() !== null);
  /** Super Admins also manage admin users and see sensitive data (disability details). */
  readonly isSuperAdmin = computed(() => this.admin()?.roles.includes('SUPER_ADMIN') ?? false);

  get accessToken(): string | null {
    return this.tokens()?.accessToken ?? null;
  }

  requestCode(mobileNumber: string): Observable<CodeIssued> {
    return this.http
      .post<ApiResponse<CodeIssued>>(`${this.api}/auth/verification-codes`, { mobileNumber })
      .pipe(map((r) => r.data!));
  }

  /** Verifies the code, then confirms the account is an administrator. */
  verifyCode(challengeId: string, code: string): Observable<AdminProfile> {
    return this.http
      .post<ApiResponse<AuthTokens>>(`${this.api}/auth/verification-codes/verify`, { challengeId, code })
      .pipe(
        tap((r) => this.store(r.data!)),
        switchMap(() => this.loadAdmin()),
      );
  }

  /** Loads (or re-checks) the administrator profile; signs out when the account is not an admin. */
  loadAdmin(): Observable<AdminProfile> {
    return this.http.get<ApiResponse<AdminProfile>>(`${this.api}/admin/me`).pipe(
      map((r) => r.data!),
      tap((admin) => this.admin.set(admin)),
      catchError((e: unknown) => {
        this.clear();
        const forbidden = e instanceof HttpErrorResponse && e.status === 403;
        return throwError(() => (forbidden ? new Error(NO_ADMIN_ACCESS) : e));
      }),
    );
  }

  /** New access token from the refresh token; concurrent callers share one request. */
  refresh(): Observable<string> {
    const refreshToken = this.tokens()?.refreshToken;
    if (!refreshToken) return throwError(() => new Error('Not signed in.'));
    this.refreshInFlight ??= this.http
      .post<ApiResponse<AuthTokens>>(`${this.api}/auth/token/refresh`, { refreshToken })
      .pipe(
        map((r) => {
          this.store(r.data!);
          return r.data!.accessToken;
        }),
        catchError((e: unknown) => {
          this.clear();
          return throwError(() => e);
        }),
        finalize(() => (this.refreshInFlight = null)),
        shareReplay(1),
      );
    return this.refreshInFlight;
  }

  signOut(): Observable<void> {
    const refreshToken = this.tokens()?.refreshToken;
    const request = refreshToken
      ? this.http.post(`${this.api}/auth/logout`, { refreshToken }).pipe(catchError(() => of(null)))
      : of(null);
    return request.pipe(
      map(() => undefined),
      finalize(() => this.clear()),
    );
  }

  private store(tokens: AuthTokens): void {
    const session: AuthTokens = { accessToken: tokens.accessToken, refreshToken: tokens.refreshToken };
    this.tokens.set(session);
    try {
      sessionStorage.setItem(SESSION_KEY, JSON.stringify(session));
    } catch {
      // Storage unavailable (e.g. private mode): the session lasts for this page only.
    }
  }

  private clear(): void {
    this.tokens.set(null);
    this.admin.set(null);
    try {
      sessionStorage.removeItem(SESSION_KEY);
    } catch {
      // Storage unavailable: nothing to remove.
    }
  }
}

function readSession(): AuthTokens | null {
  try {
    const raw = sessionStorage.getItem(SESSION_KEY);
    return raw ? (JSON.parse(raw) as AuthTokens) : null;
  } catch {
    return null;
  }
}

import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';

import { environment } from '../../environments/environment';
import { ApiResponse } from './api';
import {
  AdminUser, AppBranding, ListItem, ListType, LocationItem, LookupItem, MemberDetail, MemberFilters, MemberRow, OtherValue,
  PagedResult, Summary,
} from './models';

/** Typed calls to the admin endpoints (`/api/v1/admin/...`) and the shared lookup lists. */
@Injectable({ providedIn: 'root' })
export class AdminApi {
  private readonly http = inject(HttpClient);
  private readonly api = `${environment.apiBaseUrl}/api/v1`;

  // ---------------------------------------------------------------- Lookups (dropdowns)
  lookups(types: string[]): Observable<Record<string, LookupItem[]>> {
    return this.get<Record<string, LookupItem[]>>('/master-data', new HttpParams().set('types', types.join(',')));
  }
  states(countryId: number): Observable<LookupItem[]> {
    return this.get(`/locations/countries/${countryId}/states`);
  }
  districts(stateId: number): Observable<LookupItem[]> {
    return this.get(`/locations/states/${stateId}/districts`);
  }
  taluks(districtId: number): Observable<LookupItem[]> {
    return this.get(`/locations/districts/${districtId}/taluks`);
  }

  // ---------------------------------------------------------------- Members
  members(filters: MemberFilters): Observable<PagedResult<MemberRow>> {
    return this.get('/admin/members', toParams(filters));
  }
  exportMembers(filters: MemberFilters): Observable<Blob> {
    return this.http.get(`${this.api}/admin/members/export`, { params: toParams(filters), responseType: 'blob' });
  }
  member(registrationId: string): Observable<MemberDetail> {
    return this.get(`/admin/members/${registrationId}`);
  }
  setMemberActive(registrationId: string, isActive: boolean): Observable<string> {
    return this.put(`/admin/members/${registrationId}/status`, { isActive });
  }

  // ---------------------------------------------------------------- Reports
  summary(): Observable<Summary> {
    return this.get('/admin/reports/summary');
  }

  // ---------------------------------------------------------------- Master lists
  listTypes(): Observable<ListType[]> {
    return this.get('/admin/lists');
  }
  listItems(type: string): Observable<ListItem[]> {
    return this.get(`/admin/lists/${type}`);
  }
  createListItem(type: string, item: { name: string; code?: string | null; displayOrder?: number | null }): Observable<ListItem> {
    return this.http.post<ApiResponse<ListItem>>(`${this.api}/admin/lists/${type}`, item).pipe(map((r) => r.data!));
  }
  updateListItem(type: string, id: number, changes: { name?: string; displayOrder?: number; isActive?: boolean }): Observable<ListItem> {
    return this.http.put<ApiResponse<ListItem>>(`${this.api}/admin/lists/${type}/${id}`, changes).pipe(map((r) => r.data!));
  }

  // ---------------------------------------------------------------- "Other" values
  otherValues(): Observable<OtherValue[]> {
    return this.get('/admin/other-values');
  }
  mapOtherValue(listType: string, text: string, targetId: number): Observable<number> {
    return this.http
      .post<ApiResponse<{ updatedRows: number }>>(`${this.api}/admin/other-values/map`, { listType, text, targetId })
      .pipe(map((r) => r.data!.updatedRows));
  }

  // ---------------------------------------------------------------- Admin users
  adminUsers(): Observable<AdminUser[]> {
    return this.get('/admin/users');
  }
  grantRole(mobileNumber: string, roleCode: string): Observable<AdminUser> {
    return this.http.post<ApiResponse<AdminUser>>(`${this.api}/admin/users`, { mobileNumber, roleCode }).pipe(map((r) => r.data!));
  }
  revokeRole(accountId: number, roleCode: string): Observable<string> {
    return this.http
      .delete<ApiResponse<null>>(`${this.api}/admin/users/${accountId}/roles/${roleCode}`)
      .pipe(map((r) => r.message));
  }

  // ---------------------------------------------------------------- Splash branding (Super Admin)
  branding(): Observable<AppBranding> {
    return this.get('/admin/branding');
  }
  saveBranding(sponsorName: string, poweredBy: string): Observable<AppBranding> {
    return this.http
      .put<ApiResponse<AppBranding>>(`${this.api}/admin/branding`, { sponsorName, poweredBy })
      .pipe(map((r) => r.data!));
  }
  uploadSponsorLogo(file: File): Observable<AppBranding> {
    const form = new FormData();
    form.append('file', file);
    return this.http.post<ApiResponse<AppBranding>>(`${this.api}/admin/branding/sponsor-logo`, form).pipe(map((r) => r.data!));
  }
  removeSponsorLogo(): Observable<AppBranding> {
    return this.http.delete<ApiResponse<AppBranding>>(`${this.api}/admin/branding/sponsor-logo`).pipe(map((r) => r.data!));
  }
  sponsorLogoUrl(branding: AppBranding): string | null {
    return branding.hasSponsorLogo ? `${this.api}/app/branding/sponsor-logo?v=${branding.sponsorLogoVersion}` : null;
  }

  // ---------------------------------------------------------------- Locations
  locations(includeSeed: boolean): Observable<LocationItem[]> {
    return this.get('/admin/locations', new HttpParams().set('includeSeed', includeSeed));
  }
  updateLocation(kind: 'District' | 'Taluk', id: number, changes: { name?: string; isActive?: boolean }): Observable<string> {
    return this.put(`/admin/locations/${kind === 'District' ? 'districts' : 'taluks'}/${id}`, changes);
  }
  mergeTaluk(id: number, targetTalukId: number): Observable<string> {
    return this.http
      .post<ApiResponse<null>>(`${this.api}/admin/locations/taluks/${id}/merge`, { targetTalukId })
      .pipe(map((r) => r.message));
  }

  private get<T>(path: string, params?: HttpParams): Observable<T> {
    return this.http.get<ApiResponse<T>>(`${this.api}${path}`, { params }).pipe(map((r) => r.data!));
  }

  private put(path: string, body: unknown): Observable<string> {
    return this.http.put<ApiResponse<null>>(`${this.api}${path}`, body).pipe(map((r) => r.message));
  }
}

/** Query string from filters, skipping empty values. */
export function toParams(filters: object): HttpParams {
  let params = new HttpParams();
  for (const [key, value] of Object.entries(filters)) {
    if (value !== null && value !== undefined && value !== '') params = params.set(key, String(value));
  }
  return params;
}

/** Saves a downloaded file (e.g. the CSV export). */
export function saveFile(blob: Blob, fileName: string): void {
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = fileName;
  link.click();
  URL.revokeObjectURL(url);
}

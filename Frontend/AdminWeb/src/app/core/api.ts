import { HttpErrorResponse } from '@angular/common/http';

/** Envelope every PVS API response uses. */
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T | null;
  errors: { field: string | null; message: string }[];
}

/** User-facing message for a failed API call. */
export function errorMessage(error: unknown): string {
  if (error instanceof HttpErrorResponse) {
    if (error.status === 0) return 'Cannot reach the server. Check your connection and that the API is running.';
    const body = error.error as Partial<ApiResponse<unknown>> | null;
    return body?.errors?.[0]?.message || body?.message || `Request failed (${error.status}).`;
  }
  return error instanceof Error ? error.message : 'Something went wrong.';
}

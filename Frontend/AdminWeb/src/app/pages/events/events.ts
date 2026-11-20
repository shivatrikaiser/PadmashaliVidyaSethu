import { DatePipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';

import { AdminApi } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { EventRow } from '../../core/models';

/** Events members register for in the app (sports, drawing, quiz, ...), newest first. */
@Component({
  selector: 'app-events',
  imports: [RouterLink, DatePipe],
  templateUrl: './events.html',
})
export class Events {
  private readonly api = inject(AdminApi);

  protected readonly events = signal<EventRow[] | null>(null);
  protected readonly error = signal<string | null>(null);

  constructor() {
    this.api.events().subscribe({
      next: (e) => this.events.set(e),
      error: (e: unknown) => this.error.set(errorMessage(e)),
    });
  }

  protected status(e: EventRow): string {
    if (!e.isActive) return 'Cancelled';
    if (!e.isPublished) return 'Draft';
    const today = todayInIndia();
    if (today < e.registrationOpensDate) return 'Opens later';
    if (today > e.registrationClosesDate) return 'Registration closed';
    return 'Registration open';
  }
}

/** yyyy-MM-dd in India (the server opens and closes registration by India dates). */
export function todayInIndia(offsetDays = 0): string {
  return new Date(Date.now() + (5.5 * 60 + offsetDays * 24 * 60) * 60_000).toISOString().slice(0, 10);
}

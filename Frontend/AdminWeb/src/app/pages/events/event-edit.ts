import { HttpErrorResponse } from '@angular/common/http';
import { DatePipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';

import { AdminApi, saveFile } from '../../core/admin-api.service';
import { ApiResponse, errorMessage } from '../../core/api';
import { EventDetail, EventGroup, EventInput, EventRegistrationRow, LookupItem } from '../../core/models';
import { todayInIndia } from './events';

/**
 * Add or edit an event and its age / gender groups (`/events/new` or `/events/:id`), and see who registered.
 * Groups are saved with the event; a group members are registered in cannot be removed (change it instead).
 */
@Component({
  selector: 'app-event-edit',
  imports: [FormsModule, RouterLink, DatePipe],
  templateUrl: './event-edit.html',
  styleUrl: './event-edit.scss',
})
export class EventEdit {
  private readonly api = inject(AdminApi);
  private readonly router = inject(Router);

  protected id: number | null = null;
  protected form: EventInput = EventEdit.blank();
  protected readonly detail = signal<EventDetail | null>(null);
  protected readonly genders = signal<LookupItem[]>([]);
  protected readonly registrations = signal<EventRegistrationRow[] | null>(null);
  protected readonly showCancelled = signal(false);

  protected readonly loading = signal(false);
  protected readonly busy = signal(false);
  protected readonly exporting = signal(false);
  protected readonly error = signal<string | null>(null);
  protected readonly fieldErrors = signal<Record<string, string>>({});
  protected readonly message = signal<string | null>(null);

  constructor() {
    this.api.lookups(['genders']).subscribe((l) => this.genders.set(l['genders']));
    const param = inject(ActivatedRoute).snapshot.paramMap.get('id');
    if (param && param !== 'new') {
      this.id = Number(param);
      this.load();
    }
  }

  private static blank(): EventInput {
    const eventDate = todayInIndia(30);
    return {
      code: '',
      title: '',
      description: '',
      venue: '',
      eventDate,
      ageAsOnDate: eventDate,
      registrationOpensDate: todayInIndia(),
      registrationClosesDate: todayInIndia(23),
      maxGroupsPerMember: 1,
      isPublished: false,
      isActive: true,
      groups: [EventEdit.group()],
    };
  }

  private static group(): EventGroup {
    return { id: null, name: '', minAge: null, maxAge: null, genderId: null, capacity: null };
  }

  protected addGroup(): void {
    this.form.groups.push(EventEdit.group());
  }

  protected removeGroup(index: number): void {
    this.form.groups.splice(index, 1);
  }

  protected moveGroup(index: number, by: -1 | 1): void {
    const groups = this.form.groups;
    const target = index + by;
    if (target < 0 || target >= groups.length) return;
    [groups[index], groups[target]] = [groups[target], groups[index]];
  }

  /** Same as the event date, the common case. */
  protected ageAsOnEventDate(): void {
    this.form.ageAsOnDate = this.form.eventDate;
  }

  protected save(): void {
    this.busy.set(true);
    this.error.set(null);
    this.fieldErrors.set({});
    this.message.set(null);
    const body: EventInput = {
      ...this.form,
      code: this.form.code.trim().toUpperCase(),
      groups: this.form.groups.map(({ id, name, minAge, maxAge, genderId, capacity }) => ({
        id, name, minAge, maxAge, genderId, capacity: capacity || null,
      })),
    };
    this.api.saveEvent(this.id, body).subscribe({
      next: (saved) => {
        this.busy.set(false);
        this.message.set('Saved.');
        if (this.id === null) {
          void this.router.navigate(['/events', saved.id], { replaceUrl: true });
          this.id = saved.id;
        }
        this.apply(saved);
        this.loadRegistrations();
      },
      error: (e: unknown) => {
        this.busy.set(false);
        this.error.set(errorMessage(e));
        this.fieldErrors.set(fieldErrors(e));
      },
    });
  }

  protected export(): void {
    if (this.id === null) return;
    this.exporting.set(true);
    this.api.exportEventRegistrations(this.id).subscribe({
      next: (blob) => {
        saveFile(blob, `pvs-event-${this.form.code.toLowerCase()}-${todayInIndia()}.csv`);
        this.exporting.set(false);
      },
      error: (e: unknown) => {
        this.error.set(errorMessage(e));
        this.exporting.set(false);
      },
    });
  }

  protected visibleRegistrations(): EventRegistrationRow[] {
    const all = this.registrations() ?? [];
    return this.showCancelled() ? all : all.filter((r) => r.isActive);
  }

  protected cancelledCount(): number {
    return (this.registrations() ?? []).filter((r) => !r.isActive).length;
  }

  protected err(field: string): string | undefined {
    return this.fieldErrors()[field];
  }

  private load(): void {
    this.loading.set(true);
    this.api.event(this.id!).subscribe({
      next: (e) => {
        this.loading.set(false);
        this.apply(e);
      },
      error: (e: unknown) => {
        this.loading.set(false);
        this.error.set(errorMessage(e));
      },
    });
    this.loadRegistrations();
  }

  private loadRegistrations(): void {
    if (this.id === null) return;
    this.api.eventRegistrations(this.id).subscribe({
      next: (r) => this.registrations.set(r),
      error: (e: unknown) => this.error.set(errorMessage(e)),
    });
  }

  private apply(e: EventDetail): void {
    this.detail.set(e);
    this.form = {
      code: e.code,
      title: e.title,
      description: e.description ?? '',
      venue: e.venue ?? '',
      eventDate: e.eventDate,
      ageAsOnDate: e.ageAsOnDate,
      registrationOpensDate: e.registrationOpensDate,
      registrationClosesDate: e.registrationClosesDate,
      maxGroupsPerMember: e.maxGroupsPerMember,
      isPublished: e.isPublished,
      isActive: e.isActive,
      groups: e.groups.map((g) => ({ ...g })),
    };
  }
}

/** Field → message from a validation response (camelCase paths such as `groups[0].maxAge`). */
function fieldErrors(error: unknown): Record<string, string> {
  if (!(error instanceof HttpErrorResponse)) return {};
  const body = error.error as Partial<ApiResponse<unknown>> | null;
  const result: Record<string, string> = {};
  for (const e of body?.errors ?? []) if (e.field) result[e.field] ??= e.message;
  return result;
}

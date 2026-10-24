import { DatePipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';

import { AdminApi, saveFile } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { LookupItem, MemberFilters, MemberRow, PagedResult } from '../../core/models';

const INDIA = 1;

/** Member search with filters, paging and CSV export (opens in Excel). */
@Component({
  selector: 'app-members',
  imports: [FormsModule, RouterLink, DatePipe],
  templateUrl: './members.html',
})
export class Members {
  private readonly api = inject(AdminApi);

  protected filters: MemberFilters = { isActive: true, page: 1, pageSize: 25 };
  protected stateId: number | null = null;

  protected readonly temples = signal<LookupItem[]>([]);
  protected readonly statuses = signal<LookupItem[]>([]);
  protected readonly classes = signal<LookupItem[]>([]);
  protected readonly organisations = signal<LookupItem[]>([]);
  protected readonly states = signal<LookupItem[]>([]);
  protected readonly districts = signal<LookupItem[]>([]);

  protected readonly result = signal<PagedResult<MemberRow> | null>(null);
  protected readonly loading = signal(false);
  protected readonly exporting = signal(false);
  protected readonly error = signal<string | null>(null);

  constructor() {
    this.api.lookups(['temples', 'member-statuses', 'classes', 'organisations']).subscribe((l) => {
      this.temples.set(l['temples']);
      this.statuses.set(l['member-statuses']);
      this.classes.set(l['classes']);
      this.organisations.set(l['organisations']);
    });
    this.api.states(INDIA).subscribe((s) => this.states.set(s));
    this.search();
  }

  protected onStateChange(): void {
    this.filters.districtId = null;
    this.districts.set([]);
    if (this.stateId) this.api.districts(this.stateId).subscribe((d) => this.districts.set(d));
  }

  protected search(page = 1): void {
    this.filters.page = page;
    this.loading.set(true);
    this.error.set(null);
    this.api.members(this.filters).subscribe({
      next: (r) => {
        this.result.set(r);
        this.loading.set(false);
      },
      error: (e: unknown) => {
        this.error.set(errorMessage(e));
        this.loading.set(false);
      },
    });
  }

  protected clear(): void {
    this.filters = { isActive: true, page: 1, pageSize: 25 };
    this.stateId = null;
    this.districts.set([]);
    this.search();
  }

  protected export(): void {
    this.exporting.set(true);
    const { page: _page, pageSize: _size, ...all } = this.filters;
    this.api.exportMembers(all).subscribe({
      next: (blob) => {
        saveFile(blob, `pvs-members-${new Date().toISOString().slice(0, 10)}.csv`);
        this.exporting.set(false);
      },
      error: (e: unknown) => {
        this.error.set(errorMessage(e));
        this.exporting.set(false);
      },
    });
  }

  protected pages(r: PagedResult<MemberRow>): number {
    return Math.max(1, Math.ceil(r.totalCount / r.pageSize));
  }
}

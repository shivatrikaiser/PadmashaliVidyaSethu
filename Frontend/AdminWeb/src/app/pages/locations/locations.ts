import { DatePipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Observable } from 'rxjs';

import { AdminApi } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { LocationItem, LookupItem } from '../../core/models';

interface Row extends LocationItem {
  editName: string;
  mergeTargetId: number | null;
}

/** Districts and taluks added by PIN lookups or typed by members: rename, deactivate, merge duplicates. */
@Component({
  selector: 'app-locations',
  imports: [FormsModule, DatePipe],
  templateUrl: './locations.html',
})
export class Locations {
  private readonly api = inject(AdminApi);

  protected includeSeed = false;
  protected readonly rows = signal<Row[]>([]);
  /** Active taluks per district, for the merge dropdowns. */
  protected readonly taluks = signal<Partial<Record<number, LookupItem[]>>>({});
  protected readonly error = signal<string | null>(null);
  protected readonly message = signal<string | null>(null);
  protected readonly busy = signal(false);

  constructor() {
    this.load();
  }

  protected load(): void {
    this.api.locations(this.includeSeed).subscribe({
      next: (items) => {
        this.rows.set(items.map((i) => ({ ...i, editName: i.name, mergeTargetId: null })));
        const districtIds = new Set(items.filter((i) => i.kind === 'Taluk').map((i) => i.parentId));
        for (const id of districtIds) {
          this.api.taluks(id).subscribe((t) => this.taluks.update((all) => ({ ...all, [id]: t })));
        }
      },
      error: (e: unknown) => this.error.set(errorMessage(e)),
    });
  }

  protected mergeOptions(row: Row): LookupItem[] {
    return (this.taluks()[row.parentId] ?? []).filter((t) => t.id !== row.id);
  }

  protected rename(row: Row): void {
    this.run(this.api.updateLocation(row.kind, row.id, { name: row.editName }));
  }

  protected toggle(row: Row): void {
    this.run(this.api.updateLocation(row.kind, row.id, { isActive: !row.isActive }));
  }

  protected merge(row: Row): void {
    const target = this.mergeOptions(row).find((t) => t.id === row.mergeTargetId);
    if (!target || !confirm(`Move all ${row.addressCount} address(es) from "${row.name}" to "${target.name}" and deactivate "${row.name}"?`)) return;
    this.run(this.api.mergeTaluk(row.id, target.id));
  }

  private run(request: Observable<string>): void {
    this.busy.set(true);
    this.error.set(null);
    request.subscribe({
      next: (msg) => {
        this.busy.set(false);
        this.message.set(msg);
        this.load();
      },
      error: (e: unknown) => {
        this.busy.set(false);
        this.error.set(errorMessage(e));
      },
    });
  }
}

import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Observable, switchMap } from 'rxjs';

import { AdminApi } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { ListItem, OtherValue } from '../../core/models';

interface Row extends OtherValue {
  targetId: number | null;
}

/**
 * "Other" texts typed by members. Map each to an existing list entry, or create a new entry from the text; all
 * members who typed it are moved to that entry (see Docs/MasterData.md).
 */
@Component({
  selector: 'app-other-values',
  imports: [FormsModule],
  templateUrl: './other-values.html',
})
export class OtherValues {
  private readonly api = inject(AdminApi);

  protected readonly rows = signal<Row[]>([]);
  /** Active, non-"Other" entries per list type, for the "Map to" dropdowns. */
  protected readonly targets = signal<Partial<Record<string, ListItem[]>>>({});
  protected readonly error = signal<string | null>(null);
  protected readonly message = signal<string | null>(null);
  protected readonly busy = signal(false);
  protected readonly loaded = signal(false);

  constructor() {
    this.load();
  }

  protected map(row: Row): void {
    if (!row.targetId) return;
    const target = this.targets()[row.listType]?.find((t) => t.id === row.targetId);
    this.run(this.api.mapOtherValue(row.listType, row.text, row.targetId), row, target?.name ?? '');
  }

  protected createAndMap(row: Row): void {
    if (!confirm(`Add "${row.text}" to ${row.listLabel} and move ${row.memberCount} member(s) to it?`)) return;
    this.run(
      this.api.createListItem(row.listType, { name: row.text }).pipe(
        switchMap((item) => this.api.mapOtherValue(row.listType, row.text, item.id)),
      ),
      row,
      row.text,
    );
  }

  private run(request: Observable<number>, row: Row, targetName: string): void {
    this.busy.set(true);
    this.error.set(null);
    request.subscribe({
      next: (updated) => {
        this.busy.set(false);
        this.message.set(`"${row.text}" mapped to "${targetName}" (${updated} record(s) updated).`);
        this.load();
      },
      error: (e: unknown) => {
        this.busy.set(false);
        this.error.set(errorMessage(e));
      },
    });
  }

  private load(): void {
    this.api.otherValues().subscribe({
      next: (values) => {
        this.rows.set(values.map((v) => ({ ...v, targetId: null })));
        this.loaded.set(true);
        for (const type of new Set(values.map((v) => v.listType))) {
          this.api.listItems(type).subscribe((items) =>
            this.targets.update((t) => ({ ...t, [type]: items.filter((i) => i.isActive && i.code !== 'OTHER') })),
          );
        }
      },
      error: (e: unknown) => this.error.set(errorMessage(e)),
    });
  }
}

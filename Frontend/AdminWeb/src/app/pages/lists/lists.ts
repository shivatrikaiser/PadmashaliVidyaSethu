import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { AdminApi } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { ListItem, ListType } from '../../core/models';

interface EditableItem extends ListItem {
  editName: string;
  editOrder: number;
}

/** Configurable lists: add, rename, reorder, activate / deactivate. Codes never change. */
@Component({
  selector: 'app-lists',
  imports: [FormsModule],
  templateUrl: './lists.html',
})
export class Lists {
  private readonly api = inject(AdminApi);

  protected readonly types = signal<ListType[]>([]);
  protected type = 'temples';
  protected readonly items = signal<EditableItem[]>([]);
  protected readonly error = signal<string | null>(null);
  protected readonly message = signal<string | null>(null);
  protected readonly busy = signal(false);

  protected newName = '';
  protected newCode = '';

  constructor() {
    this.api.listTypes().subscribe((t) => this.types.set(t));
    this.load();
  }

  protected load(): void {
    this.message.set(null);
    this.error.set(null);
    this.api.listItems(this.type).subscribe({
      next: (items) => this.items.set(items.map((i) => ({ ...i, editName: i.name, editOrder: i.displayOrder }))),
      error: (e: unknown) => this.error.set(errorMessage(e)),
    });
  }

  protected add(): void {
    const name = this.newName.trim();
    if (!name) return;
    this.run(
      this.api.createListItem(this.type, { name, code: this.type === 'temples' ? this.newCode.trim() : null }),
      `Added "${name}".`,
      () => {
        this.newName = '';
        this.newCode = '';
      },
    );
  }

  protected save(item: EditableItem): void {
    this.run(this.api.updateListItem(this.type, item.id, { name: item.editName, displayOrder: item.editOrder }), 'Saved.');
  }

  protected toggle(item: EditableItem): void {
    this.run(
      this.api.updateListItem(this.type, item.id, { isActive: !item.isActive }),
      item.isActive ? `"${item.name}" deactivated - it no longer appears in the app.` : `"${item.name}" activated.`,
    );
  }

  protected changed(item: EditableItem): boolean {
    return item.editName.trim() !== item.name || item.editOrder !== item.displayOrder;
  }

  private run(request: ReturnType<AdminApi['updateListItem']>, success: string, after?: () => void): void {
    this.busy.set(true);
    this.error.set(null);
    request.subscribe({
      next: () => {
        this.busy.set(false);
        after?.();
        this.load();
        this.message.set(success);
      },
      error: (e: unknown) => {
        this.busy.set(false);
        this.error.set(errorMessage(e));
      },
    });
  }
}

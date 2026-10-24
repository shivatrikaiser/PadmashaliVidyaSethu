import { DatePipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';

import { AdminApi, saveFile } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { DeletedAccount, DeletedAccountFilters } from '../../core/models';

/**
 * Accounts their users deleted in the app ("Delete my account"). Nothing was erased: the account and its members are
 * kept for the records, and the mobile number cannot sign in or register again.
 */
@Component({
  selector: 'app-deleted-accounts',
  imports: [FormsModule, RouterLink, DatePipe],
  templateUrl: './deleted-accounts.html',
})
export class DeletedAccounts {
  private readonly api = inject(AdminApi);

  protected filters: DeletedAccountFilters = {};
  protected readonly rows = signal<DeletedAccount[] | null>(null);
  protected readonly loading = signal(false);
  protected readonly exporting = signal(false);
  protected readonly error = signal<string | null>(null);

  constructor() {
    this.search();
  }

  protected search(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.deletedAccounts(this.filters).subscribe({
      next: (rows) => {
        this.rows.set(rows);
        this.loading.set(false);
      },
      error: (e: unknown) => {
        this.error.set(errorMessage(e));
        this.loading.set(false);
      },
    });
  }

  protected clear(): void {
    this.filters = {};
    this.search();
  }

  protected export(): void {
    this.exporting.set(true);
    this.api.exportDeletedAccounts(this.filters).subscribe({
      next: (blob) => {
        saveFile(blob, `pvs-deleted-accounts-${new Date().toISOString().slice(0, 10)}.csv`);
        this.exporting.set(false);
      },
      error: (e: unknown) => {
        this.error.set(errorMessage(e));
        this.exporting.set(false);
      },
    });
  }

  protected memberCount(rows: DeletedAccount[]): number {
    return rows.reduce((sum, r) => sum + r.members.length, 0);
  }
}

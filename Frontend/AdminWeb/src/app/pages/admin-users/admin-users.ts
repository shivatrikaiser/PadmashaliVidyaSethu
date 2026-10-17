import { DatePipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { AdminApi } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { AuthService } from '../../core/auth.service';
import { AdminUser } from '../../core/models';

/** Who can use the admin portal (Super Admin only). */
@Component({
  selector: 'app-admin-users',
  imports: [FormsModule, DatePipe],
  templateUrl: './admin-users.html',
})
export class AdminUsers {
  private readonly api = inject(AdminApi);
  protected readonly auth = inject(AuthService);

  protected readonly users = signal<AdminUser[]>([]);
  protected readonly error = signal<string | null>(null);
  protected readonly message = signal<string | null>(null);
  protected readonly busy = signal(false);

  protected mobileNumber = '';
  protected roleCode = 'ADMIN';

  constructor() {
    this.load();
  }

  protected grant(): void {
    this.busy.set(true);
    this.error.set(null);
    this.api.grantRole(this.mobileNumber, this.roleCode).subscribe({
      next: (user) => {
        this.busy.set(false);
        this.message.set(`${user.mobileNumber} is now ${this.roleCode}. It applies at their next sign-in.`);
        this.mobileNumber = '';
        this.load();
      },
      error: (e: unknown) => {
        this.busy.set(false);
        this.error.set(errorMessage(e));
      },
    });
  }

  protected revoke(user: AdminUser, role: string): void {
    if (!confirm(`Remove ${role} from ${user.mobileNumber}? They will be signed out.`)) return;
    this.busy.set(true);
    this.error.set(null);
    this.api.revokeRole(user.accountId, role).subscribe({
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

  private load(): void {
    this.api.adminUsers().subscribe({
      next: (u) => this.users.set(u),
      error: (e: unknown) => this.error.set(errorMessage(e)),
    });
  }
}

import { DatePipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Observable } from 'rxjs';

import { AdminApi } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { AuthService } from '../../core/auth.service';
import { AdminUser } from '../../core/models';

export const MIN_PASSWORD_LENGTH = 8;

/** A random password without look-alike characters (0/O, 1/l/I), easy to read out over the phone. */
export function generatePassword(length = 12): string {
  const chars = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789@#$%';
  const values = crypto.getRandomValues(new Uint32Array(length));
  return Array.from(values, (v) => chars[v % chars.length]).join('');
}

/**
 * Who can use the admin portal and their passwords (Super Admin only). Admins sign in with mobile number +
 * password; there is no self-service change or reset - a Super Admin sets a new password here.
 */
@Component({
  selector: 'app-admin-users',
  imports: [FormsModule, DatePipe],
  templateUrl: './admin-users.html',
  styleUrl: './admin-users.scss',
})
export class AdminUsers {
  private readonly api = inject(AdminApi);
  protected readonly auth = inject(AuthService);
  protected readonly minLength = MIN_PASSWORD_LENGTH;

  protected readonly users = signal<AdminUser[]>([]);
  protected readonly error = signal<string | null>(null);
  protected readonly message = signal<string | null>(null);
  protected readonly busy = signal(false);

  protected mobileNumber = '';
  protected roleCode = 'ADMIN';
  protected newPassword = '';

  /** The row whose password is being set. */
  protected readonly editing = signal<number | null>(null);
  protected rowPassword = '';

  constructor() {
    this.load();
  }

  protected generateNew(): void {
    this.newPassword = generatePassword();
  }

  protected generateRow(): void {
    this.rowPassword = generatePassword();
  }

  protected grant(): void {
    if (this.newPassword && this.newPassword.length < MIN_PASSWORD_LENGTH) {
      this.error.set(`The password needs at least ${MIN_PASSWORD_LENGTH} characters.`);
      return;
    }
    this.run(this.api.grantRole(this.mobileNumber, this.roleCode, this.newPassword), (user) => {
      const password = this.newPassword ? ' Share the password with them.' : ' Set a password before they sign in.';
      this.message.set(`${user.mobileNumber} is now ${this.roleCode === 'SUPER_ADMIN' ? 'Super Admin' : 'Admin'}.${password}`);
      this.mobileNumber = '';
      this.newPassword = '';
    });
  }

  protected startPassword(user: AdminUser): void {
    this.editing.set(user.accountId);
    this.rowPassword = '';
    this.message.set(null);
    this.error.set(null);
  }

  protected cancelPassword(): void {
    this.editing.set(null);
    this.rowPassword = '';
  }

  protected savePassword(user: AdminUser): void {
    if (this.rowPassword.length < MIN_PASSWORD_LENGTH) {
      this.error.set(`The password needs at least ${MIN_PASSWORD_LENGTH} characters.`);
      return;
    }
    const replacing = user.hasPassword ? ' They have been signed out and use the new password from now on.' : '';
    this.run(this.api.setPassword(user.accountId, this.rowPassword), () => {
      this.message.set(`Password set for ${user.mobileNumber}.${replacing} Share it with them.`);
      this.cancelPassword();
    });
  }

  protected revoke(user: AdminUser, role: string): void {
    if (!confirm(`Remove ${role} from ${user.mobileNumber}? They will be signed out.`)) return;
    this.run(this.api.revokeRole(user.accountId, role), (msg) => this.message.set(msg));
  }

  private run<T>(request: Observable<T>, done: (result: T) => void): void {
    this.busy.set(true);
    this.error.set(null);
    this.message.set(null);
    request.subscribe({
      next: (result) => {
        this.busy.set(false);
        done(result);
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

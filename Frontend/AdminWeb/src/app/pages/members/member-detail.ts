import { DatePipe } from '@angular/common';
import { Component, OnInit, inject, input, signal } from '@angular/core';
import { RouterLink } from '@angular/router';

import { AdminApi } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { MemberDetail as Detail } from '../../core/models';

/** One member's full profile, with deactivate / reactivate. */
@Component({
  selector: 'app-member-detail',
  imports: [RouterLink, DatePipe],
  templateUrl: './member-detail.html',
})
export class MemberDetail implements OnInit {
  private readonly api = inject(AdminApi);

  /** Route parameter (`/members/:registrationId`). */
  readonly registrationId = input.required<string>();

  protected readonly detail = signal<Detail | null>(null);
  protected readonly error = signal<string | null>(null);
  protected readonly message = signal<string | null>(null);
  protected readonly busy = signal(false);

  ngOnInit(): void {
    this.load();
  }

  protected setActive(isActive: boolean): void {
    const action = isActive ? 'reactivate' : 'deactivate';
    if (!confirm(`Do you want to ${action} ${this.detail()?.profile.fullName}?`)) return;
    this.busy.set(true);
    this.api.setMemberActive(this.registrationId(), isActive).subscribe({
      next: (msg) => {
        this.message.set(msg);
        this.busy.set(false);
        this.load();
      },
      error: (e: unknown) => {
        this.error.set(errorMessage(e));
        this.busy.set(false);
      },
    });
  }

  private load(): void {
    this.api.member(this.registrationId()).subscribe({
      next: (d) => this.detail.set(d),
      error: (e: unknown) => this.error.set(errorMessage(e)),
    });
  }
}

import { DatePipe } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { ApiResponse, errorMessage } from '../../core/api';

interface PushNotification {
  id: number;
  title: string;
  body: string;
  topic: string;
  sentDate: string;
  sentBy: string | null;
}

interface NotificationOverview {
  isConfigured: boolean;
  topic: string;
  maxTitleLength: number;
  maxBodyLength: number;
  history: PushNotification[];
}

/**
 * Push notification to every app user (Super Admin only). One message goes to the Firebase topic all app installs
 * subscribe to; phones show it even when the app is closed.
 */
@Component({
  selector: 'app-notifications',
  imports: [FormsModule, DatePipe],
  templateUrl: './notifications.html',
  styleUrl: './notifications.scss',
})
export class Notifications {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiBaseUrl}/api/v1/admin/notifications`;

  protected readonly overview = signal<NotificationOverview | null>(null);
  protected readonly error = signal<string | null>(null);
  protected readonly message = signal<string | null>(null);
  protected readonly busy = signal(false);

  protected title = '';
  protected body = '';

  constructor() {
    this.load();
  }

  protected send(): void {
    const title = this.title.trim();
    const body = this.body.trim();
    if (!title || !body) return;
    if (!confirm(`Send this notification to ALL app users?\n\n${title}\n${body}`)) return;

    this.busy.set(true);
    this.error.set(null);
    this.message.set(null);
    this.http.post<ApiResponse<PushNotification>>(this.url, { title, body }).subscribe({
      next: () => {
        this.busy.set(false);
        this.message.set('Sent. Phones receive it within a few seconds to a few minutes (longer when a phone is off or offline).');
        this.title = '';
        this.body = '';
        this.load();
      },
      error: (e: unknown) => {
        this.busy.set(false);
        this.error.set(errorMessage(e));
      },
    });
  }

  private load(): void {
    this.http
      .get<ApiResponse<NotificationOverview>>(this.url)
      .pipe(map((r) => r.data!))
      .subscribe({
        next: (o) => this.overview.set(o),
        error: (e: unknown) => this.error.set(errorMessage(e)),
      });
  }
}

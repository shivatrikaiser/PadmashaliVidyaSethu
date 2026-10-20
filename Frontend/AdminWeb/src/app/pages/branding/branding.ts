import { DatePipe } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Observable } from 'rxjs';

import { AdminApi } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { AppBranding } from '../../core/models';

const MAX_LOGO_KB = 300;

/** Sponsor (name, organisation, address) and "Powered by" shown in the app (Super Admin only). */
@Component({
  selector: 'app-branding',
  imports: [FormsModule, DatePipe],
  templateUrl: './branding.html',
  styleUrl: './branding.scss',
})
export class Branding {
  private readonly api = inject(AdminApi);

  protected readonly branding = signal<AppBranding | null>(null);
  protected readonly logoUrl = computed(() => {
    const b = this.branding();
    return b ? this.api.sponsorLogoUrl(b) : null;
  });
  protected readonly error = signal<string | null>(null);
  protected readonly message = signal<string | null>(null);
  protected readonly busy = signal(false);

  protected sponsorName = '';
  protected sponsorOrganisation = '';
  protected sponsorAddress = '';
  protected poweredBy = '';

  /** Address lines as the app shows them (blank lines dropped). */
  protected addressLines(): string[] {
    return this.sponsorAddress.split('\n').map((l) => l.trim()).filter((l) => l.length > 0);
  }

  constructor() {
    this.api.branding().subscribe({
      next: (b) => this.apply(b),
      error: (e: unknown) => this.error.set(errorMessage(e)),
    });
  }

  protected save(): void {
    const text = {
      sponsorName: this.sponsorName,
      sponsorOrganisation: this.sponsorOrganisation,
      sponsorAddress: this.sponsorAddress,
      poweredBy: this.poweredBy,
    };
    this.run(this.api.saveBranding(text), 'Saved. The app shows it at the next start.');
  }

  protected upload(input: HTMLInputElement): void {
    const file = input.files?.[0];
    input.value = '';
    if (!file) return;
    if (file.size > MAX_LOGO_KB * 1024) {
      this.error.set(`The logo must be at most ${MAX_LOGO_KB} KB (this one is ${Math.round(file.size / 1024)} KB).`);
      return;
    }
    this.run(this.api.uploadSponsorLogo(file), 'Logo uploaded.');
  }

  protected removeLogo(): void {
    if (!confirm('Remove the sponsor logo?')) return;
    this.run(this.api.removeSponsorLogo(), 'Logo removed.');
  }

  private run(request: Observable<AppBranding>, success: string): void {
    this.busy.set(true);
    this.error.set(null);
    this.message.set(null);
    request.subscribe({
      next: (b) => {
        this.apply(b);
        this.busy.set(false);
        this.message.set(success);
      },
      error: (e: unknown) => {
        this.busy.set(false);
        this.error.set(errorMessage(e));
      },
    });
  }

  private apply(b: AppBranding): void {
    this.branding.set(b);
    this.sponsorName = b.sponsorName ?? '';
    this.sponsorOrganisation = b.sponsorOrganisation ?? '';
    this.sponsorAddress = b.sponsorAddress ?? '';
    this.poweredBy = b.poweredBy ?? '';
  }
}

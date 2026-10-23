import { DatePipe } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Observable } from 'rxjs';

import { AdminApi } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { AppBranding, FooterSponsor, FooterSponsorInput } from '../../core/models';

const MAX_LOGO_KB = 300;
const IQ_EXPLORE_PLAY_URL = 'https://play.google.com/store/apps/details?id=com.iqexplore.app';

const emptySponsor = (order: number): FooterSponsorInput => ({
  name: '',
  designation: '',
  companyName: '',
  displayOrder: order,
  isActive: true,
});

/** Sponsor (name, organisation, address), footer sponsors and "Technology Powered by" shown in the app (Super Admin only). */
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
  protected poweredByUrl = '';

  protected readonly footerSponsors = signal<FooterSponsor[]>([]);
  /** The sponsor being added (id null) or edited; null when the form is closed. */
  protected editing: { id: number | null; value: FooterSponsorInput } | null = null;

  /** What the app's footer scrolls: active sponsors, in order, "Name, Designation, Company". */
  protected readonly footerLine = computed(() =>
    this.footerSponsors()
      .filter((s) => s.isActive)
      .map((s) => [s.name, s.designation, s.companyName].filter((p) => !!p).join(', '))
      .join('   •   '),
  );

  /** Address lines as the app shows them (blank lines dropped). */
  protected addressLines(): string[] {
    return this.sponsorAddress.split('\n').map((l) => l.trim()).filter((l) => l.length > 0);
  }

  constructor() {
    this.api.branding().subscribe({
      next: (b) => this.apply(b),
      error: (e: unknown) => this.error.set(errorMessage(e)),
    });
    this.loadSponsors();
  }

  private loadSponsors(): void {
    this.api.footerSponsors().subscribe({
      next: (list) => this.footerSponsors.set(list),
      error: (e: unknown) => this.error.set(errorMessage(e)),
    });
  }

  protected addSponsor(): void {
    const last = this.footerSponsors().reduce((max, s) => Math.max(max, s.displayOrder), 0);
    this.editing = { id: null, value: emptySponsor(last + 10) };
  }

  protected editSponsor(s: FooterSponsor): void {
    this.editing = {
      id: s.id,
      value: {
        name: s.name,
        designation: s.designation ?? '',
        companyName: s.companyName ?? '',
        displayOrder: s.displayOrder,
        isActive: s.isActive,
      },
    };
  }

  protected saveSponsor(): void {
    const editing = this.editing;
    if (!editing) return;
    this.sponsorRequest(this.api.saveFooterSponsor(editing.id, editing.value), editing.id === null ? 'Sponsor added.' : 'Sponsor saved.');
  }

  protected toggleSponsor(s: FooterSponsor): void {
    const value = { name: s.name, designation: s.designation ?? '', companyName: s.companyName ?? '', displayOrder: s.displayOrder, isActive: !s.isActive };
    this.sponsorRequest(this.api.saveFooterSponsor(s.id, value), value.isActive ? 'Sponsor shown in the app.' : 'Sponsor hidden from the app.');
  }

  protected deleteSponsor(s: FooterSponsor): void {
    if (!confirm(`Remove ${s.name} from the sponsor list? To hide a sponsor for now, make it inactive instead.`)) return;
    this.sponsorRequest(this.api.deleteFooterSponsor(s.id), 'Sponsor removed.');
  }

  private sponsorRequest(request: Observable<unknown>, success: string): void {
    this.busy.set(true);
    this.error.set(null);
    this.message.set(null);
    request.subscribe({
      next: () => {
        this.busy.set(false);
        this.editing = null;
        this.message.set(`${success} The app shows it at the next start.`);
        this.loadSponsors();
      },
      error: (e: unknown) => {
        this.busy.set(false);
        this.error.set(errorMessage(e));
      },
    });
  }

  protected useIqExploreLink(): void {
    this.poweredByUrl = IQ_EXPLORE_PLAY_URL;
  }

  protected save(): void {
    const text = {
      sponsorName: this.sponsorName,
      sponsorOrganisation: this.sponsorOrganisation,
      sponsorAddress: this.sponsorAddress,
      poweredBy: this.poweredBy,
      poweredByUrl: this.poweredByUrl,
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
    this.poweredByUrl = b.poweredByUrl ?? '';
  }
}

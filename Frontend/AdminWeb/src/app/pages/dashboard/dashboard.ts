import { Component, computed, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';

import { AdminApi } from '../../core/admin-api.service';
import { errorMessage } from '../../core/api';
import { Summary } from '../../core/models';
import { ChartView } from '../../shared/chart';

/** Headline cards, breakdown charts and the district table for active members. */
@Component({
  selector: 'app-dashboard',
  imports: [RouterLink, ChartView],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.scss',
})
export class Dashboard {
  private readonly api = inject(AdminApi);
  protected readonly summary = signal<Summary | null>(null);
  protected readonly error = signal<string | null>(null);

  /** Total of the district table, for the share column. */
  protected readonly districtTotal = computed(() => this.summary()?.byDistrict.reduce((sum, d) => sum + d.count, 0) ?? 0);

  /** Temple names read "Temple name, Place": the axis shows the place, the tooltip the full name. */
  protected readonly templeTick = (name: string): string => {
    const place = name.includes(',') ? name.slice(name.lastIndexOf(',') + 1).trim() : name;
    return place.length > 16 ? `${place.slice(0, 15)}…` : place;
  };

  constructor() {
    this.api.summary().subscribe({
      next: (s) => this.summary.set(s),
      error: (e: unknown) => this.error.set(errorMessage(e)),
    });
  }

  protected share(count: number): string {
    const total = this.districtTotal();
    return total ? `${((count / total) * 100).toFixed(1)}%` : '';
  }
}

import { Component, ElementRef, OnDestroy, computed, effect, input, viewChild } from '@angular/core';
import {
  ArcElement, BarController, BarElement, CategoryScale, Chart, ChartConfiguration, LinearScale, PieController, Tooltip,
} from 'chart.js';

import { CountItem } from '../core/models';

Chart.register(BarController, BarElement, CategoryScale, LinearScale, PieController, ArcElement, Tooltip);

/**
 * Validated categorical palette (fixed order, never cycled) - checked with the dataviz palette validator against the
 * white panel surface. Three slots are below 3:1 contrast, so every pie carries a visible legend with values.
 */
export const SERIES = ['#2a78d6', '#eb6834', '#1baf7a', '#eda100', '#e87ba4', '#008300'];
const SINGLE_SERIES = SERIES[0];
const INK_MUTED = '#5b6676';
const GRID = '#e6e9ef';
const SURFACE = '#ffffff';

export type ChartKind = 'column' | 'bar' | 'pie';

/**
 * Column (vertical bars), bar (horizontal bars) or pie chart of label/count pairs, with hover tooltips.
 * Pies get an HTML legend (swatch, label, count, share) so identity never depends on colour alone.
 */
@Component({
  selector: 'app-chart',
  template: `
    @if (hasData()) {
      <div class="chart" [class.pie]="kind() === 'pie'">
        <div class="canvas" [style.height.px]="height()">
          <canvas #canvas role="img" [attr.aria-label]="ariaLabel()"></canvas>
        </div>
        @if (kind() === 'pie') {
          <ul class="legend">
            @for (item of shown(); track item.label; let i = $index) {
              <li>
                <span class="swatch" [style.background]="colour(i)"></span>
                <span class="name">{{ item.label }}</span>
                <span class="value">{{ item.count }}</span>
                <span class="share">{{ share(item.count) }}</span>
              </li>
            }
          </ul>
        }
      </div>
    } @else {
      <p class="empty" [style.height.px]="height()">No data yet.</p>
    }
  `,
  styleUrl: './chart.scss',
})
export class ChartView implements OnDestroy {
  readonly kind = input.required<ChartKind>();
  readonly items = input.required<CountItem[]>();
  /** Short axis label for long names (the tooltip always shows the full name). */
  readonly tickLabel = input<(label: string) => string>((l) => (l.length > 16 ? `${l.slice(0, 15)}…` : l));
  readonly height = input(280);
  readonly ariaLabel = input('Chart');

  private readonly canvas = viewChild<ElementRef<HTMLCanvasElement>>('canvas');
  private chart: Chart | null = null;

  /** Pies show at most 6 slices (5 + "Other") so a colour is never reused. */
  protected readonly shown = computed(() => {
    const items = this.items();
    if (this.kind() !== 'pie' || items.length <= SERIES.length) return items;
    const rest = items.slice(SERIES.length - 1).reduce((sum, i) => sum + i.count, 0);
    return [...items.slice(0, SERIES.length - 1), { label: 'Other', count: rest }];
  });
  protected readonly hasData = computed(() => this.shown().some((i) => i.count > 0));
  private readonly total = computed(() => this.shown().reduce((sum, i) => sum + i.count, 0));

  constructor() {
    effect(() => {
      const canvas = this.canvas()?.nativeElement;
      const config = this.config();
      this.chart?.destroy();
      this.chart = canvas ? new Chart(canvas, config) : null;
    });
  }

  ngOnDestroy(): void {
    this.chart?.destroy();
  }

  protected colour(index: number): string {
    return SERIES[index];
  }

  protected share(count: number): string {
    const total = this.total();
    return total ? `${Math.round((count / total) * 100)}%` : '';
  }

  private config(): ChartConfiguration {
    const items = this.shown();
    const labels = items.map((i) => i.label);
    const data = items.map((i) => i.count);
    const tooltip = {
      backgroundColor: '#1c2430',
      padding: 10,
      cornerRadius: 6,
      displayColors: this.kind() === 'pie',
      callbacks: {
        label: (ctx: { parsed: number | { x: number; y: number }; dataIndex: number }) => {
          const value = data[ctx.dataIndex];
          return ` ${value} member${value === 1 ? '' : 's'} (${this.share(value)})`;
        },
      },
    };

    if (this.kind() === 'pie') {
      return {
        type: 'pie',
        data: {
          labels,
          datasets: [{ data, backgroundColor: items.map((_, i) => this.colour(i)), borderColor: SURFACE, borderWidth: 2, hoverOffset: 6 }],
        },
        options: { maintainAspectRatio: false, plugins: { legend: { display: false }, tooltip } },
      };
    }

    const horizontal = this.kind() === 'bar';
    const short = this.tickLabel();
    const categoryAxis = {
      grid: { display: false },
      border: { color: '#c3c8d2' },
      ticks: { color: INK_MUTED, autoSkip: false, maxRotation: 45, callback: (_: unknown, i: number) => short(labels[i]) },
    };
    const valueAxis = {
      beginAtZero: true,
      grid: { color: GRID },
      border: { display: false },
      ticks: { color: INK_MUTED, precision: 0 },
    };
    return {
      type: 'bar',
      data: {
        labels,
        datasets: [{
          data,
          backgroundColor: SINGLE_SERIES,
          hoverBackgroundColor: '#1c5cab',
          borderRadius: 4,
          borderSkipped: 'start',
          maxBarThickness: 40,
          categoryPercentage: 0.8,
          barPercentage: 0.9,
        }],
      },
      options: {
        indexAxis: horizontal ? 'y' : 'x',
        maintainAspectRatio: false,
        scales: horizontal ? { y: categoryAxis, x: valueAxis } : { x: categoryAxis, y: valueAxis },
        plugins: { legend: { display: false }, tooltip },
      },
    } as ChartConfiguration;
  }
}

import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';

import { I18n } from '../../i18n/i18n';
import { Icon } from '../../shared/icon';
import { StatusBadge } from '../../shared/status-badge';

@Component({
  selector: 'vs-features',
  imports: [RouterLink, Icon, StatusBadge],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @let m = t().features;
    <section class="page-hero">
      <div class="container">
        <h1>{{ m.title }}</h1>
        <p class="lead">{{ m.lead }}</p>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <aside class="legend card" aria-labelledby="legend-title">
          <h2 id="legend-title">{{ m.legendTitle }}</h2>
          <dl>
            <div>
              <dt><vs-status-badge status="available" /></dt>
              <dd>{{ m.legend.available }}</dd>
            </div>
            <div>
              <dt><vs-status-badge status="planned" /></dt>
              <dd>{{ m.legend.planned }}</dd>
            </div>
            <div>
              <dt><vs-status-badge status="future" /></dt>
              <dd>{{ m.legend.future }}</dd>
            </div>
          </dl>
        </aside>

        <ul class="grid cols-3 modules">
          @for (f of m.modules; track f.title) {
            <li class="card module" [class.not-yet]="f.status !== 'available'">
              <div class="top">
                <span class="icon-tile"><vs-icon [name]="f.icon" /></span>
                <vs-status-badge [status]="f.status" />
              </div>
              <h2 class="h3">{{ f.title }}</h2>
              <ul class="checklist">
                @for (point of f.points; track point) {
                  <li>{{ point }}</li>
                }
              </ul>
            </li>
          }
        </ul>
      </div>
    </section>

    <section class="cta-band">
      <div class="container inner">
        <h2>{{ m.ctaTitle }}</h2>
        <a class="btn light large" routerLink="/for-organizations">{{ m.ctaButton }}</a>
      </div>
    </section>
  `,
  styles: `
    .legend {
      margin-bottom: 40px;

      h2 {
        font-size: 1.1rem;
      }
      dl {
        display: grid;
        gap: 10px;
        margin: 0;
      }
      dl > div {
        display: grid;
        grid-template-columns: 170px 1fr;
        align-items: start;
        gap: 12px;
      }
      dd {
        margin: 0;
        color: var(--vs-text-muted);
      }
    }
    .modules {
      margin: 0;
      padding: 0;
      list-style: none;
    }
    .module .top {
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: 12px;
    }
    .h3 {
      font-size: 1.15rem;
    }
    .not-yet {
      background: var(--vs-surface-muted);
      box-shadow: none;
    }
    @media (max-width: 560px) {
      .legend dl > div {
        grid-template-columns: 1fr;
        gap: 4px;
      }
    }
  `,
})
export class Features {
  protected readonly t = inject(I18n).messages;
}

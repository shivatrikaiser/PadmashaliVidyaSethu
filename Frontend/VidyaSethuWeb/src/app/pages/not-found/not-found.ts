import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';

import { I18n } from '../../i18n/i18n';

/** Unknown routes. Prerendered as /404 and served by the host with status 404 (staticwebapp.config.json). */
@Component({
  selector: 'vs-not-found',
  imports: [RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @let m = t().notFound;
    <section class="section">
      <div class="container wrap">
        <p class="code" aria-hidden="true">404</p>
        <h1>{{ m.title }}</h1>
        <p>{{ m.text }}</p>
        <div class="actions">
          <a class="btn" routerLink="/">{{ m.home }}</a>
          <a class="btn secondary" routerLink="/organizations">{{ m.organizations }}</a>
        </div>
      </div>
    </section>
  `,
  styles: `
    .wrap {
      max-width: 640px;
      text-align: center;
    }
    .code {
      margin: 0;
      font-size: 5rem;
      font-weight: 800;
      line-height: 1;
      color: var(--vs-navy-soft);
      -webkit-text-stroke: 2px var(--vs-navy);
    }
    .actions {
      justify-content: center;
      margin-top: 24px;
    }
  `,
})
export class NotFound {
  protected readonly t = inject(I18n).messages;
}

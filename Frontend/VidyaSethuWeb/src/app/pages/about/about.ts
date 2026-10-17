import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';

import { I18n } from '../../i18n/i18n';

@Component({
  selector: 'vs-about',
  imports: [RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @let m = t().about;
    <section class="page-hero">
      <div class="container">
        <h1>{{ m.title }}</h1>
        <p class="lead">{{ m.lead }}</p>
      </div>
    </section>

    <section class="section">
      <div class="container prose">
        @for (s of m.sections; track s.heading) {
          <h2>{{ s.heading }}</h2>
          @for (p of s.paragraphs; track $index) {
            <p>{{ p }}</p>
          }
        }
        <div class="actions">
          <a class="btn" routerLink="/organizations">{{ t().home.primaryCta }}</a>
          <a class="btn secondary" routerLink="/features">{{ t().nav.features }}</a>
        </div>
      </div>
    </section>
  `,
  styles: `
    .actions {
      margin-top: 40px;
    }
  `,
})
export class About {
  protected readonly t = inject(I18n).messages;
}

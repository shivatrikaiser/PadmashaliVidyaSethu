import { ChangeDetectionStrategy, Component, computed, inject, input } from '@angular/core';

import { SITE_CONFIG } from '../../core/site-config';
import { I18n, Messages } from '../../i18n/i18n';
import { Icon } from '../../shared/icon';

type LegalDocumentKey = keyof Messages['legal'];

/**
 * /privacy, /terms, /accessibility and the Padmashali Vidya Sethu app documents (route data `document`). Shows a draft
 * notice until legal review approves.
 */
@Component({
  selector: 'vs-legal',
  imports: [Icon],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @let d = doc();
    <section class="page-hero">
      <div class="container">
        <h1>{{ d.title }}</h1>
        <p class="updated">{{ t().common.lastUpdated }}: {{ d.lastUpdated }}</p>
      </div>
    </section>

    <section class="section">
      <div class="container prose">
        @if (!approved) {
          <div class="notice warning draft" role="note" data-testid="legal-draft">
            <vs-icon name="info" [size]="22" />
            <p>{{ t().common.draftNotice }}</p>
          </div>
        }
        <p class="intro">{{ d.intro }}</p>
        @for (s of d.sections; track s.heading) {
          <h2>{{ s.heading }}</h2>
          @for (p of s.paragraphs; track $index) {
            <p>{{ p }}</p>
          }
        }
      </div>
    </section>
  `,
  styles: `
    .updated {
      margin: 0;
      color: var(--vs-text-muted);
    }
    .draft {
      margin-bottom: 32px;
    }
    .intro {
      font-size: 1.1rem;
    }
  `,
})
export class Legal {
  protected readonly t = inject(I18n).messages;
  protected readonly approved = inject(SITE_CONFIG).legalPagesApproved;

  /** From route data. */
  readonly document = input<LegalDocumentKey>('privacy');
  protected readonly doc = computed(() => this.t().legal[this.document()]);
}

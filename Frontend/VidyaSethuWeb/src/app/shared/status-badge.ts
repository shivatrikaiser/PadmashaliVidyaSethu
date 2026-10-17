import { ChangeDetectionStrategy, Component, computed, inject, input } from '@angular/core';

import { I18n } from '../i18n/i18n';
import type { FeatureStatus } from '../i18n/en/pages';

/** "Implemented in PVS" / "Planned" / "Future" label, so planned features are never mistaken for live ones. */
@Component({
  selector: 'vs-status-badge',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `<span class="badge" [class]="status()">{{ label() }}</span>`,
  styles: `
    .badge {
      display: inline-block;
      padding: 3px 10px;
      font-size: 0.78rem;
      font-weight: 600;
      line-height: 1.4;
      border-radius: 999px;
      white-space: nowrap;
    }
    .available {
      color: var(--vs-success);
      background: var(--vs-success-bg);
    }
    .planned {
      color: var(--vs-navy);
      background: var(--vs-navy-soft);
    }
    .future {
      color: var(--vs-text-muted);
      background: var(--vs-surface-muted);
    }
  `,
})
export class StatusBadge {
  private readonly i18n = inject(I18n);
  readonly status = input.required<FeatureStatus>();
  readonly label = computed(() => this.i18n.messages().common.status[this.status()]);
}

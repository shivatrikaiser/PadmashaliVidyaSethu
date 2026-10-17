import { ChangeDetectionStrategy, Component, computed, inject, input } from '@angular/core';
import { RouterLink } from '@angular/router';

import { I18n } from '../i18n/i18n';
import type { Organization } from '../organizations/organization.model';
import { Icon } from './icon';

/** Directory card. The whole card is clickable through the heading link (one tab stop per card). */
@Component({
  selector: 'vs-organization-card',
  imports: [RouterLink, Icon],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <article class="card" [style.--org-accent]="accent()">
      @if (org().logo; as logo) {
        <img
          class="logo"
          [src]="'/' + logo.src"
          [alt]="i18n.text(logo.alt)"
          [width]="logo.width"
          [height]="logo.height"
          loading="lazy"
        />
      }
      <div class="body">
        <p class="category">{{ t().organizations.categories[org().category] }}</p>
        <div class="name" role="heading" [attr.aria-level]="headingLevel()">
          <a
            [routerLink]="['/organizations', org().slug]"
            [attr.aria-label]="t().organizations.viewOrganization(name())"
          >
            {{ name() }}
          </a>
        </div>
        @if (org().operatedBy; as by) {
          <p class="by">{{ t().organization.operatedBy(i18n.text(by)) }}</p>
        }
        <p class="description">{{ i18n.text(org().description) }}</p>
        <span class="more" aria-hidden="true">
          {{ t().common.learnMore }} <vs-icon name="arrowRight" [size]="18" />
        </span>
      </div>
    </article>
  `,
  styles: `
    .card {
      position: relative;
      display: flex;
      gap: 20px;
      height: 100%;
      padding: 24px;
      background: var(--vs-surface);
      border: 1px solid var(--vs-border);
      border-top: 4px solid var(--org-accent, var(--vs-navy));
      border-radius: var(--vs-radius-lg);
      box-shadow: var(--vs-shadow-sm);
      transition:
        box-shadow 0.15s ease,
        transform 0.15s ease;

      &:hover {
        box-shadow: var(--vs-shadow-md);
        transform: translateY(-2px);
      }
      &:focus-within {
        outline: 3px solid var(--vs-focus);
        outline-offset: 2px;
      }
    }
    .logo {
      flex: none;
      width: 96px;
      height: 96px;
      object-fit: contain;
      border-radius: var(--vs-radius);
      background: #fff;
    }
    .body {
      display: flex;
      flex-direction: column;
      min-width: 0;
    }
    .category {
      margin: 0 0 4px;
      font-size: 0.8rem;
      font-weight: 600;
      letter-spacing: 0.04em;
      text-transform: uppercase;
      color: var(--vs-sky-text);
    }
    .name {
      margin: 0;
      font-size: 1.2rem;
      font-weight: 700;
      line-height: 1.3;
    }
    a {
      color: var(--vs-navy);
      text-decoration: none;

      &::after {
        content: '';
        position: absolute;
        inset: 0;
      }
      &:focus-visible {
        outline: none;
      }
    }
    .by {
      margin: 4px 0 0;
      font-size: 0.9rem;
      color: var(--vs-text-muted);
    }
    .description {
      margin: 12px 0 16px;
      color: var(--vs-text);
    }
    .more {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      margin-top: auto;
      font-weight: 600;
      color: var(--vs-link);
    }
    @media (max-width: 520px) {
      .card {
        flex-direction: column;
      }
      .logo {
        width: 80px;
        height: 80px;
      }
    }
    @media (prefers-reduced-motion: reduce) {
      .card {
        transition: none;
        &:hover {
          transform: none;
        }
      }
    }
  `,
})
export class OrganizationCard {
  protected readonly i18n = inject(I18n);
  protected readonly t = this.i18n.messages;

  readonly org = input.required<Organization>();
  /** Heading level of the organization name: 2 when the cards sit directly under the page's h1. */
  readonly headingLevel = input<2 | 3>(3);
  protected readonly name = computed(() => this.i18n.text(this.org().displayName));
  protected readonly accent = computed(() => {
    const b = this.org().branding;
    return b.useOwnBranding ? b.primaryColor : null;
  });
}

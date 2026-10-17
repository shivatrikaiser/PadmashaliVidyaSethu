import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';

import { EnquiryForm } from '../../enquiry/enquiry-form';
import { I18n } from '../../i18n/i18n';
import { Icon } from '../../shared/icon';
import { StatusBadge } from '../../shared/status-badge';

@Component({
  selector: 'vs-for-organizations',
  imports: [RouterLink, Icon, StatusBadge, EnquiryForm],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @let m = t().forOrganizations;
    <section class="page-hero">
      <div class="container">
        <p class="eyebrow">{{ t().nav.forOrganizations }}</p>
        <h1>{{ m.title }}</h1>
        <p class="lead">{{ m.lead }}</p>
        <a class="btn large" routerLink="/for-organizations" fragment="enquiry">{{ m.cta }}</a>
      </div>
    </section>

    <section class="section" aria-labelledby="benefits-title">
      <div class="container">
        <div class="section-head">
          <h2 id="benefits-title">{{ m.benefitsTitle }}</h2>
        </div>
        <ul class="grid cols-4 plain">
          @for (b of m.benefits; track b.title) {
            <li class="card">
              <span class="icon-tile"><vs-icon [name]="b.icon" /></span>
              <h3>{{ b.title }}</h3>
              <p>{{ b.text }}</p>
            </li>
          }
        </ul>
      </div>
    </section>

    <section class="section muted" aria-labelledby="modules-title">
      <div class="container">
        <div class="section-head">
          <h2 id="modules-title">{{ m.modulesTitle }}</h2>
          <p>
            {{ m.modulesLead }}
            <a routerLink="/features">{{ t().nav.features }}</a>
          </p>
        </div>
        <ul class="modules plain">
          @for (f of t().features.modules; track f.title) {
            <li>
              <vs-icon [name]="f.icon" [size]="20" />
              <span class="name">{{ f.title }}</span>
              <vs-status-badge [status]="f.status" />
            </li>
          }
        </ul>
      </div>
    </section>

    <section class="section">
      <div class="container grid cols-2">
        <div class="card">
          <h2 class="h3">{{ m.brandingTitle }}</h2>
          <p>{{ m.brandingText }}</p>
        </div>
        <div class="card">
          <h2 class="h3">{{ m.adminTitle }}</h2>
          <p>{{ m.adminText }}</p>
        </div>
      </div>
    </section>

    <section class="section muted" aria-labelledby="onboarding-title">
      <div class="container">
        <div class="section-head">
          <h2 id="onboarding-title">{{ m.onboardingTitle }}</h2>
        </div>
        <ol class="steps">
          @for (s of m.onboarding; track s.title) {
            <li>
              <h3>{{ s.title }}</h3>
              <p>{{ s.text }}</p>
            </li>
          }
        </ol>
      </div>
    </section>

    <section class="section" id="enquiry" aria-labelledby="enquiry-title">
      <div class="container form-wrap">
        <div class="section-head">
          <h2 id="enquiry-title">{{ m.enquiryTitle }}</h2>
          <p>{{ m.enquiryLead }}</p>
        </div>
        <div class="card">
          <vs-enquiry-form category="organization" idPrefix="org-enquiry" />
        </div>
      </div>
    </section>
  `,
  styles: `
    .plain {
      margin: 0;
      padding: 0;
      list-style: none;
    }
    .modules {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(min(100%, 340px), 1fr));
      gap: 12px;

      li {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 14px 16px;
        background: var(--vs-surface);
        border: 1px solid var(--vs-border);
        border-radius: var(--vs-radius);
      }
      vs-icon {
        color: var(--vs-sky-text);
      }
      .name {
        flex: 1;
        font-weight: 600;
      }
    }
    .h3 {
      font-size: 1.25rem;
    }
    .form-wrap {
      max-width: 820px;
    }
  `,
})
export class ForOrganizations {
  protected readonly t = inject(I18n).messages;
}

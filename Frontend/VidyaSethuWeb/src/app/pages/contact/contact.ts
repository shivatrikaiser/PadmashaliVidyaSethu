import { ChangeDetectionStrategy, Component, inject } from '@angular/core';

import { SITE_CONFIG } from '../../core/site-config';
import { EnquiryForm } from '../../enquiry/enquiry-form';
import { I18n } from '../../i18n/i18n';

@Component({
  selector: 'vs-contact',
  imports: [EnquiryForm],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @let m = t().contact;
    <section class="page-hero">
      <div class="container">
        <h1>{{ m.title }}</h1>
        <p class="lead">{{ m.lead }}</p>
      </div>
    </section>

    <section class="section">
      <div class="container layout">
        <div class="card">
          <h2 class="h3">{{ m.formTitle }}</h2>
          <vs-enquiry-form category="general" idPrefix="contact" />
        </div>

        <aside class="side">
          <div class="card">
            <h2 class="h3">{{ m.detailsTitle }}</h2>
            <dl>
              <dt>{{ m.labels.company }}</dt>
              <dd>{{ company.legalName }}</dd>
              @if (company.email) {
                <dt>{{ m.labels.email }}</dt>
                <dd>
                  <a [href]="'mailto:' + company.email">{{ company.email }}</a>
                </dd>
              }
              @if (company.phone) {
                <dt>{{ m.labels.phone }}</dt>
                <dd>
                  <a [href]="'tel:' + company.phone">{{ company.phone }}</a>
                </dd>
              }
              @if (company.address) {
                <dt>{{ m.labels.address }}</dt>
                <dd>{{ company.address }}</dd>
              }
            </dl>
            @if (!company.email && !company.phone && !company.address) {
              <p class="pending" data-testid="contact-pending">{{ m.detailsPending }}</p>
            }
          </div>

          <div class="card">
            <h2 class="h3">{{ m.membersTitle }}</h2>
            <p>{{ m.membersText }}</p>
          </div>
        </aside>
      </div>
    </section>
  `,
  styles: `
    .layout {
      display: grid;
      grid-template-columns: minmax(0, 1.6fr) minmax(0, 1fr);
      gap: 32px;
      align-items: start;
    }
    .side {
      display: grid;
      gap: 20px;
    }
    .h3 {
      font-size: 1.25rem;
      margin-bottom: 16px;
    }
    dl {
      margin: 0;
    }
    dt {
      font-weight: 600;
    }
    dd {
      margin: 0 0 10px;
      overflow-wrap: anywhere;
    }
    .pending {
      margin-top: 12px;
      color: var(--vs-text-muted);
    }
    @media (max-width: 900px) {
      .layout {
        grid-template-columns: 1fr;
      }
    }
  `,
})
export class Contact {
  protected readonly t = inject(I18n).messages;
  protected readonly company = inject(SITE_CONFIG).company;
}

import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';

import { I18n } from '../../i18n/i18n';
import { OrganizationDirectory } from '../../organizations/organization-directory';
import { OrganizationCard } from '../../shared/organization-card';

@Component({
  selector: 'vs-organizations',
  imports: [RouterLink, OrganizationCard],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @let m = t().organizations;
    <section class="page-hero">
      <div class="container">
        <h1>{{ m.title }}</h1>
        <p class="lead">{{ m.lead }}</p>
      </div>
    </section>

    <section class="section">
      <div class="container">
        @if (organizations.length) {
          <ul class="grid cols-2 list">
            @for (org of organizations; track org.organizationId) {
              <li><vs-organization-card [org]="org" [headingLevel]="2" /></li>
            }
          </ul>
        } @else {
          <p>{{ m.empty }}</p>
        }
      </div>
    </section>

    <section class="cta-band">
      <div class="container inner">
        <h2>{{ m.joinTitle }}</h2>
        <a class="btn light large" routerLink="/for-organizations">{{ m.joinCta }}</a>
      </div>
    </section>
  `,
  styles: `
    .list {
      margin: 0;
      padding: 0;
      list-style: none;
    }
  `,
})
export class Organizations {
  protected readonly t = inject(I18n).messages;
  protected readonly organizations = inject(OrganizationDirectory).listed();
}

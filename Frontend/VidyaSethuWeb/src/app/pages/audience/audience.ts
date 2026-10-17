import { ChangeDetectionStrategy, Component, computed, inject, input } from '@angular/core';
import { RouterLink } from '@angular/router';

import { I18n } from '../../i18n/i18n';
import { OrganizationDirectory } from '../../organizations/organization-directory';
import { Icon } from '../../shared/icon';
import { OrganizationCard } from '../../shared/organization-card';
import { StatusBadge } from '../../shared/status-badge';

/**
 * /for-students and /for-job-seekers (route data `audience`). Joining always happens in an organization's portal -
 * this site has no registration of its own.
 */
@Component({
  selector: 'vs-audience',
  imports: [RouterLink, Icon, StatusBadge, OrganizationCard],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @let a = t().audience;
    @let m = content();
    <section class="page-hero">
      <div class="container">
        <h1>{{ m.title }}</h1>
        <p class="lead">{{ m.lead }}</p>
      </div>
    </section>

    <section class="section" aria-labelledby="benefits-title">
      <div class="container">
        <div class="section-head">
          <h2 id="benefits-title">{{ m.benefitsTitle }}</h2>
          <p>{{ a.statusNote }}</p>
        </div>
        <ul class="grid cols-4 plain">
          @for (b of m.benefits; track b.title) {
            <li class="card">
              <div class="top">
                <span class="icon-tile"><vs-icon [name]="b.icon" /></span>
                <vs-status-badge [status]="b.status" />
              </div>
              <h3>{{ b.title }}</h3>
              <p>{{ b.text }}</p>
            </li>
          }
        </ul>
      </div>
    </section>

    <section class="section muted" aria-labelledby="join-title">
      <div class="container">
        <div class="section-head">
          <h2 id="join-title">{{ a.joinTitle }}</h2>
          <p>{{ a.joinText }}</p>
        </div>
        @if (organizations.length) {
          <ul class="grid cols-2 plain">
            @for (org of organizations; track org.organizationId) {
              <li><vs-organization-card [org]="org" /></li>
            }
          </ul>
        } @else {
          <p>{{ t().organizations.empty }}</p>
        }
        <div class="card missing">
          <div>
            <h3>{{ a.noOrganizationTitle }}</h3>
            <p>{{ a.noOrganizationText }}</p>
          </div>
          <a class="btn secondary" routerLink="/for-organizations">{{ a.noOrganizationCta }}</a>
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
    .top {
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: 12px;
    }
    .missing {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      margin-top: 32px;
      box-shadow: none;
    }
  `,
})
export class Audience {
  protected readonly t = inject(I18n).messages;
  protected readonly organizations = inject(OrganizationDirectory).listed();

  /** From route data. */
  readonly audience = input<'students' | 'jobSeekers'>('students');
  protected readonly content = computed(() => this.t().audience[this.audience()]);
}

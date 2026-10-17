import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';

import { SITE_CONFIG } from '../../core/site-config';
import { I18n } from '../../i18n/i18n';
import { OrganizationDirectory } from '../../organizations/organization-directory';
import { Icon } from '../../shared/icon';
import { OrganizationCard } from '../../shared/organization-card';

@Component({
  selector: 'vs-home',
  imports: [RouterLink, Icon, OrganizationCard],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './home.html',
  styleUrl: './home.scss',
})
export class Home {
  protected readonly t = inject(I18n).messages;
  protected readonly organizations = inject(OrganizationDirectory).listed().slice(0, 3);
  protected readonly company = inject(SITE_CONFIG).company;
}

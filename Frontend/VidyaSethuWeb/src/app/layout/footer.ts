import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';

import { SITE_CONFIG } from '../core/site-config';
import { I18n } from '../i18n/i18n';
import { Logo } from '../shared/logo';

@Component({
  selector: 'vs-footer',
  imports: [RouterLink, Logo],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './footer.html',
  styleUrl: './footer.scss',
})
export class Footer {
  protected readonly t = inject(I18n).messages;
  protected readonly company = inject(SITE_CONFIG).company;
  protected readonly year = new Date().getFullYear();
}

import { ChangeDetectionStrategy, Component, computed, effect, inject, input } from '@angular/core';
import { RouterLink } from '@angular/router';

import { Seo } from '../../core/seo';
import { I18n } from '../../i18n/i18n';
import { OrganizationDirectory } from '../../organizations/organization-directory';
import { Icon } from '../../shared/icon';
import { safeExternalLink } from '../../core/safe-url';
import { SITE_CONFIG } from '../../core/site-config';

/**
 * /organizations/:slug - public page of one organization, with the button to its own portal.
 * The portal destination comes from configuration and is validated; when it is not configured the page says the
 * portal is not yet available instead of showing a link.
 */
@Component({
  selector: 'vs-organization-page',
  imports: [RouterLink, Icon],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './organization-page.html',
  styleUrl: './organization-page.scss',
})
export class OrganizationPage {
  protected readonly i18n = inject(I18n);
  protected readonly t = this.i18n.messages;
  private readonly directory = inject(OrganizationDirectory);
  private readonly config = inject(SITE_CONFIG);
  private readonly seo = inject(Seo);

  /** Route parameter (component input binding). */
  readonly slug = input<string>();

  protected readonly org = computed(() => this.directory.bySlug(this.slug()));
  protected readonly name = computed(() => {
    const org = this.org();
    return org ? this.i18n.text(org.displayName) : '';
  });
  protected readonly application = computed(() => {
    const org = this.org();
    return org ? this.directory.link(org, 'application') : null;
  });
  protected readonly deepLinks = computed(() => {
    const org = this.org();
    return org ? this.directory.deepLinks(org) : [];
  });
  protected readonly website = computed(() =>
    safeExternalLink(this.org()?.publicContact?.website, this.config),
  );
  protected readonly brandColor = computed(() => {
    const b = this.org()?.branding;
    return b?.useOwnBranding ? b.primaryColor : null;
  });

  constructor() {
    effect(() => {
      const org = this.org();
      const seo = this.t().seo;
      if (org) {
        this.seo.set({
          title: seo.organizationPage(this.name()),
          description: this.i18n.text(org.description),
          path: `/organizations/${org.slug}`,
          image: org.logo?.src,
        });
      } else {
        this.seo.set({
          ...seo.notFound,
          path: `/organizations/${this.slug() ?? ''}`,
          noIndex: true,
        });
      }
    });
  }
}

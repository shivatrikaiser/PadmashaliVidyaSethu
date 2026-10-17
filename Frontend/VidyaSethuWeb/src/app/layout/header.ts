import {
  ChangeDetectionStrategy,
  Component,
  DOCUMENT,
  DestroyRef,
  inject,
  signal,
} from '@angular/core';
import { NavigationEnd, Router, RouterLink, RouterLinkActive } from '@angular/router';
import { filter } from 'rxjs';

import { I18n } from '../i18n/i18n';
import { Icon } from '../shared/icon';
import { Logo } from '../shared/logo';
import { NAV_LINKS } from './nav-links';

/** Top bar. Below 1080px the navigation collapses behind a menu button. */
@Component({
  selector: 'vs-header',
  imports: [RouterLink, RouterLinkActive, Logo, Icon],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './header.html',
  styleUrl: './header.scss',
  host: { '(document:keydown.escape)': 'close()' },
})
export class Header {
  protected readonly t = inject(I18n).messages;
  protected readonly links = NAV_LINKS;
  protected readonly open = signal(false);
  private readonly document = inject(DOCUMENT);

  constructor() {
    const sub = inject(Router)
      .events.pipe(filter((e) => e instanceof NavigationEnd))
      .subscribe(() => this.open.set(false));
    inject(DestroyRef).onDestroy(() => sub.unsubscribe());
  }

  protected toggle(): void {
    this.open.update((v) => !v);
  }

  protected close(): void {
    this.open.set(false);
  }

  /** With <base href="/">, a plain "#main" link would navigate to the home page; move focus instead. */
  protected skipToMain(event: Event): void {
    const main = this.document.getElementById('main');
    if (!main) return;
    event.preventDefault();
    main.focus();
    main.scrollIntoView();
  }
}

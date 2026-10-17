import { Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';

import { Seo } from './core/seo';
import { Footer } from './layout/footer';
import { Header } from './layout/header';

@Component({
  selector: 'vs-root',
  imports: [RouterOutlet, Header, Footer],
  template: `
    <vs-header />
    <main id="main" tabindex="-1">
      <router-outlet />
    </main>
    <vs-footer />
  `,
  styles: `
    :host {
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    main {
      flex: 1;
    }
  `,
})
export class App {
  constructor() {
    inject(Seo).init();
  }
}

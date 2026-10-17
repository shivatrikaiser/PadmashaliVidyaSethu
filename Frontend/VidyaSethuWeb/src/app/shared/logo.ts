import { ChangeDetectionStrategy, Component, input } from '@angular/core';

/**
 * VidyaSethu logo (public/brand, generated from branding/vidyasethu-logo.png by scripts/generate-images.ps1) with the
 * name as text beside it: the lettering inside the logo is too small to read at header size, and text can be
 * translated. Decorative here - the surrounding link carries the accessible name.
 */
@Component({
  selector: 'vs-logo',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <img
      class="mark"
      src="/brand/vidyasethu-logo-96.png"
      srcset="/brand/vidyasethu-logo-96.png 1x, /brand/vidyasethu-logo-192.png 2x"
      alt=""
      [width]="size()"
      [height]="size()"
    />
    <span class="word" [class.inverse]="inverse()"
      ><span class="a">Vidya</span><span class="b">Sethu</span></span
    >
  `,
  styles: `
    :host {
      display: inline-flex;
      align-items: center;
      gap: 10px;
    }
    .mark {
      display: block;
      flex: none;
    }
    .word {
      font-size: 1.35rem;
      font-weight: 800;
      letter-spacing: -0.01em;
      line-height: 1;
    }
    .a {
      color: var(--vs-navy);
    }
    .b {
      color: #097cd6;
    }
    .inverse .a {
      color: #fff;
    }
    .inverse .b {
      color: var(--vs-sky-light);
    }
  `,
})
export class Logo {
  readonly size = input(48);
  readonly inverse = input(false);
}

import { ChangeDetectionStrategy, Component, OnInit, inject, input, signal } from '@angular/core';
import {
  AbstractControl,
  NonNullableFormBuilder,
  ReactiveFormsModule,
  ValidationErrors,
  Validators,
} from '@angular/forms';
import { Router, RouterLink } from '@angular/router';

import { SITE_CONFIG } from '../core/site-config';
import { I18n } from '../i18n/i18n';
import { Icon } from '../shared/icon';
import {
  ENQUIRY_CATEGORIES,
  ENQUIRY_MIN_FILL_MS,
  EnquiryCategory,
  EnquiryService,
} from './enquiry.service';

export const MESSAGE_MIN = 10;
export const MESSAGE_MAX = 2000;
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
const PHONE_PATTERN = /^\+?[0-9][0-9 ()-]{6,18}[0-9]$/;

export type EnquiryState = 'idle' | 'invalid' | 'tooFast' | 'sending' | 'success' | 'error';

function emailOrPhone(group: AbstractControl): ValidationErrors | null {
  const { email, phone } = group.value as { email: string; phone: string };
  return email.trim() || phone.trim() ? null : { emailOrPhone: true };
}

/**
 * Contact / demo enquiry form. Reports success only after the endpoint confirms (2xx). When no endpoint is configured
 * the form is shown disabled with a notice - nothing can be "sent".
 * Spam protection here: hidden honeypot field and a minimum fill time; the endpoint must also validate, rate-limit
 * and verify (see README "Enquiry endpoint").
 */
@Component({
  selector: 'vs-enquiry-form',
  imports: [ReactiveFormsModule, RouterLink, Icon],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './enquiry-form.html',
  styleUrl: './enquiry-form.scss',
})
export class EnquiryForm implements OnInit {
  private readonly i18n = inject(I18n);
  private readonly service = inject(EnquiryService);
  private readonly router = inject(Router);
  private readonly minFillMs = inject(ENQUIRY_MIN_FILL_MS);
  protected readonly t = this.i18n.messages;
  protected readonly companyEmail = inject(SITE_CONFIG).company.email;

  /** Pre-selected category. */
  readonly category = input<EnquiryCategory>('general');
  /** Prefix for element ids, so two forms could share a page. */
  readonly idPrefix = input('enquiry');

  protected readonly categories = ENQUIRY_CATEGORIES;
  protected readonly enabled = this.service.endpoint !== null;
  protected readonly state = signal<EnquiryState>('idle');
  protected readonly messageMin = MESSAGE_MIN;
  protected readonly messageMax = MESSAGE_MAX;
  private startedAt = Date.now();

  protected readonly form = inject(NonNullableFormBuilder).group(
    {
      category: ['general' as EnquiryCategory, Validators.required],
      name: ['', [Validators.required, Validators.minLength(2), Validators.maxLength(100)]],
      organization: ['', Validators.maxLength(150)],
      email: ['', [Validators.maxLength(254), Validators.pattern(EMAIL_PATTERN)]],
      phone: ['', Validators.pattern(PHONE_PATTERN)],
      message: [
        '',
        [Validators.required, Validators.minLength(MESSAGE_MIN), Validators.maxLength(MESSAGE_MAX)],
      ],
      consent: [false, Validators.requiredTrue],
      /** Honeypot: hidden from people, filled by bots. */
      website: [''],
    },
    { validators: emailOrPhone },
  );

  ngOnInit(): void {
    this.form.controls.category.setValue(this.category());
    if (!this.enabled) this.form.disable();
    this.startedAt = Date.now();
  }

  protected id(field: string): string {
    return `${this.idPrefix()}-${field}`;
  }

  protected showError(field: keyof typeof this.form.controls): boolean {
    const control = this.form.controls[field];
    return control.invalid && (control.touched || this.state() === 'invalid');
  }

  protected showContactError(): boolean {
    const { email, phone } = this.form.controls;
    return (
      this.form.hasError('emailOrPhone') &&
      ((email.touched && phone.touched) || this.state() === 'invalid')
    );
  }

  protected submit(): void {
    if (!this.enabled || this.state() === 'sending') return;

    if (this.form.invalid) {
      this.form.markAllAsTouched();
      this.state.set('invalid');
      return;
    }

    const value = this.form.getRawValue();
    const elapsedMs = Date.now() - this.startedAt;
    // Automated submissions: the honeypot is filled, or the form was completed impossibly fast. Nothing is sent and
    // nothing claims success.
    if (value.website.trim()) {
      this.state.set('error');
      return;
    }
    if (elapsedMs < this.minFillMs) {
      this.state.set('tooFast');
      return;
    }

    this.state.set('sending');
    this.service
      .submit({
        category: value.category,
        name: value.name.trim(),
        organization: value.organization.trim() || null,
        email: value.email.trim() || null,
        phone: value.phone.trim() || null,
        message: value.message.trim(),
        consent: true,
        locale: this.i18n.locale(),
        page: this.router.url.split(/[?#]/)[0],
        elapsedMs,
      })
      .subscribe({
        next: () => {
          this.state.set('success');
          this.form.reset({ category: value.category });
          this.startedAt = Date.now();
        },
        error: () => this.state.set('error'),
      });
  }
}

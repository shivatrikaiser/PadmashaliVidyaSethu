import { Component, inject, signal } from '@angular/core';
import { NonNullableFormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';

import { errorMessage } from '../../core/api';
import { AuthService, CodeIssued } from '../../core/auth.service';

/** Two steps: mobile number, then the verification code sent by SMS. */
@Component({
  selector: 'app-login',
  imports: [ReactiveFormsModule],
  templateUrl: './login.html',
  styleUrl: './login.scss',
})
export class Login {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  private readonly fb = inject(NonNullableFormBuilder);

  protected readonly phoneForm = this.fb.group({
    mobileNumber: ['', [Validators.required, Validators.pattern(/^[6-9]\d{9}$/)]],
  });
  protected readonly codeForm = this.fb.group({
    code: ['', [Validators.required, Validators.pattern(/^\d{4,8}$/)]],
  });

  protected readonly challenge = signal<CodeIssued | null>(null);
  protected readonly busy = signal(false);
  protected readonly error = signal<string | null>(null);

  protected sendCode(): void {
    if (this.phoneForm.invalid) {
      this.phoneForm.markAllAsTouched();
      return;
    }
    this.run(() =>
      this.auth.requestCode(this.phoneForm.getRawValue().mobileNumber).subscribe({
        next: (issued) => {
          this.challenge.set(issued);
          this.codeForm.reset();
          this.busy.set(false);
        },
        error: (e: unknown) => this.fail(e),
      }),
    );
  }

  protected verify(): void {
    const challenge = this.challenge();
    if (!challenge || this.codeForm.invalid) {
      this.codeForm.markAllAsTouched();
      return;
    }
    this.run(() =>
      this.auth.verifyCode(challenge.challengeId, this.codeForm.getRawValue().code).subscribe({
        next: () => void this.router.navigate(['/']),
        error: (e: unknown) => this.fail(e),
      }),
    );
  }

  protected changeNumber(): void {
    this.challenge.set(null);
    this.error.set(null);
  }

  private run(start: () => void): void {
    this.busy.set(true);
    this.error.set(null);
    start();
  }

  private fail(e: unknown): void {
    this.busy.set(false);
    this.error.set(errorMessage(e));
  }
}

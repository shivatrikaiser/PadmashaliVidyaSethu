import { Component, inject, signal } from '@angular/core';
import { NonNullableFormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';

import { errorMessage } from '../../core/api';
import { AuthService } from '../../core/auth.service';

/** Mobile number + password. Passwords are set by a Super Admin (Admin users page); there is no self-service reset. */
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

  protected readonly form = this.fb.group({
    mobileNumber: ['', [Validators.required, Validators.pattern(/^[6-9]\d{9}$/)]],
    password: ['', [Validators.required]],
  });

  protected readonly busy = signal(false);
  protected readonly error = signal<string | null>(null);
  protected readonly showPassword = signal(false);

  protected signIn(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    const { mobileNumber, password } = this.form.getRawValue();
    this.busy.set(true);
    this.error.set(null);
    this.auth.signIn(mobileNumber, password).subscribe({
      next: () => void this.router.navigate(['/']),
      error: (e: unknown) => {
        this.busy.set(false);
        this.form.controls.password.reset();
        this.error.set(errorMessage(e));
      },
    });
  }
}

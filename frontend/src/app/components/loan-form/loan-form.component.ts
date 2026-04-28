import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, ChangeDetectorRef, Component, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { HttpErrorResponse } from '@angular/common/http';

import { LoanRequest } from '../../models/loan-request';
import { LoanDecision, LoanResponse } from '../../models/loan-response';
import { LoanService } from '../../services/loan.service';

@Component({
  selector: 'app-loan-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatProgressSpinnerModule,
    MatSnackBarModule,
    MatCardModule
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './loan-form.component.html',
  styleUrl: './loan-form.component.scss'
})
export class LoanFormComponent {
  private readonly fb = inject(FormBuilder);
  private readonly loanService = inject(LoanService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly cdr = inject(ChangeDetectorRef);

  readonly submitting = signal(false);
  readonly result = signal<LoanResponse | null>(null);
  readonly errorMessage = signal<string | null>(null);

  readonly form: FormGroup = this.fb.group({
    applicantName: ['', [Validators.required, Validators.minLength(2)]],
    requestedAmount: [null as number | null, [Validators.required, Validators.min(1)]],
    taxId: ['', [Validators.required, Validators.pattern(/^[0-9-]{4,15}$/)]]
  });

  onSubmit(): void {
    if (this.form.invalid || this.submitting()) {
      return;
    }
    const request: LoanRequest = {
      applicantName: this.form.value.applicantName as string,
      requestedAmount: Number(this.form.value.requestedAmount),
      taxId: this.form.value.taxId as string
    };

    this.submitting.set(true);
    this.errorMessage.set(null);

    this.loanService.submit(request).subscribe({
      next: (response: LoanResponse) => {
        if (response.status === 'error') {
          const msg = response.message ?? 'An unknown error occurred.';
          this.errorMessage.set(msg);
          this.snackBar.open(msg, 'Dismiss', { duration: 5000 });
        } else {
          this.result.set(response);
        }
        this.submitting.set(false);
        this.cdr.detectChanges();
      },
      error: (err: HttpErrorResponse) => {
        const msg =
          err?.error?.message ??
          err?.message ??
          `Request failed (${err?.status ?? 'unknown'})`;
        this.errorMessage.set(msg);
        this.snackBar.open(msg, 'Dismiss', { duration: 5000 });
        this.submitting.set(false);
        this.cdr.detectChanges();
      }
    });
  }

  reset(): void {
    this.form.reset({ applicantName: '', requestedAmount: null, taxId: '' });
    this.form.markAsPristine();
    this.form.markAsUntouched();
    this.result.set(null);
    this.errorMessage.set(null);
    this.cdr.detectChanges();
  }

  decisionClass(decision: LoanDecision | undefined): string {
    switch (decision) {
      case 'Approved':
        return 'decision-approved';
      case 'Rejected':
        return 'decision-rejected';
      case 'Manual Review':
        return 'decision-review';
      case 'Pending':
        return 'decision-pending';
      default:
        return '';
    }
  }
}

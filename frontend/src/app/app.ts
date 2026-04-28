import { Component } from '@angular/core';

import { LoanFormComponent } from './components/loan-form/loan-form.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [LoanFormComponent],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {}

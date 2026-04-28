import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { environment } from '../../environments/environment';
import { LoanRequest } from '../models/loan-request';
import { LoanResponse } from '../models/loan-response';

@Injectable({ providedIn: 'root' })
export class LoanService {
  private readonly http = inject(HttpClient);

  private readonly httpOptions = {
    headers: new HttpHeaders({ 'Content-Type': 'application/json' }),
    withCredentials: false
  };

  submit(request: LoanRequest): Observable<LoanResponse> {
    return this.http.post<LoanResponse>(
      `${environment.apiUrl}/loan/apply`,
      request,
      this.httpOptions
    );
  }
}

import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { environment } from '../../environments/environment';

export const apiInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);

  // Add base URL if the request URL doesn't start with http
  let apiReq = req;
  if (!req.url.startsWith('http')) {
    apiReq = req.clone({
      url: `${environment.apiUrl}${req.url}`
    });
  }

  // Attach JWT token to all requests except auth endpoints
  const token = localStorage.getItem('token');
  if (token && !apiReq.url.includes('/auth/')) {
    apiReq = apiReq.clone({
      setHeaders: { Authorization: `Bearer ${token}` }
    });
  }

  // Log requests in development
  if (!environment.production) {
    console.log(`[API] ${apiReq.method} ${apiReq.url}`);
  }

  return next(apiReq).pipe(
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'An error occurred';

      if (error.error instanceof ErrorEvent) {
        // Client-side error
        errorMessage = error.error.message;
      } else {
        // Server-side error
        switch (error.status) {
          case 400:
            errorMessage = error.error?.message || 'Bad request';
            break;
          case 401:
            errorMessage = 'Unauthorized. Please login again.';
            // Only clear session and redirect if this is not an auth endpoint
            if (!apiReq.url.includes('/auth/')) {
              localStorage.removeItem('token');
              localStorage.removeItem('refreshToken');
              localStorage.removeItem('user');
              router.navigate(['/login']);
            }
            break;
          case 403:
            errorMessage = 'Forbidden. You do not have permission.';
            break;
          case 404:
            errorMessage = error.error?.message || 'Resource not found';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage = error.error?.message || `Error: ${error.status}`;
        }
      }

      if (!environment.production) {
        console.error(`[API Error] ${error.status}: ${errorMessage}`, error);
      }

      return throwError(() => new Error(errorMessage));
    })
  );
};

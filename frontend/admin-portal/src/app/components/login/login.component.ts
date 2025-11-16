import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  template: `
    <div class="login-container">
      <div class="login-card">
        <h1>Kado24 Admin</h1>
        <p>Platform Management Portal</p>
        
        <form [formGroup]="loginForm" (ngSubmit)="onSubmit()">
          <mat-form-field appearance="outline">
            <mat-label>Email</mat-label>
            <input matInput formControlName="identifier" type="email">
            <mat-error *ngIf="loginForm.get('identifier')?.hasError('required')">
              Email is required
            </mat-error>
          </mat-form-field>
          
          <mat-form-field appearance="outline">
            <mat-label>Password</mat-label>
            <input matInput formControlName="password" type="password">
            <mat-error *ngIf="loginForm.get('password')?.hasError('required')">
              Password is required
            </mat-error>
          </mat-form-field>
          
          <button mat-raised-button color="primary" type="submit" [disabled]="loginForm.invalid">
            Login
          </button>
        </form>
        
        <div *ngIf="errorMessage" class="error-message">
          {{ errorMessage }}
        </div>
      </div>
    </div>
  `,
  styles: [`
    .login-container {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }
    
    .login-card {
      background: white;
      padding: 40px;
      border-radius: 12px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.1);
      width: 100%;
      max-width: 400px;
    }
    
    h1 {
      text-align: center;
      color: #667eea;
      margin-bottom: 8px;
    }
    
    p {
      text-align: center;
      color: #666;
      margin-bottom: 32px;
    }
    
    form {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }
    
    button {
      height: 48px;
      font-size: 16px;
    }
    
    .error-message {
      margin-top: 16px;
      padding: 12px;
      background: #ffebee;
      color: #c62828;
      border-radius: 4px;
      text-align: center;
    }
  `]
})
export class LoginComponent {
  loginForm: FormGroup;
  errorMessage: string = '';

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private router: Router
  ) {
    this.loginForm = this.fb.group({
      identifier: ['admin@kado24.com', [Validators.required, Validators.email]],
      password: ['', Validators.required]
    });
  }

  onSubmit(): void {
    if (this.loginForm.valid) {
      this.authService.login(this.loginForm.value).subscribe({
        next: (response) => {
          if (response.success) {
            this.router.navigate(['/dashboard']);
          }
        },
        error: (error) => {
          this.errorMessage = 'Login failed. Please check your credentials.';
          console.error('Login error', error);
        }
      });
    }
  }
}




















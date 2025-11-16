import { Component } from '@angular/core';
import { AuthService } from './services/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-root',
  template: `
    <div class="app-container">
      <mat-toolbar color="primary" *ngIf="authService.isLoggedIn()">
        <span>Kado24 Admin Portal</span>
        <span class="spacer"></span>
        <button mat-button routerLink="/dashboard">
          <mat-icon>dashboard</mat-icon>
          Dashboard
        </button>
        <button mat-button routerLink="/merchants/pending">
          <mat-icon>store</mat-icon>
          Merchants
        </button>
        <button mat-button routerLink="/transactions">
          <mat-icon>receipt</mat-icon>
          Transactions
        </button>
        <button mat-button (click)="logout()">
          <mat-icon>logout</mat-icon>
          Logout
        </button>
      </mat-toolbar>
      
      <div class="content">
        <router-outlet></router-outlet>
      </div>
    </div>
  `,
  styles: [`
    .app-container {
      height: 100vh;
      display: flex;
      flex-direction: column;
    }
    
    .spacer {
      flex: 1;
    }
    
    .content {
      flex: 1;
      overflow: auto;
      background: #f5f5f5;
    }
    
    mat-toolbar {
      position: sticky;
      top: 0;
      z-index: 1000;
    }
  `]
})
export class AppComponent {
  constructor(
    public authService: AuthService,
    private router: Router
  ) {}

  logout(): void {
    this.authService.logout();
  }
}


















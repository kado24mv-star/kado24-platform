import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { RouterModule, Routes } from '@angular/router';

// Angular Material
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatSelectModule } from '@angular/material/select';
import { MatMenuModule } from '@angular/material/menu';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatChipsModule } from '@angular/material/chips';
import { MatDialogModule } from '@angular/material/dialog';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatPaginatorModule } from '@angular/material/paginator';

// Components
import { AppComponent } from './app.component';
import { LoginComponent } from './components/login/login.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { MerchantApprovalComponent, ConfirmDialogComponent, RejectDialogComponent, MerchantDetailsDialogComponent } from './components/merchants/merchant-approval/merchant-approval.component';
import { UserVerificationComponent, UserDetailsDialogComponent, ConfirmUserVerificationDialogComponent, RejectUserVerificationDialogComponent } from './components/users/user-verification/user-verification.component';
import { TransactionMonitorComponent } from './components/transactions/transaction-monitor/transaction-monitor.component';

// Services
import { ApiService } from './services/api.service';
import { AuthService } from './services/auth.service';

// Guards
import { AuthGuard } from './guards/auth.guard';

// Interceptors
import { AuthInterceptor } from './interceptors/auth.interceptor';

const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { 
    path: '', 
    canActivate: [AuthGuard],
    children: [
      { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
      { path: 'dashboard', component: DashboardComponent },
      { path: 'merchants/pending', component: MerchantApprovalComponent },
      { path: 'users/pending', component: UserVerificationComponent },
      { path: 'transactions', component: TransactionMonitorComponent },
    ]
  },
  { path: '**', redirectTo: '/login' }
];

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    DashboardComponent,
    MerchantApprovalComponent,
    ConfirmDialogComponent,
    RejectDialogComponent,
    MerchantDetailsDialogComponent,
    UserVerificationComponent,
    UserDetailsDialogComponent,
    ConfirmUserVerificationDialogComponent,
    RejectUserVerificationDialogComponent,
    TransactionMonitorComponent,
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule,
    RouterModule.forRoot(routes),
    
    // Material
    MatToolbarModule,
    MatButtonModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatIconModule,
    MatTableModule,
    MatSelectModule,
    MatMenuModule,
    MatSidenavModule,
    MatListModule,
    MatChipsModule,
    MatDialogModule,
    MatSnackBarModule,
    MatPaginatorModule,
  ],
  providers: [
    ApiService,
    AuthService,
    AuthGuard,
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }






















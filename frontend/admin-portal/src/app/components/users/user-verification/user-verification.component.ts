import { Component, OnInit, Inject } from '@angular/core';
import { MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { ApiService } from '../../../services/api.service';
import { AuthService } from '../../../services/auth.service';
import { environment } from '../../../../environments/environment';

interface PendingUser {
  id: number;
  userId: number;
  userFullName: string;
  userEmail: string;
  phoneNumber: string;
  otpCode: string;
  status: string;
  verificationMethod: string;
  requestedAt: string;
  expiresAt: string;
  isExpired: boolean;
  notes?: string;
}

@Component({
  selector: 'app-user-verification',
  template: `
    <div class="user-verification-container">
      <h1>Pending User Verifications</h1>
      
      <div class="stats-bar">
        <div class="stat">
          <span class="stat-label">Total Pending:</span>
          <span class="stat-value">{{ users.length }}</span>
        </div>
        <button mat-raised-button color="primary" (click)="loadPendingUsers()" style="margin-left: auto;">
          <mat-icon>refresh</mat-icon>
          Refresh
        </button>
      </div>

      <div class="user-list" *ngIf="users.length > 0">
        <mat-card *ngFor="let user of users" class="user-card">
          <mat-card-header>
            <mat-card-title>{{ user.userFullName || 'Unknown User' }}</mat-card-title>
            <mat-card-subtitle>{{ user.phoneNumber }}</mat-card-subtitle>
          </mat-card-header>
          
          <mat-card-content>
            <div class="user-details">
              <p><strong>User ID:</strong> {{ user.userId }}</p>
              <p><strong>Phone:</strong> {{ user.phoneNumber }}</p>
              <p><strong>Email:</strong> {{ user.userEmail || 'N/A' }}</p>
              <p><strong>Verification Method:</strong> {{ user.verificationMethod }}</p>
              <p><strong>OTP Code:</strong> <code>{{ user.otpCode }}</code></p>
              <p><strong>Requested:</strong> {{ formatDate(user.requestedAt) }}</p>
              <p><strong>Expires:</strong> {{ formatDate(user.expiresAt) }}</p>
              <p *ngIf="user.isExpired" class="expired-warning">
                <mat-icon>warning</mat-icon>
                <strong>Expired</strong>
              </p>
            </div>
          </mat-card-content>
          
          <mat-card-actions>
            <button mat-raised-button color="primary" 
                    (click)="verifyUser(user.id, user.userId)"
                    [disabled]="user.isExpired">
              <mat-icon>check</mat-icon>
              Verify
            </button>
            <button mat-raised-button color="warn" 
                    (click)="rejectUser(user.id, user.userId)">
              <mat-icon>close</mat-icon>
              Reject
            </button>
            <button mat-button (click)="viewDetails(user)">
              View Details
            </button>
          </mat-card-actions>
        </mat-card>
      </div>
      
      <div *ngIf="users.length === 0" class="empty-state">
        <mat-icon style="font-size: 64px; width: 64px; height: 64px; color: #ccc;">person</mat-icon>
        <h2>No Pending Verifications</h2>
        <p>There are currently no pending user verification requests.</p>
        <button mat-raised-button color="primary" (click)="loadPendingUsers()">
          <mat-icon>refresh</mat-icon>
          Refresh
        </button>
      </div>
    </div>
  `,
  styles: [`
    .user-verification-container {
      padding: 24px;
    }
    
    h1 {
      margin-bottom: 24px;
    }
    
    .stats-bar {
      background: #f5f5f5;
      padding: 16px;
      border-radius: 8px;
      margin-bottom: 24px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    
    .stat {
      display: flex;
      gap: 12px;
      align-items: center;
    }
    
    .stat-label {
      font-size: 14px;
      color: #666;
    }
    
    .stat-value {
      font-size: 24px;
      font-weight: bold;
      color: #333;
    }
    
    .user-list {
      display: grid;
      gap: 16px;
    }
    
    .empty-state {
      text-align: center;
      padding: 60px 20px;
      color: #666;
    }
    
    .empty-state h2 {
      margin: 16px 0 8px 0;
      color: #333;
    }
    
    .empty-state p {
      margin-bottom: 24px;
      color: #999;
    }
    
    .user-card {
      margin-bottom: 16px;
    }
    
    .user-card ::ng-deep mat-card-actions {
      display: flex;
      gap: 16px;
      padding: 16px;
      margin: 0;
      flex-wrap: wrap;
    }
    
    .user-card ::ng-deep mat-card-actions button {
      margin: 0 8px 0 0;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }
    
    .user-card ::ng-deep mat-card-actions button:last-child {
      margin-right: 0;
    }
    
    .user-card ::ng-deep mat-card-actions mat-icon {
      font-size: 18px;
      width: 18px;
      height: 18px;
    }
    
    .user-details p {
      margin: 8px 0;
      font-size: 14px;
    }
    
    .user-details code {
      background: #f5f5f5;
      padding: 2px 8px;
      border-radius: 4px;
      font-family: monospace;
      font-size: 14px;
      color: #d32f2f;
      font-weight: bold;
    }
    
    .expired-warning {
      color: #f44336;
      display: flex;
      align-items: center;
      gap: 8px;
      margin-top: 12px;
      padding: 8px;
      background: #ffebee;
      border-radius: 4px;
    }
    
    .expired-warning mat-icon {
      color: #f44336;
    }
  `]
})
export class UserVerificationComponent implements OnInit {
  users: PendingUser[] = [];

  constructor(
    private api: ApiService,
    private authService: AuthService,
    private router: Router,
    private dialog: MatDialog,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit(): void {
    if (!this.authService.isLoggedIn()) {
      this.snackBar.open('Please login to access this page', 'Close', {
        duration: 3000,
        panelClass: ['error-snackbar']
      });
      this.router.navigate(['/login']);
      return;
    }
    this.loadPendingUsers();
  }

  loadPendingUsers(): void {
    console.log('Loading pending users from:', environment.api.admin.usersPending);
    this.api.get<any>(environment.api.admin.usersPending).subscribe({
      next: (response) => {
        console.log('Pending users response:', response);
        if (response && response.success !== false) {
          // Handle paginated response
          if (response.data && response.data.content) {
            this.users = response.data.content;
          } else if (response.data && Array.isArray(response.data)) {
            this.users = response.data;
          } else if (Array.isArray(response)) {
            this.users = response;
          } else if (response.content) {
            this.users = response.content;
          } else {
            this.users = [];
          }
          console.log(`Loaded ${this.users.length} pending users`);
        } else {
          console.warn('Response success is false or missing data:', response);
          this.users = [];
        }
      },
      error: (error) => {
        console.error('Failed to load pending users', error);
        console.error('Error details:', {
          status: error.status,
          statusText: error.statusText,
          message: error.message,
          error: error.error
        });
        
        let errorMessage = 'Failed to load pending users';
        if (error.status === 401 || error.status === 403) {
          errorMessage = 'Authentication required or insufficient permissions. Please login as admin.';
          // Redirect to login after a delay
          setTimeout(() => {
            this.authService.logout();
            this.router.navigate(['/login']);
          }, 2000);
        } else if (error.status === 404) {
          errorMessage = 'Endpoint not found. Please check API configuration.';
        } else if (error.status === 0) {
          errorMessage = 'Cannot connect to server. Please check if auth-service is running.';
        } else if (error.status === 500) {
          // Check if it's an access denied error
          if (error.error && (error.error.message?.includes('Access Denied') || error.error.message?.includes('access'))) {
            errorMessage = 'Access denied. Admin role required. Please login as admin.';
            setTimeout(() => {
              this.authService.logout();
              this.router.navigate(['/login']);
            }, 2000);
          } else {
            errorMessage = 'Server error. Please try again later.';
          }
        } else if (error.error && error.error.message) {
          errorMessage = error.error.message;
        }
        
        this.snackBar.open(errorMessage, 'Close', {
          duration: 5000,
          panelClass: ['error-snackbar']
        });
        this.users = [];
      }
    });
  }

  verifyUser(verificationId: number, userId: number): void {
    const user = this.users.find(u => u.id === verificationId);
    const dialogRef = this.dialog.open(ConfirmUserVerificationDialogComponent, {
      width: '450px',
      data: {
        title: 'Verify User Account',
        message: `Are you sure you want to verify "${user?.userFullName || user?.phoneNumber}"? This will activate their account and allow them to use the platform.`,
        confirmText: 'Yes, Verify',
        rejectText: 'No',
        cancelText: 'Cancel'
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        const verifyEndpoint = environment.api.admin.userVerify.replace('{id}', verificationId.toString());
        this.api.post<any>(verifyEndpoint, { notes: 'Verified by admin' })
          .subscribe({
            next: (response) => {
              if (response.success) {
                this.snackBar.open('User verified successfully!', 'Close', {
                  duration: 3000,
                  panelClass: ['success-snackbar']
                });
                this.loadPendingUsers();
              }
            },
            error: (error) => {
              this.snackBar.open('Failed to verify user', 'Close', {
                duration: 3000,
                panelClass: ['error-snackbar']
              });
              console.error(error);
            }
          });
      }
    });
  }

  rejectUser(verificationId: number, userId: number): void {
    const user = this.users.find(u => u.id === verificationId);
    const dialogRef = this.dialog.open(RejectUserVerificationDialogComponent, {
      width: '450px',
      data: {
        userName: user?.userFullName || user?.phoneNumber
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        const rejectEndpoint = environment.api.admin.userReject.replace('{id}', verificationId.toString());
        this.api.post<any>(rejectEndpoint, { notes: result })
          .subscribe({
            next: (response) => {
              if (response.success) {
                this.snackBar.open('User verification rejected', 'Close', {
                  duration: 3000,
                  panelClass: ['success-snackbar']
                });
                this.loadPendingUsers();
              }
            },
            error: (error) => {
              this.snackBar.open('Failed to reject verification', 'Close', {
                duration: 3000,
                panelClass: ['error-snackbar']
              });
              console.error(error);
            }
          });
      }
    });
  }

  viewDetails(user: PendingUser): void {
    const dialogRef = this.dialog.open(UserDetailsDialogComponent, {
      width: '600px',
      maxWidth: '90vw',
      data: user
    });
  }

  formatDate(dateStr: string): string {
    try {
      const date = new Date(dateStr);
      return new Intl.DateTimeFormat('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      }).format(date);
    } catch {
      return dateStr;
    }
  }
}

// Confirmation Dialog Component for User Verification
@Component({
  selector: 'app-confirm-dialog-user-verification',
  template: `
    <div class="dialog-container">
      <h2 class="dialog-title">{{ data.title }}</h2>
      <div class="dialog-content">
        <p>{{ data.message }}</p>
      </div>
      <div class="dialog-actions">
        <button mat-raised-button class="btn-yes" (click)="onConfirm()">
          {{ data.confirmText || 'Yes' }}
        </button>
        <button mat-raised-button class="btn-no" (click)="onCancel()">
          {{ data.rejectText || 'No' }}
        </button>
        <button mat-raised-button class="btn-cancel" (click)="onCancel()">
          {{ data.cancelText || 'Cancel' }}
        </button>
      </div>
    </div>
  `,
  styles: [`
    .dialog-container {
      padding: 24px;
      min-width: 400px;
    }
    
    .dialog-title {
      margin: 0 0 16px 0;
      font-size: 20px;
      font-weight: 500;
      color: #333;
    }
    
    .dialog-content {
      margin-bottom: 24px;
    }
    
    .dialog-content p {
      margin: 0;
      line-height: 1.6;
      color: #666;
      font-size: 14px;
    }
    
    .dialog-actions {
      display: flex;
      justify-content: flex-end;
      gap: 12px;
      padding-top: 16px;
      border-top: 1px solid #e0e0e0;
    }
    
    .btn-yes {
      background-color: #4caf50 !important;
      color: white !important;
    }
    
    .btn-yes:hover {
      background-color: #45a049 !important;
    }
    
    .btn-no {
      background-color: #f44336 !important;
      color: white !important;
    }
    
    .btn-no:hover {
      background-color: #da190b !important;
    }
    
    .btn-cancel {
      background-color: #9e9e9e !important;
      color: white !important;
    }
    
    .btn-cancel:hover {
      background-color: #757575 !important;
    }
  `]
})
export class ConfirmUserVerificationDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<ConfirmUserVerificationDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any
  ) {}

  onConfirm(): void {
    this.dialogRef.close(true);
  }

  onCancel(): void {
    this.dialogRef.close(false);
  }
}

// Rejection Dialog Component for User Verification
@Component({
  selector: 'app-reject-dialog-user-verification',
  template: `
    <div class="dialog-container">
      <h2 class="dialog-title">Reject User Verification</h2>
      <div class="dialog-content">
        <p>You are about to reject the verification request for <strong>{{ data.userName }}</strong>.</p>
        <p class="dialog-description">Please provide a reason for rejection. This reason will be communicated to the user.</p>
        <mat-form-field appearance="outline" class="full-width">
          <mat-label>Reason for Rejection</mat-label>
          <textarea matInput 
                    [(ngModel)]="reason" 
                    placeholder="Please provide a detailed reason for the rejection..."
                    rows="4"
                    required></textarea>
          <mat-hint>This reason will be communicated to the user.</mat-hint>
        </mat-form-field>
      </div>
      <div class="dialog-actions">
        <button mat-raised-button class="btn-yes" (click)="onReject()" [disabled]="!reason || reason.trim().length === 0">
          Yes, Reject
        </button>
        <button mat-raised-button class="btn-no" (click)="onCancel()">
          No
        </button>
        <button mat-raised-button class="btn-cancel" (click)="onCancel()">
          Cancel
        </button>
      </div>
    </div>
  `,
  styles: [`
    .dialog-container {
      padding: 24px;
      min-width: 450px;
    }
    
    .dialog-title {
      margin: 0 0 16px 0;
      font-size: 20px;
      font-weight: 500;
      color: #333;
    }
    
    .dialog-content {
      margin-bottom: 24px;
    }
    
    .dialog-content p {
      margin: 0 0 12px 0;
      line-height: 1.6;
      color: #666;
      font-size: 14px;
    }
    
    .dialog-content p:last-of-type {
      margin-bottom: 16px;
    }
    
    .dialog-description {
      color: #666;
      font-style: italic;
    }
    
    .full-width {
      width: 100%;
      margin-top: 8px;
    }
    
    .dialog-actions {
      display: flex;
      justify-content: flex-end;
      gap: 12px;
      padding-top: 16px;
      border-top: 1px solid #e0e0e0;
    }
    
    .btn-yes {
      background-color: #4caf50 !important;
      color: white !important;
    }
    
    .btn-yes:hover:not(:disabled) {
      background-color: #45a049 !important;
    }
    
    .btn-yes:disabled {
      background-color: #cccccc !important;
      color: #999999 !important;
      cursor: not-allowed;
    }
    
    .btn-no {
      background-color: #f44336 !important;
      color: white !important;
    }
    
    .btn-no:hover {
      background-color: #da190b !important;
    }
    
    .btn-cancel {
      background-color: #9e9e9e !important;
      color: white !important;
    }
    
    .btn-cancel:hover {
      background-color: #757575 !important;
    }
  `]
})
export class RejectUserVerificationDialogComponent {
  reason: string = '';

  constructor(
    public dialogRef: MatDialogRef<RejectUserVerificationDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any
  ) {}

  onReject(): void {
    if (this.reason && this.reason.trim().length > 0) {
      this.dialogRef.close(this.reason.trim());
    }
  }

  onCancel(): void {
    this.dialogRef.close(null);
  }
}

// User Details Dialog Component
@Component({
  selector: 'app-user-details-dialog',
  template: `
    <div class="details-dialog">
      <h2 mat-dialog-title>Verification Request Details</h2>
      <mat-dialog-content>
        <div class="details-section">
          <h3>User Information</h3>
          <div class="detail-row">
            <span class="label">User ID:</span>
            <span class="value">{{ data.userId }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Full Name:</span>
            <span class="value">{{ data.userFullName || 'N/A' }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Phone Number:</span>
            <span class="value">{{ data.phoneNumber }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Email:</span>
            <span class="value">{{ data.userEmail || 'N/A' }}</span>
          </div>
        </div>

        <div class="details-section">
          <h3>Verification Details</h3>
          <div class="detail-row">
            <span class="label">Verification ID:</span>
            <span class="value">{{ data.id }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Status:</span>
            <span class="value status-badge" [ngClass]="'status-' + data.status?.toLowerCase()">
              {{ data.status }}
            </span>
          </div>
          <div class="detail-row">
            <span class="label">Verification Method:</span>
            <span class="value">{{ data.verificationMethod }}</span>
          </div>
          <div class="detail-row">
            <span class="label">OTP Code:</span>
            <span class="value"><code>{{ data.otpCode }}</code></span>
          </div>
          <div class="detail-row">
            <span class="label">Requested At:</span>
            <span class="value">{{ formatDate(data.requestedAt) }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Expires At:</span>
            <span class="value">{{ formatDate(data.expiresAt) }}</span>
          </div>
          <div class="detail-row" *ngIf="data.isExpired">
            <span class="label">Status:</span>
            <span class="value expired-badge">EXPIRED</span>
          </div>
        </div>

        <div class="details-section" *ngIf="data.notes">
          <h3>Notes</h3>
          <div class="detail-row">
            <span class="value">{{ data.notes }}</span>
          </div>
        </div>
      </mat-dialog-content>
      <mat-dialog-actions align="end">
        <button mat-button (click)="onClose()">Close</button>
      </mat-dialog-actions>
    </div>
  `,
  styles: [`
    .details-dialog {
      padding: 0;
    }
    
    h2[mat-dialog-title] {
      margin: 0 0 20px 0;
      padding-bottom: 16px;
      border-bottom: 1px solid #e0e0e0;
    }
    
    mat-dialog-content {
      padding: 20px 0;
      max-height: 70vh;
      overflow-y: auto;
    }
    
    .details-section {
      margin-bottom: 24px;
    }
    
    .details-section:last-child {
      margin-bottom: 0;
    }
    
    .details-section h3 {
      margin: 0 0 12px 0;
      font-size: 16px;
      font-weight: 600;
      color: #333;
      padding-bottom: 8px;
      border-bottom: 2px solid #f0f0f0;
    }
    
    .detail-row {
      display: flex;
      padding: 8px 0;
      border-bottom: 1px solid #f5f5f5;
    }
    
    .detail-row:last-child {
      border-bottom: none;
    }
    
    .label {
      font-weight: 500;
      color: #666;
      min-width: 140px;
      flex-shrink: 0;
    }
    
    .value {
      color: #333;
      flex: 1;
    }
    
    .value code {
      background: #f5f5f5;
      padding: 2px 8px;
      border-radius: 4px;
      font-family: monospace;
      font-size: 14px;
      color: #d32f2f;
      font-weight: bold;
    }
    
    .status-badge {
      display: inline-block;
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 600;
      text-transform: uppercase;
    }
    
    .status-pending {
      background-color: #fff3cd;
      color: #856404;
    }
    
    .status-verified {
      background-color: #d4edda;
      color: #155724;
    }
    
    .status-rejected {
      background-color: #f8d7da;
      color: #721c24;
    }
    
    .expired-badge {
      color: #f44336;
      font-weight: bold;
    }
    
    mat-dialog-actions {
      padding: 16px 0 0 0;
      margin: 0;
      border-top: 1px solid #e0e0e0;
    }
  `]
})
export class UserDetailsDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<UserDetailsDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any
  ) {}

  formatDate(dateStr: string): string {
    try {
      const date = new Date(dateStr);
      return new Intl.DateTimeFormat('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      }).format(date);
    } catch {
      return dateStr;
    }
  }

  onClose(): void {
    this.dialogRef.close();
  }
}


import { Component, OnInit, Inject } from '@angular/core';
import { MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { ApiService } from '../../../services/api.service';
import { environment } from '../../../../environments/environment';

interface PendingMerchant {
  id: number;
  businessName: string;
  businessType: string;
  phoneNumber: string;
  email: string;
  city: string;
  verificationStatus: string;
  createdAt: string;
}

@Component({
  selector: 'app-merchant-approval',
  template: `
    <div class="merchant-approval-container">
      <h1>Pending Merchant Applications</h1>
      
      <div class="stats-bar">
        <div class="stat">
          <span class="stat-label">Total Pending:</span>
          <span class="stat-value">{{ merchants.length }}</span>
        </div>
        <button mat-raised-button color="primary" (click)="loadPendingMerchants()" style="margin-left: auto;">
          <mat-icon>refresh</mat-icon>
          Refresh
        </button>
      </div>

      <div class="merchant-list" *ngIf="merchants.length > 0">
        <mat-card *ngFor="let merchant of merchants" class="merchant-card">
          <mat-card-header>
            <mat-card-title>{{ merchant.businessName }}</mat-card-title>
            <mat-card-subtitle>{{ merchant.businessType }}</mat-card-subtitle>
          </mat-card-header>
          
          <mat-card-content>
            <div class="merchant-details">
              <p><strong>Phone:</strong> {{ merchant.phoneNumber }}</p>
              <p><strong>Email:</strong> {{ merchant.email }}</p>
              <p><strong>City:</strong> {{ merchant.city }}</p>
              <p><strong>Applied:</strong> {{ formatDate(merchant.createdAt) }}</p>
            </div>
          </mat-card-content>
          
          <mat-card-actions>
            <button mat-raised-button color="primary" 
                    (click)="approveMerchant(merchant.id)">
              <mat-icon>check</mat-icon>
              Approve
            </button>
            <button mat-raised-button color="warn" 
                    (click)="rejectMerchant(merchant.id)">
              <mat-icon>close</mat-icon>
              Reject
            </button>
            <button mat-button (click)="viewDetails(merchant.id)">
              View Details
            </button>
          </mat-card-actions>
        </mat-card>
      </div>
      
      <div *ngIf="merchants.length === 0" class="empty-state">
        <mat-icon style="font-size: 64px; width: 64px; height: 64px; color: #ccc;">business</mat-icon>
        <h2>No Pending Applications</h2>
        <p>There are currently no pending merchant applications.</p>
        <button mat-raised-button color="primary" (click)="loadPendingMerchants()">
          <mat-icon>refresh</mat-icon>
          Refresh
        </button>
      </div>
    </div>
  `,
  styles: [`
    .merchant-approval-container {
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
    
    .merchant-list {
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
    
    .merchant-card {
      margin-bottom: 16px;
    }
    
    .merchant-card ::ng-deep mat-card-actions {
      display: flex;
      gap: 16px;
      padding: 16px;
      margin: 0;
      flex-wrap: wrap;
    }
    
    .merchant-card ::ng-deep mat-card-actions button {
      margin: 0 8px 0 0;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }
    
    .merchant-card ::ng-deep mat-card-actions button:last-child {
      margin-right: 0;
    }
    
    .merchant-card ::ng-deep mat-card-actions mat-icon {
      font-size: 18px;
      width: 18px;
      height: 18px;
    }
    
    .merchant-details p {
      margin: 8px 0;
      font-size: 14px;
    }
  `]
})
export class MerchantApprovalComponent implements OnInit {
  merchants: PendingMerchant[] = [];

  constructor(
    private api: ApiService,
    private dialog: MatDialog,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit(): void {
    this.loadPendingMerchants();
  }

  loadPendingMerchants(): void {
    console.log('Loading pending merchants from:', environment.api.admin.merchantsPending);
    this.api.get<any>(environment.api.admin.merchantsPending).subscribe({
      next: (response) => {
        console.log('Pending merchants response:', response);
        if (response.success && response.data) {
          this.merchants = response.data.content || [];
          console.log(`Loaded ${this.merchants.length} pending merchants`);
        } else {
          console.warn('Response success is false or missing data:', response);
          this.merchants = [];
        }
      },
      error: (error) => {
        console.error('Failed to load merchants', error);
        this.merchants = [];
      }
    });
  }

  approveMerchant(merchantId: number): void {
    const merchant = this.merchants.find(m => m.id === merchantId);
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      width: '450px',
      data: {
        title: 'Approve Merchant Application',
        message: `Are you sure you want to approve "${merchant?.businessName}"? This action will grant them access to create and sell vouchers on the platform.`,
        confirmText: 'Yes',
        rejectText: 'No',
        cancelText: 'Cancel'
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        const approveEndpoint = environment.api.admin.merchantApprove.replace('{id}', merchantId.toString());
        this.api.post<any>(approveEndpoint, {})
          .subscribe({
            next: (response) => {
              if (response.success) {
                this.snackBar.open('Merchant approved successfully!', 'Close', {
                  duration: 3000,
                  panelClass: ['success-snackbar']
                });
                this.loadPendingMerchants();
              }
            },
            error: (error) => {
              this.snackBar.open('Failed to approve merchant', 'Close', {
                duration: 3000,
                panelClass: ['error-snackbar']
              });
              console.error(error);
            }
          });
      }
    });
  }

  rejectMerchant(merchantId: number): void {
    const merchant = this.merchants.find(m => m.id === merchantId);
    const dialogRef = this.dialog.open(RejectDialogComponent, {
      width: '450px',
      data: {
        merchantName: merchant?.businessName
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        const rejectEndpoint = environment.api.admin.merchantReject.replace('{id}', merchantId.toString());
        this.api.post<any>(`${rejectEndpoint}?reason=${encodeURIComponent(result)}`, {})
          .subscribe({
            next: (response) => {
              if (response.success) {
                this.snackBar.open('Merchant application rejected', 'Close', {
                  duration: 3000,
                  panelClass: ['success-snackbar']
                });
                this.loadPendingMerchants();
              }
            },
            error: (error) => {
              this.snackBar.open('Failed to reject merchant', 'Close', {
                duration: 3000,
                panelClass: ['error-snackbar']
              });
              console.error(error);
            }
          });
      }
    });
  }

  viewDetails(merchantId: number): void {
    this.api.get<any>(`/api/admin/merchants/${merchantId}`).subscribe({
      next: (response) => {
        if (response.success && response.data) {
          const dialogRef = this.dialog.open(MerchantDetailsDialogComponent, {
            width: '600px',
            maxWidth: '90vw',
            data: response.data
          });
        } else {
          this.snackBar.open('Failed to load merchant details', 'Close', {
            duration: 3000,
            panelClass: ['error-snackbar']
          });
        }
      },
      error: (error) => {
        console.error('Error loading merchant details:', error);
        this.snackBar.open('Error loading merchant details', 'Close', {
          duration: 3000,
          panelClass: ['error-snackbar']
        });
      }
    });
  }

  formatDate(dateStr: string): string {
    try {
      const date = new Date(dateStr);
      return new Intl.DateTimeFormat('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric' 
      }).format(date);
    } catch {
      return dateStr;
    }
  }
}

// Confirmation Dialog Component
@Component({
  selector: 'app-confirm-dialog',
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
export class ConfirmDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<ConfirmDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any
  ) {}

  onConfirm(): void {
    this.dialogRef.close(true);
  }

  onCancel(): void {
    this.dialogRef.close(false);
  }
}

// Rejection Dialog Component
@Component({
  selector: 'app-reject-dialog',
  template: `
    <div class="dialog-container">
      <h2 class="dialog-title">Reject Merchant Application</h2>
      <div class="dialog-content">
        <p>You are about to reject the application for <strong>{{ data.merchantName }}</strong>.</p>
        <p class="dialog-description">This one has another option, the cancel option for when you dont want to do anything</p>
        <mat-form-field appearance="outline" class="full-width">
          <mat-label>Reason for Rejection</mat-label>
          <textarea matInput 
                    [(ngModel)]="reason" 
                    placeholder="Please provide a detailed reason for the rejection..."
                    rows="4"
                    required></textarea>
          <mat-hint>This reason will be communicated to the merchant.</mat-hint>
        </mat-form-field>
      </div>
      <div class="dialog-actions">
        <button mat-raised-button class="btn-yes" (click)="onReject()" [disabled]="!reason || reason.trim().length === 0">
          Yes
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
export class RejectDialogComponent {
  reason: string = '';

  constructor(
    public dialogRef: MatDialogRef<RejectDialogComponent>,
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

// Merchant Details Dialog Component
@Component({
  selector: 'app-merchant-details-dialog',
  template: `
    <div class="details-dialog">
      <h2 mat-dialog-title>Merchant Details</h2>
      <mat-dialog-content>
        <div class="details-section">
          <h3>Business Information</h3>
          <div class="detail-row">
            <span class="label">Business Name:</span>
            <span class="value">{{ data.businessName }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Business Type:</span>
            <span class="value">{{ data.businessType }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Business License:</span>
            <span class="value">{{ data.businessLicense || 'N/A' }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Tax ID:</span>
            <span class="value">{{ data.taxId || 'N/A' }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Description:</span>
            <span class="value">{{ data.description || 'N/A' }}</span>
          </div>
        </div>

        <div class="details-section">
          <h3>Contact Information</h3>
          <div class="detail-row">
            <span class="label">Phone:</span>
            <span class="value">{{ data.phoneNumber }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Email:</span>
            <span class="value">{{ data.email || 'N/A' }}</span>
          </div>
        </div>

        <div class="details-section">
          <h3>Address</h3>
          <div class="detail-row">
            <span class="label">Address:</span>
            <span class="value">{{ data.address || 'N/A' }}</span>
          </div>
          <div class="detail-row">
            <span class="label">City:</span>
            <span class="value">{{ data.city || 'N/A' }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Province:</span>
            <span class="value">{{ data.province || 'N/A' }}</span>
          </div>
        </div>

        <div class="details-section">
          <h3>Bank Details</h3>
          <div class="detail-row">
            <span class="label">Bank Name:</span>
            <span class="value">{{ data.bankName || 'N/A' }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Account Number:</span>
            <span class="value">{{ data.bankAccountNumber || 'N/A' }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Account Name:</span>
            <span class="value">{{ data.bankAccountName || 'N/A' }}</span>
          </div>
        </div>

        <div class="details-section">
          <h3>Status & Statistics</h3>
          <div class="detail-row">
            <span class="label">Verification Status:</span>
            <span class="value status-badge" [ngClass]="'status-' + data.verificationStatus?.toLowerCase()">
              {{ data.verificationStatus }}
            </span>
          </div>
          <div class="detail-row">
            <span class="label">Rating:</span>
            <span class="value">{{ data.rating || 0 }} ⭐</span>
          </div>
          <div class="detail-row">
            <span class="label">Total Reviews:</span>
            <span class="value">{{ data.totalReviews || 0 }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Applied Date:</span>
            <span class="value">{{ formatDate(data.createdAt) }}</span>
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
    
    .status-approved {
      background-color: #d4edda;
      color: #155724;
    }
    
    .status-rejected {
      background-color: #f8d7da;
      color: #721c24;
    }
    
    mat-dialog-actions {
      padding: 16px 0 0 0;
      margin: 0;
      border-top: 1px solid #e0e0e0;
    }
  `]
})
export class MerchantDetailsDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<MerchantDetailsDialogComponent>,
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















import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-merchant-detail',
  template: `
    <div class="merchant-detail">
      <div class="header">
        <h1>{{merchant.businessName}}</h1>
        <span class="status-badge" [class]="merchant.status.toLowerCase()">
          {{merchant.status}}
        </span>
      </div>

      <div class="content-grid">
        <mat-card class="info-section">
          <mat-card-header>
            <mat-card-title>Business Information</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="info-row">
              <span class="label">Business Name:</span>
              <span class="value">{{merchant.businessName}}</span>
            </div>
            <div class="info-row">
              <span class="label">Category:</span>
              <span class="value">{{merchant.businessType}}</span>
            </div>
            <div class="info-row">
              <span class="label">Phone:</span>
              <span class="value">{{merchant.phoneNumber}}</span>
            </div>
            <div class="info-row">
              <span class="label">Email:</span>
              <span class="value">{{merchant.email}}</span>
            </div>
            <div class="info-row">
              <span class="label">Location:</span>
              <span class="value">{{merchant.city}}</span>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="info-section">
          <mat-card-header>
            <mat-card-title>Documents</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="document-item">
              <mat-icon color="primary">check_circle</mat-icon>
              <span>Business Registration</span>
              <button mat-icon-button>
                <mat-icon>visibility</mat-icon>
              </button>
            </div>
            <div class="document-item">
              <mat-icon color="primary">check_circle</mat-icon>
              <span>Tax ID Certificate</span>
              <button mat-icon-button>
                <mat-icon>visibility</mat-icon>
              </button>
            </div>
            <div class="document-item">
              <mat-icon color="primary">check_circle</mat-icon>
              <span>Owner ID Card</span>
              <button mat-icon-button>
                <mat-icon>visibility</mat-icon>
              </button>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="info-section">
          <mat-card-header>
            <mat-card-title>Bank Details</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="info-row">
              <span class="label">Bank:</span>
              <span class="value">{{merchant.bankName}}</span>
            </div>
            <div class="info-row">
              <span class="label">Account:</span>
              <span class="value">**** **** {{merchant.accountLast4}}</span>
            </div>
            <div class="info-row">
              <span class="label">Account Name:</span>
              <span class="value">{{merchant.accountName}}</span>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="info-section">
          <mat-card-header>
            <mat-card-title>Notes</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <mat-form-field class="full-width">
              <mat-label>Admin Notes</mat-label>
              <textarea matInput rows="4" placeholder="Add notes about this merchant..."></textarea>
            </mat-form-field>
          </mat-card-content>
        </mat-card>
      </div>

      <div class="actions">
        <button mat-raised-button color="primary" (click)="approve()" *ngIf="merchant.status === 'PENDING'">
          ✅ Approve Merchant
        </button>
        <button mat-raised-button color="warn" (click)="reject()" *ngIf="merchant.status === 'PENDING'">
          ❌ Reject Application
        </button>
        <button mat-button routerLink="/merchants/pending">Back to List</button>
      </div>
    </div>
  `,
  styles: [`
    .merchant-detail {
      padding: 24px;
    }
    
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 24px;
    }
    
    .status-badge {
      padding: 8px 16px;
      border-radius: 16px;
      font-weight: bold;
      font-size: 14px;
    }
    
    .status-badge.pending {
      background: #fff3cd;
      color: #856404;
    }
    
    .status-badge.approved {
      background: #d4edda;
      color: #155724;
    }
    
    .content-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 20px;
      margin-bottom: 24px;
    }
    
    .info-section {
      height: fit-content;
    }
    
    .info-row {
      display: flex;
      justify-content: space-between;
      padding: 12px 0;
      border-bottom: 1px solid #eee;
    }
    
    .label {
      color: #666;
    }
    
    .value {
      font-weight: bold;
    }
    
    .document-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px 0;
      border-bottom: 1px solid #eee;
    }
    
    .full-width {
      width: 100%;
    }
    
    .actions {
      display: flex;
      gap: 16px;
      justify-content: center;
    }
  `]
})
export class MerchantDetailComponent implements OnInit {
  merchant = {
    id: 1,
    businessName: 'Amazon Coffee',
    businessType: 'Food & Beverage',
    phoneNumber: '+855 12 345 678',
    email: 'amazon@coffee.com',
    city: 'Phnom Penh',
    status: 'PENDING',
    bankName: 'ABA Bank',
    accountLast4: '5678',
    accountName: 'Amazon Coffee Shop'
  };

  constructor(private route: ActivatedRoute) {}

  ngOnInit() {
    // Load merchant details
  }

  approve() {
    if (confirm('Approve this merchant?')) {
      alert('Merchant approved!');
    }
  }

  reject() {
    const reason = prompt('Reason for rejection:');
    if (reason) {
      alert('Merchant rejected');
    }
  }
}



































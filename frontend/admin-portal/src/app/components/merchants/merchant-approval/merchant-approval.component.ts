import { Component, OnInit } from '@angular/core';
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
      </div>

      <div class="merchant-list">
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
              ✓ Approve
            </button>
            <button mat-raised-button color="warn" 
                    (click)="rejectMerchant(merchant.id)">
              ✗ Reject
            </button>
            <button mat-button (click)="viewDetails(merchant.id)">
              View Details
            </button>
          </mat-card-actions>
        </mat-card>
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
    
    .merchant-card {
      margin-bottom: 16px;
    }
    
    .merchant-details p {
      margin: 8px 0;
      font-size: 14px;
    }
  `]
})
export class MerchantApprovalComponent implements OnInit {
  merchants: PendingMerchant[] = [];

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.loadPendingMerchants();
  }

  loadPendingMerchants(): void {
    this.api.get<any>(environment.api.admin.merchantsPending).subscribe({
      next: (response) => {
        if (response.success) {
          this.merchants = response.data.content;
        }
      },
      error: (error) => {
        console.error('Failed to load merchants', error);
      }
    });
  }

  approveMerchant(merchantId: number): void {
    if (confirm('Are you sure you want to approve this merchant?')) {
      const approveEndpoint = environment.api.admin.merchantApprove.replace('{id}', merchantId.toString());
      this.api.post<any>(approveEndpoint, {})
        .subscribe({
          next: (response) => {
            if (response.success) {
              alert('Merchant approved successfully!');
              this.loadPendingMerchants();
            }
          },
          error: (error) => {
            alert('Failed to approve merchant');
            console.error(error);
          }
        });
    }
  }

  rejectMerchant(merchantId: number): void {
    const reason = prompt('Reason for rejection:');
    if (reason) {
      const rejectEndpoint = environment.api.admin.merchantReject.replace('{id}', merchantId.toString());
      this.api.post<any>(`${rejectEndpoint}?reason=${encodeURIComponent(reason)}`, {})
        .subscribe({
          next: (response) => {
            if (response.success) {
              alert('Merchant rejected');
              this.loadPendingMerchants();
            }
          },
          error: (error) => {
            alert('Failed to reject merchant');
            console.error(error);
          }
        });
    }
  }

  viewDetails(merchantId: number): void {
    // TODO: Navigate to merchant details view
    console.log('View merchant:', merchantId);
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















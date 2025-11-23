import { Component } from '@angular/core';

@Component({
  selector: 'app-voucher-moderation',
  template: `
    <div class="voucher-moderation">
      <h1>Voucher Moderation</h1>
      
      <div class="tabs">
        <button mat-raised-button [color]="tab === 'pending' ? 'primary' : ''" (click)="tab = 'pending'">
          Pending Review ({{pendingCount}})
        </button>
        <button mat-raised-button [color]="tab === 'approved' ? 'primary' : ''" (click)="tab = 'approved'">
          Approved
        </button>
        <button mat-raised-button [color]="tab === 'rejected' ? 'primary' : ''" (click)="tab = 'rejected'">
          Rejected
        </button>
      </div>

      <div class="voucher-list">
        <mat-card *ngFor="let voucher of vouchers" class="voucher-card">
          <div class="voucher-header">
            <div>
              <h3>{{voucher.title}}</h3>
              <p class="merchant">{{voucher.merchantName}}</p>
            </div>
            <span class="status-badge pending">New</span>
          </div>
          
          <div class="voucher-details">
            <div class="detail-item">
              <span class="label">Category:</span>
              <span class="value">{{voucher.category}}</span>
            </div>
            <div class="detail-item">
              <span class="label">Denominations:</span>
              <span class="value">{{voucher.denominations}}</span>
            </div>
            <div class="detail-item">
              <span class="label">Stock:</span>
              <span class="value">{{voucher.stock}}</span>
            </div>
            <div class="detail-item">
              <span class="label">Submitted:</span>
              <span class="value">{{voucher.submittedDate}}</span>
            </div>
          </div>
          
          <mat-card-actions>
            <button mat-raised-button color="primary" (click)="approveVoucher(voucher.id)">
              ✅ Approve
            </button>
            <button mat-raised-button color="warn" (click)="rejectVoucher(voucher.id)">
              ❌ Reject
            </button>
            <button mat-button (click)="viewDetails(voucher.id)">
              View Full Details
            </button>
          </mat-card-actions>
        </mat-card>
      </div>
    </div>
  `,
  styles: [`
    .voucher-moderation {
      padding: 24px;
    }
    
    .tabs {
      display: flex;
      gap: 12px;
      margin: 24px 0;
    }
    
    .voucher-list {
      display: grid;
      gap: 16px;
    }
    
    .voucher-card {
      padding: 20px;
    }
    
    .voucher-header {
      display: flex;
      justify-content: space-between;
      align-items: start;
      margin-bottom: 16px;
    }
    
    .voucher-header h3 {
      margin: 0;
    }
    
    .merchant {
      color: #666;
      font-size: 14px;
      margin-top: 4px;
    }
    
    .status-badge {
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: bold;
    }
    
    .status-badge.pending {
      background: #fff3cd;
      color: #856404;
    }
    
    .voucher-details {
      display: grid;
      gap: 8px;
      margin-bottom: 16px;
    }
    
    .detail-item {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid #eee;
    }
    
    .label {
      color: #666;
    }
    
    .value {
      font-weight: bold;
    }
  `]
})
export class VoucherModerationComponent {
  tab = 'pending';
  pendingCount = 5;
  
  vouchers = [
    {
      id: 1,
      title: 'Coffee Voucher',
      merchantName: 'Amazon Coffee',
      category: 'Food & Beverage',
      denominations: '$5, $10, $15, $25',
      stock: '100 vouchers',
      submittedDate: '2 hours ago'
    },
    {
      id: 2,
      title: 'Spa Treatment',
      merchantName: 'Lotus Spa',
      category: 'Health & Beauty',
      denominations: '$30, $50, $100',
      stock: 'Unlimited',
      submittedDate: 'Yesterday'
    }
  ];

  approveVoucher(id: number) {
    if (confirm('Approve this voucher?')) {
      alert('Voucher approved!');
    }
  }

  rejectVoucher(id: number) {
    const reason = prompt('Reason for rejection:');
    if (reason) {
      alert('Voucher rejected');
    }
  }

  viewDetails(id: number) {
    console.log('View voucher:', id);
  }
}



































import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-revenue-dashboard',
  template: `
    <div class="revenue-dashboard">
      <h1>Financial Overview</h1>
      
      <div class="revenue-card">
        <h2>Platform Revenue (30 days)</h2>
        <div class="big-number">\$22,740</div>
        <div class="growth">▲ 23% vs last period</div>
        <div class="subtitle">8% commission on all transactions</div>
      </div>

      <div class="stats-grid">
        <div class="stat-box">
          <div class="label">Total GMV</div>
          <div class="value">\$284,250</div>
          <div class="detail">Gross Merchandise Value</div>
        </div>
        
        <div class="stat-box">
          <div class="label">Merchant Payouts</div>
          <div class="value">\$261,510</div>
          <div class="detail">92% to merchants</div>
        </div>
        
        <div class="stat-box">
          <div class="label">Platform Commission</div>
          <div class="value">\$22,740</div>
          <div class="detail">8% revenue</div>
        </div>
        
        <div class="stat-box">
          <div class="label">Success Rate</div>
          <div class="value">97.2%</div>
          <div class="detail">Transaction success</div>
        </div>
      </div>

      <h2>Pending Payouts</h2>
      
      <mat-card class="payout-card">
        <mat-card-header>
          <mat-card-title>Weekly Payout #WP245</mat-card-title>
          <mat-card-subtitle>Due: Friday, Nov 15, 2025</mat-card-subtitle>
        </mat-card-header>
        <mat-card-content>
          <div class="payout-details">
            <div class="payout-amount">\$45,234</div>
            <div class="payout-info">158 merchants • 1,234 transactions</div>
          </div>
        </mat-card-content>
        <mat-card-actions>
          <button mat-raised-button color="primary" (click)="processPayout()">
            Process Payout
          </button>
          <button mat-button>View Details</button>
        </mat-card-actions>
      </mat-card>

      <h2>Recent Payouts</h2>
      
      <div class="payout-list">
        <mat-card *ngFor="let payout of recentPayouts" class="payout-item">
          <div class="payout-row">
            <div>
              <div class="payout-period">{{payout.period}}</div>
              <div class="payout-date">Paid: {{payout.paidDate}}</div>
            </div>
            <div class="payout-amount-small">\${{payout.amount.toLocaleString()}}</div>
          </div>
        </mat-card>
      </div>
    </div>
  `,
  styles: [`
    .revenue-dashboard {
      padding: 24px;
    }
    
    .revenue-card {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 32px;
      border-radius: 12px;
      margin: 24px 0;
      text-align: center;
    }
    
    .big-number {
      font-size: 56px;
      font-weight: bold;
      margin: 16px 0;
    }
    
    .growth {
      font-size: 18px;
      margin-bottom: 8px;
    }
    
    .subtitle {
      opacity: 0.9;
    }
    
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 16px;
      margin: 24px 0;
    }
    
    .stat-box {
      background: white;
      padding: 24px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      text-align: center;
    }
    
    .stat-box .label {
      font-size: 14px;
      color: #666;
      margin-bottom: 8px;
    }
    
    .stat-box .value {
      font-size: 32px;
      font-weight: bold;
      color: #333;
    }
    
    .stat-box .detail {
      font-size: 12px;
      color: #999;
      margin-top: 4px;
    }
    
    .payout-card {
      margin: 16px 0;
    }
    
    .payout-details {
      text-align: center;
      padding: 16px;
    }
    
    .payout-amount {
      font-size: 40px;
      font-weight: bold;
      color: #27ae60;
    }
    
    .payout-info {
      color: #666;
      margin-top: 8px;
    }
    
    .payout-list {
      display: grid;
      gap: 12px;
    }
    
    .payout-item {
      padding: 16px;
    }
    
    .payout-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    
    .payout-period {
      font-weight: bold;
    }
    
    .payout-date {
      font-size: 12px;
      color: #666;
    }
    
    .payout-amount-small {
      font-size: 20px;
      font-weight: bold;
      color: #4facfe;
    }
  `]
})
export class UserManagementComponent implements OnInit {
  users: User[] = [];
  filteredUsers: User[] = [];
  searchTerm = '';
  selectedStatus = 'all';
  stats = { total: 0, active: 0, suspended: 0 };
  
  recentPayouts = [
    { period: 'Week of Nov 1-7', paidDate: 'Nov 8, 2025', amount: 42145 },
    { period: 'Week of Oct 25-31', paidDate: 'Nov 1, 2025', amount: 39876 },
    { period: 'Week of Oct 18-24', paidDate: 'Oct 25, 2025', amount: 45234 },
  ];

  ngOnInit() {
    this.loadUsers();
  }

  loadUsers() {
    // Mock data - TODO: Call user-service
    this.users = [];
    this.filteredUsers = [...this.users];
    this.updateStats();
  }

  filterUsers() {
    // Filtering logic
  }

  updateStats() {
    this.stats.total = this.users.length;
    this.stats.active = this.users.filter(u => u.status === 'ACTIVE').length;
    this.stats.suspended = this.users.filter(u => u.status === 'SUSPENDED').length;
  }

  processPayout() {
    if (confirm('Process weekly payout of $45,234 to 158 merchants?')) {
      alert('Payout processing initiated');
    }
  }

  formatDate(dateStr: string): string {
    return new Date(dateStr).toLocaleDateString();
  }
}
















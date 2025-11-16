import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { environment } from '../../../environments/environment';

interface DashboardStats {
  totalUsers: number;
  totalMerchants: number;
  totalVouchers: number;
  totalOrders: number;
  platformRevenue: number;
}

@Component({
  selector: 'app-dashboard',
  template: `
    <div class="dashboard-container">
      <h1>Admin Dashboard</h1>
      
      <div class="stats-grid">
        <div class="stat-card">
          <h3>Total Users</h3>
          <p class="stat-number">{{ stats.totalUsers }}</p>
        </div>
        
        <div class="stat-card">
          <h3>Total Merchants</h3>
          <p class="stat-number">{{ stats.totalMerchants }}</p>
        </div>
        
        <div class="stat-card">
          <h3>Total Vouchers</h3>
          <p class="stat-number">{{ stats.totalVouchers }}</p>
        </div>
        
        <div class="stat-card">
          <h3>Total Orders</h3>
          <p class="stat-number">{{ stats.totalOrders }}</p>
        </div>
        
        <div class="stat-card revenue">
          <h3>Platform Revenue</h3>
          <p class="stat-number">\${{ stats.platformRevenue.toFixed(2) }}</p>
        </div>
      </div>
      
      <div class="actions">
        <button mat-raised-button color="primary" routerLink="/merchants/pending">
          Pending Merchants
        </button>
        <button mat-raised-button color="accent" routerLink="/transactions">
          View Transactions
        </button>
      </div>
    </div>
  `,
  styles: [`
    .dashboard-container {
      padding: 24px;
    }
    
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 20px;
      margin: 24px 0;
    }
    
    .stat-card {
      background: white;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .stat-card h3 {
      margin: 0 0 12px 0;
      color: #666;
      font-size: 14px;
    }
    
    .stat-number {
      font-size: 32px;
      font-weight: bold;
      margin: 0;
      color: #333;
    }
    
    .stat-card.revenue {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }
    
    .stat-card.revenue h3,
    .stat-card.revenue .stat-number {
      color: white;
    }
    
    .actions {
      display: flex;
      gap: 16px;
      margin-top: 24px;
    }
  `]
})
export class DashboardComponent implements OnInit {
  stats: DashboardStats = {
    totalUsers: 0,
    totalMerchants: 0,
    totalVouchers: 0,
    totalOrders: 0,
    platformRevenue: 0
  };

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.loadDashboard();
  }

  loadDashboard(): void {
    this.api.get<any>(environment.api.admin.dashboard).subscribe({
      next: (response) => {
        if (response.success) {
          this.stats = response.data;
        }
      },
      error: (error) => {
        console.error('Failed to load dashboard', error);
      }
    });
  }
}
















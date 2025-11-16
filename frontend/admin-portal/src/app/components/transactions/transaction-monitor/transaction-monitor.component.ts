import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../../services/api.service';

interface Transaction {
  id: number;
  orderNumber: string;
  userName: string;
  merchantName: string;
  amount: number;
  status: string;
  createdAt: string;
}

@Component({
  selector: 'app-transaction-monitor',
  template: `
    <div class="transaction-monitor">
      <h1>Transaction Monitoring</h1>
      
      <div class="filters">
        <mat-form-field>
          <mat-label>Status</mat-label>
          <mat-select [(value)]="selectedStatus" (selectionChange)="filterTransactions()">
            <mat-option value="all">All</mat-option>
            <mat-option value="COMPLETED">Completed</mat-option>
            <mat-option value="PENDING">Pending</mat-option>
            <mat-option value="FAILED">Failed</mat-option>
          </mat-select>
        </mat-form-field>
        
        <mat-form-field>
          <mat-label>Search</mat-label>
          <input matInput [(ngModel)]="searchTerm" (ngModelChange)="filterTransactions()" 
                 placeholder="Order number, merchant...">
        </mat-form-field>
      </div>

      <table mat-table [dataSource]="filteredTransactions" class="transaction-table">
        <ng-container matColumnDef="orderNumber">
          <th mat-header-cell *matHeaderCellDef>Order Number</th>
          <td mat-cell *matCellDef="let txn">{{ txn.orderNumber }}</td>
        </ng-container>

        <ng-container matColumnDef="user">
          <th mat-header-cell *matHeaderCellDef>Customer</th>
          <td mat-cell *matCellDef="let txn">{{ txn.userName }}</td>
        </ng-container>

        <ng-container matColumnDef="merchant">
          <th mat-header-cell *matHeaderCellDef>Merchant</th>
          <td mat-cell *matCellDef="let txn">{{ txn.merchantName }}</td>
        </ng-container>

        <ng-container matColumnDef="amount">
          <th mat-header-cell *matHeaderCellDef>Amount</th>
          <td mat-cell *matCellDef="let txn">\${{ txn.amount.toFixed(2) }}</td>
        </ng-container>

        <ng-container matColumnDef="status">
          <th mat-header-cell *matHeaderCellDef>Status</th>
          <td mat-cell *matCellDef="let txn">
            <span class="status-badge" [class.completed]="txn.status === 'COMPLETED'"
                  [class.pending]="txn.status === 'PENDING'"
                  [class.failed]="txn.status === 'FAILED'">
              {{ txn.status }}
            </span>
          </td>
        </ng-container>

        <ng-container matColumnDef="date">
          <th mat-header-cell *matHeaderCellDef>Date</th>
          <td mat-cell *matCellDef="let txn">{{ formatDate(txn.createdAt) }}</td>
        </ng-container>

        <ng-container matColumnDef="actions">
          <th mat-header-cell *matHeaderCellDef>Actions</th>
          <td mat-cell *matCellDef="let txn">
            <button mat-icon-button (click)="viewDetails(txn.id)">
              <mat-icon>visibility</mat-icon>
            </button>
          </td>
        </ng-container>

        <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
        <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
      </table>
    </div>
  `,
  styles: [`
    .transaction-monitor {
      padding: 24px;
    }
    
    .filters {
      display: flex;
      gap: 16px;
      margin: 24px 0;
    }
    
    .transaction-table {
      width: 100%;
      background: white;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .status-badge {
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: bold;
    }
    
    .status-badge.completed {
      background: #d4edda;
      color: #155724;
    }
    
    .status-badge.pending {
      background: #fff3cd;
      color: #856404;
    }
    
    .status-badge.failed {
      background: #f8d7da;
      color: #721c24;
    }
  `]
})
export class TransactionMonitorComponent implements OnInit {
  displayedColumns: string[] = ['orderNumber', 'user', 'merchant', 'amount', 'status', 'date', 'actions'];
  transactions: Transaction[] = [];
  filteredTransactions: Transaction[] = [];
  selectedStatus: string = 'all';
  searchTerm: string = '';

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.loadTransactions();
  }

  loadTransactions(): void {
    // TODO: Call admin-portal-backend for transactions
    // For now, mock data
    this.transactions = [
      {
        id: 1,
        orderNumber: 'ORD-20251112-001',
        userName: 'Test User',
        merchantName: 'Brown Coffee',
        amount: 25.00,
        status: 'COMPLETED',
        createdAt: new Date().toISOString()
      }
    ];
    this.filteredTransactions = [...this.transactions];
  }

  filterTransactions(): void {
    let filtered = [...this.transactions];
    
    if (this.selectedStatus !== 'all') {
      filtered = filtered.filter(t => t.status === this.selectedStatus);
    }
    
    if (this.searchTerm) {
      filtered = filtered.filter(t => 
        t.orderNumber.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        t.merchantName.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        t.userName.toLowerCase().includes(this.searchTerm.toLowerCase())
      );
    }
    
    this.filteredTransactions = filtered;
  }

  viewDetails(id: number): void {
    // TODO: Show transaction details dialog
    console.log('View transaction:', id);
  }

  formatDate(dateStr: string): string {
    return new Date(dateStr).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }
}



















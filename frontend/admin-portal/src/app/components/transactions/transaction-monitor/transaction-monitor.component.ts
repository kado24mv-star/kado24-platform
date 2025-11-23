import { Component, OnInit } from '@angular/core';
import { PageEvent } from '@angular/material/paginator';
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

      <mat-paginator 
        [length]="totalItems"
        [pageSize]="pageSize"
        [pageSizeOptions]="[10, 20, 50, 100]"
        [pageIndex]="currentPage"
        (page)="onPageChange($event)"
        showFirstLastButtons
        class="transaction-paginator">
      </mat-paginator>
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
    
    .transaction-paginator {
      background: white;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      margin-top: 16px;
    }
  `]
})
export class TransactionMonitorComponent implements OnInit {
  displayedColumns: string[] = ['orderNumber', 'user', 'merchant', 'amount', 'status', 'date', 'actions'];
  transactions: Transaction[] = [];
  filteredTransactions: Transaction[] = [];
  selectedStatus: string = 'all';
  searchTerm: string = '';
  
  // Pagination
  currentPage: number = 0;
  pageSize: number = 20;
  totalItems: number = 0;

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.loadTransactions();
  }

  loadTransactions(): void {
    const params: any = {
      page: this.currentPage.toString(),
      size: this.pageSize.toString()
    };
    
    if (this.selectedStatus !== 'all') {
      params.status = this.selectedStatus;
    }

    this.api.get<any>('/api/admin/transactions', { params }).subscribe({
      next: (response) => {
        if (response.success && response.data) {
          // Map backend response to Transaction interface
          this.transactions = response.data.content.map((order: any) => ({
            id: order.id,
            orderNumber: order.orderNumber,
            userName: `User ${order.userId}`,  // TODO: Fetch user details
            merchantName: `Merchant ${order.merchantId}`,  // TODO: Fetch merchant details
            amount: order.totalAmount,
            status: order.paymentStatus,
            createdAt: order.createdAt
          }));
          
          // Update pagination metadata
          if (response.pagination) {
            this.totalItems = response.pagination.totalItems;
          }
          
          this.applySearchFilter();
        }
      },
      error: (error) => {
        console.error('Failed to load transactions:', error);
        // Fallback to empty array
        this.transactions = [];
        this.filteredTransactions = [];
        this.totalItems = 0;
      }
    });
  }

  filterTransactions(): void {
    // Reset to first page when filter changes
    this.currentPage = 0;
    this.loadTransactions();
  }

  applySearchFilter(): void {
    let filtered = [...this.transactions];
    
    if (this.searchTerm) {
      filtered = filtered.filter(t => 
        t.orderNumber.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        t.merchantName.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        t.userName.toLowerCase().includes(this.searchTerm.toLowerCase())
      );
    }
    
    this.filteredTransactions = filtered;
  }

  onPageChange(event: PageEvent): void {
    this.currentPage = event.pageIndex;
    this.pageSize = event.pageSize;
    this.loadTransactions();
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






















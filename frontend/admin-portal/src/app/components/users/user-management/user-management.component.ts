import { Component, OnInit } from '@angular/core';

interface User {
  id: number;
  fullName: string;
  phoneNumber: string;
  email: string;
  status: string;
  createdAt: string;
}

@Component({
  selector: 'app-user-management',
  template: `
    <div class="user-management">
      <h1>User Management</h1>
      
      <div class="search-bar">
        <mat-form-field>
          <mat-label>Search Users</mat-label>
          <input matInput [(ngModel)]="searchTerm" (ngModelChange)="filterUsers()" placeholder="Phone, email, name...">
          <mat-icon matPrefix>search</mat-icon>
        </mat-form-field>
        
        <mat-form-field>
          <mat-label>Status</mat-label>
          <mat-select [(value)]="selectedStatus" (selectionChange)="filterUsers()">
            <mat-option value="all">All</mat-option>
            <mat-option value="ACTIVE">Active</mat-option>
            <mat-option value="SUSPENDED">Suspended</mat-option>
            <mat-option value="PENDING_VERIFICATION">Pending</mat-option>
          </mat-select>
        </mat-form-field>
      </div>

      <div class="stats-row">
        <div class="stat-card">
          <div class="stat-value">{{stats.total}}</div>
          <div class="stat-label">Total Users</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{stats.active}}</div>
          <div class="stat-label">Active</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{stats.suspended}}</div>
          <div class="stat-label">Suspended</div>
        </div>
      </div>

      <table mat-table [dataSource]="filteredUsers" class="user-table">
        <ng-container matColumnDef="name">
          <th mat-header-cell *matHeaderCellDef>Name</th>
          <td mat-cell *matCellDef="let user">{{user.fullName}}</td>
        </ng-container>

        <ng-container matColumnDef="phone">
          <th mat-header-cell *matHeaderCellDef>Phone</th>
          <td mat-cell *matCellDef="let user">{{user.phoneNumber}}</td>
        </ng-container>

        <ng-container matColumnDef="email">
          <th mat-header-cell *matHeaderCellDef>Email</th>
          <td mat-cell *matCellDef="let user">{{user.email || 'N/A'}}</td>
        </ng-container>

        <ng-container matColumnDef="status">
          <th mat-header-cell *matHeaderCellDef>Status</th>
          <td mat-cell *matCellDef="let user">
            <span class="status-badge" [class]="user.status.toLowerCase()">
              {{user.status}}
            </span>
          </td>
        </ng-container>

        <ng-container matColumnDef="joined">
          <th mat-header-cell *matHeaderCellDef>Joined</th>
          <td mat-cell *matCellDef="let user">{{formatDate(user.createdAt)}}</td>
        </ng-container>

        <ng-container matColumnDef="actions">
          <th mat-header-cell *matHeaderCellDef>Actions</th>
          <td mat-cell *matCellDef="let user">
            <button mat-icon-button [matMenuTriggerFor]="menu">
              <mat-icon>more_vert</mat-icon>
            </button>
            <mat-menu #menu="matMenu">
              <button mat-menu-item (click)="viewUser(user.id)">
                <mat-icon>visibility</mat-icon>
                <span>View Details</span>
              </button>
              <button mat-menu-item (click)="suspendUser(user.id)" *ngIf="user.status === 'ACTIVE'">
                <mat-icon>block</mat-icon>
                <span>Suspend</span>
              </button>
              <button mat-menu-item (click)="activateUser(user.id)" *ngIf="user.status === 'SUSPENDED'">
                <mat-icon>check_circle</mat-icon>
                <span>Activate</span>
              </button>
            </mat-menu>
          </td>
        </ng-container>

        <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
        <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
      </table>
    </div>
  `,
  styles: [`
    .user-management {
      padding: 24px;
    }
    
    .search-bar {
      display: flex;
      gap: 16px;
      margin: 24px 0;
    }
    
    .stats-row {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 16px;
      margin: 24px 0;
    }
    
    .stat-card {
      background: white;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      text-align: center;
    }
    
    .stat-value {
      font-size: 32px;
      font-weight: bold;
      color: #333;
    }
    
    .stat-label {
      font-size: 14px;
      color: #666;
      margin-top: 4px;
    }
    
    .user-table {
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
    
    .status-badge.active {
      background: #d4edda;
      color: #155724;
    }
    
    .status-badge.suspended {
      background: #f8d7da;
      color: #721c24;
    }
  `]
})
export class UserManagementComponent implements OnInit {
  displayedColumns = ['name', 'phone', 'email', 'status', 'joined', 'actions'];
  users: User[] = [];
  filteredUsers: User[] = [];
  searchTerm = '';
  selectedStatus = 'all';
  stats = { total: 0, active: 0, suspended: 0 };

  ngOnInit() {
    this.loadUsers();
  }

  loadUsers() {
    // TODO: Call user-service API
    this.users = [
      {
        id: 1,
        fullName: 'Test User',
        phoneNumber: '+855 12 345 678',
        email: 'test@example.com',
        status: 'ACTIVE',
        createdAt: new Date().toISOString()
      }
    ];
    this.filteredUsers = [...this.users];
    this.updateStats();
  }

  filterUsers() {
    let filtered = [...this.users];
    
    if (this.selectedStatus !== 'all') {
      filtered = filtered.filter(u => u.status === this.selectedStatus);
    }
    
    if (this.searchTerm) {
      filtered = filtered.filter(u =>
        u.fullName.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        u.phoneNumber.includes(this.searchTerm) ||
        (u.email && u.email.toLowerCase().includes(this.searchTerm.toLowerCase()))
      );
    }
    
    this.filteredUsers = filtered;
  }

  updateStats() {
    this.stats.total = this.users.length;
    this.stats.active = this.users.filter(u => u.status === 'ACTIVE').length;
    this.stats.suspended = this.users.filter(u => u.status === 'SUSPENDED').length;
  }

  viewUser(id: number) {
    console.log('View user:', id);
  }

  suspendUser(id: number) {
    if (confirm('Are you sure you want to suspend this user?')) {
      console.log('Suspend user:', id);
    }
  }

  activateUser(id: number) {
    console.log('Activate user:', id);
  }

  formatDate(dateStr: string): string {
    return new Date(dateStr).toLocaleDateString();
  }
}



































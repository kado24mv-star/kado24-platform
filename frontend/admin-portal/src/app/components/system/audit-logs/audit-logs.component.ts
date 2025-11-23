import { Component } from '@angular/core';

@Component({
  selector: 'app-audit-logs',
  template: `
    <div class="audit-logs">
      <h1>📋 Audit Logs</h1>
      
      <div class="filters">
        <mat-form-field>
          <mat-label>Action Type</mat-label>
          <mat-select>
            <mat-option value="all">All Actions</mat-option>
            <mat-option value="login">Login/Logout</mat-option>
            <mat-option value="create">Create</mat-option>
            <mat-option value="update">Update</mat-option>
            <mat-option value="delete">Delete</mat-option>
            <mat-option value="approve">Approve/Reject</mat-option>
          </mat-select>
        </mat-form-field>
        
        <mat-form-field>
          <mat-label>User</mat-label>
          <input matInput placeholder="Search by user...">
        </mat-form-field>
        
        <mat-form-field>
          <mat-label>Date Range</mat-label>
          <mat-select>
            <mat-option value="today">Today</mat-option>
            <mat-option value="week">This Week</mat-option>
            <mat-option value="month">This Month</mat-option>
          </mat-select>
        </mat-form-field>
      </div>

      <table mat-table [dataSource]="logs" class="logs-table">
        <ng-container matColumnDef="timestamp">
          <th mat-header-cell *matHeaderCellDef>Time</th>
          <td mat-cell *matCellDef="let log">{{log.timestamp}}</td>
        </ng-container>

        <ng-container matColumnDef="user">
          <th mat-header-cell *matHeaderCellDef>User</th>
          <td mat-cell *matCellDef="let log">{{log.user}}</td>
        </ng-container>

        <ng-container matColumnDef="action">
          <th mat-header-cell *matHeaderCellDef>Action</th>
          <td mat-cell *matCellDef="let log">
            <span class="action-badge" [class]="log.actionType">
              {{log.action}}
            </span>
          </td>
        </ng-container>

        <ng-container matColumnDef="entity">
          <th mat-header-cell *matHeaderCellDef>Entity</th>
          <td mat-cell *matCellDef="let log">{{log.entity}}</td>
        </ng-container>

        <ng-container matColumnDef="details">
          <th mat-header-cell *matHeaderCellDef>Details</th>
          <td mat-cell *matCellDef="let log">{{log.details}}</td>
        </ng-container>

        <ng-container matColumnDef="ip">
          <th mat-header-cell *matHeaderCellDef>IP Address</th>
          <td mat-cell *matCellDef="let log">{{log.ipAddress}}</td>
        </ng-container>

        <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
        <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
      </table>
    </div>
  `,
  styles: [`
    .audit-logs {
      padding: 24px;
    }
    
    .filters {
      display: flex;
      gap: 16px;
      margin: 24px 0;
    }
    
    .logs-table {
      width: 100%;
      background: white;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .action-badge {
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 11px;
      font-weight: bold;
    }
    
    .action-badge.create {
      background: #d4edda;
      color: #155724;
    }
    
    .action-badge.update {
      background: #cce5ff;
      color: #004085;
    }
    
    .action-badge.delete {
      background: #f8d7da;
      color: #721c24;
    }
    
    .action-badge.approve {
      background: #d1ecf1;
      color: #0c5460;
    }
  `]
})
export class AuditLogsComponent {
  displayedColumns = ['timestamp', 'user', 'action', 'entity', 'details', 'ip'];
  
  logs = [
    {
      timestamp: '2025-11-12 14:30:45',
      user: 'admin@kado24.com',
      action: 'Approved Merchant',
      actionType: 'approve',
      entity: 'Merchant #123',
      details: 'Amazon Coffee approved',
      ipAddress: '192.168.1.100'
    },
    {
      timestamp: '2025-11-12 14:25:12',
      user: 'admin@kado24.com',
      action: 'Updated Settings',
      actionType: 'update',
      entity: 'Platform Settings',
      details: 'Changed commission rate',
      ipAddress: '192.168.1.100'
    }
  ];
}



































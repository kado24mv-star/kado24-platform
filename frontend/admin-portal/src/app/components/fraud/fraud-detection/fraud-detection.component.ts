import { Component } from '@angular/core';

interface FraudAlert {
  id: number;
  type: string;
  severity: 'high' | 'medium' | 'low';
  description: string;
  details: string;
  timestamp: string;
}

@Component({
  selector: 'app-fraud-detection',
  template: `
    <div class="fraud-detection">
      <h1>🛡️ Fraud Detection</h1>
      
      <div class="alert-summary">
        <div class="alert-card high">
          <div class="alert-count">{{highRiskCount}}</div>
          <div class="alert-label">High Risk Alerts</div>
        </div>
        <div class="alert-card medium">
          <div class="alert-count">{{mediumRiskCount}}</div>
          <div class="alert-label">Medium Risk</div>
        </div>
        <div class="alert-card low">
          <div class="alert-count">{{lowRiskCount}}</div>
          <div class="alert-label">Low Risk</div>
        </div>
      </div>

      <div class="alerts-list">
        <mat-card *ngFor="let alert of alerts" class="alert-item" [class.high]="alert.severity === 'high'">
          <div class="alert-header">
            <div>
              <h3>{{alert.type}}</h3>
              <span class="severity-badge" [class]="alert.severity">
                {{alert.severity.toUpperCase()}} RISK
              </span>
            </div>
            <div class="alert-time">{{alert.timestamp}}</div>
          </div>
          
          <p class="alert-description">{{alert.description}}</p>
          <p class="alert-details">{{alert.details}}</p>
          
          <div class="alert-actions">
            <button mat-raised-button color="warn" *ngIf="alert.severity === 'high'">
              Investigate Now
            </button>
            <button mat-button>View Details</button>
            <button mat-button>Dismiss</button>
          </div>
        </mat-card>
      </div>
    </div>
  `,
  styles: [`
    .fraud-detection {
      padding: 24px;
    }
    
    .alert-summary {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 16px;
      margin: 24px 0;
    }
    
    .alert-card {
      padding: 24px;
      border-radius: 8px;
      text-align: center;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .alert-card.high {
      background: #f8d7da;
      border: 2px solid #e74c3c;
    }
    
    .alert-card.medium {
      background: #fff3cd;
      border: 2px solid #f39c12;
    }
    
    .alert-card.low {
      background: #d4edda;
      border: 2px solid #27ae60;
    }
    
    .alert-count {
      font-size: 48px;
      font-weight: bold;
    }
    
    .alert-label {
      font-size: 14px;
      margin-top: 8px;
    }
    
    .alerts-list {
      display: grid;
      gap: 16px;
    }
    
    .alert-item {
      padding: 20px;
    }
    
    .alert-item.high {
      border-left: 4px solid #e74c3c;
    }
    
    .alert-header {
      display: flex;
      justify-content: space-between;
      align-items: start;
      margin-bottom: 12px;
    }
    
    .alert-header h3 {
      margin: 0 0 8px 0;
    }
    
    .severity-badge {
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 11px;
      font-weight: bold;
    }
    
    .severity-badge.high {
      background: #f8d7da;
      color: #721c24;
    }
    
    .severity-badge.medium {
      background: #fff3cd;
      color: #856404;
    }
    
    .alert-description {
      font-weight: bold;
      margin: 12px 0;
    }
    
    .alert-details {
      color: #666;
      font-size: 14px;
    }
    
    .alert-actions {
      margin-top: 16px;
      display: flex;
      gap: 12px;
    }
  `]
})
export class FraudDetectionComponent {
  highRiskCount = 3;
  mediumRiskCount = 7;
  lowRiskCount = 12;
  
  alerts: FraudAlert[] = [
    {
      id: 1,
      type: 'Multiple Failed Redemptions',
      severity: 'high',
      description: 'User +855 XX XXX XXX attempted 15 redemptions in 10 minutes',
      details: 'All attempts failed validation. Possible voucher fraud attempt.',
      timestamp: 'Today, 11:42 AM'
    },
    {
      id: 2,
      type: 'Duplicate Transaction Pattern',
      severity: 'medium',
      description: 'Same voucher redeemed 3 times in different locations',
      details: 'Voucher: KC-2025-7834. May be cloned QR code.',
      timestamp: 'Today, 10:15 AM'
    },
    {
      id: 3,
      type: 'Unusual Purchase Volume',
      severity: 'low',
      description: 'New user purchased $500 in vouchers',
      details: 'User ID: USR-12345. May be legitimate bulk purchase.',
      timestamp: 'Yesterday, 3:30 PM'
    }
  ];
}



































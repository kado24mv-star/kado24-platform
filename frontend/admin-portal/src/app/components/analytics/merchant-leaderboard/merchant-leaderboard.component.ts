import { Component } from '@angular/core';

@Component({
  selector: 'app-merchant-leaderboard',
  template: `
    <div class="leaderboard">
      <h1>🏆 Merchant Performance Leaderboard</h1>
      
      <div class="period-selector">
        <button mat-raised-button [color]="period === 'week' ? 'primary' : ''" (click)="period = 'week'">
          This Week
        </button>
        <button mat-raised-button [color]="period === 'month' ? 'primary' : ''" (click)="period = 'month'">
          This Month
        </button>
        <button mat-raised-button [color]="period === 'all' ? 'primary' : ''" (click)="period = 'all'">
          All Time
        </button>
      </div>

      <div class="top-three">
        <div class="podium second">
          <div class="medal">🥈</div>
          <div class="merchant-name">Sokha Hotel Spa</div>
          <div class="revenue">\$18,900</div>
          <div class="sales">678 sales</div>
        </div>
        
        <div class="podium first">
          <div class="medal">🥇</div>
          <div class="merchant-name">Brown Coffee</div>
          <div class="revenue">\$28,400</div>
          <div class="sales">1,234 sales</div>
        </div>
        
        <div class="podium third">
          <div class="medal">🥉</div>
          <div class="merchant-name">Costa Coffee</div>
          <div class="revenue">\$12,800</div>
          <div class="sales">542 sales</div>
        </div>
      </div>

      <mat-card class="leaderboard-table">
        <table mat-table [dataSource]="merchants">
          <ng-container matColumnDef="rank">
            <th mat-header-cell *matHeaderCellDef>Rank</th>
            <td mat-cell *matCellDef="let merchant; let i = index">
              <strong>{{i + 4}}</strong>
            </td>
          </ng-container>

          <ng-container matColumnDef="name">
            <th mat-header-cell *matHeaderCellDef>Merchant</th>
            <td mat-cell *matCellDef="let merchant">{{merchant.name}}</td>
          </ng-container>

          <ng-container matColumnDef="revenue">
            <th mat-header-cell *matHeaderCellDef>Revenue</th>
            <td mat-cell *matCellDef="let merchant">\${{merchant.revenue.toLocaleString()}}</td>
          </ng-container>

          <ng-container matColumnDef="sales">
            <th mat-header-cell *matHeaderCellDef>Sales</th>
            <td mat-cell *matCellDef="let merchant">{{merchant.sales}}</td>
          </ng-container>

          <ng-container matColumnDef="growth">
            <th mat-header-cell *matHeaderCellDef>Growth</th>
            <td mat-cell *matCellDef="let merchant">
              <span [style.color]="merchant.growth > 0 ? 'green' : 'red'">
                {{merchant.growth > 0 ? '▲' : '▼'}} {{Math.abs(merchant.growth)}}%
              </span>
            </td>
          </ng-container>

          <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
          <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
        </table>
      </mat-card>
    </div>
  `,
  styles: [`
    .leaderboard {
      padding: 24px;
    }
    
    .period-selector {
      display: flex;
      gap: 12px;
      justify-content: center;
      margin: 24px 0;
    }
    
    .top-three {
      display: flex;
      gap: 20px;
      justify-content: center;
      align-items: flex-end;
      margin: 40px 0;
    }
    
    .podium {
      text-align: center;
      padding: 24px;
      border-radius: 12px;
      min-width: 200px;
    }
    
    .podium.first {
      background: linear-gradient(135deg, #ffd700 0%, #ffed4e 100%);
      order: 2;
      transform: translateY(-20px);
    }
    
    .podium.second {
      background: linear-gradient(135deg, #c0c0c0 0%, #e8e8e8 100%);
      order: 1;
    }
    
    .podium.third {
      background: linear-gradient(135deg, #cd7f32 0%, #ffd7b5 100%);
      order: 3;
    }
    
    .medal {
      font-size: 48px;
      margin-bottom: 12px;
    }
    
    .merchant-name {
      font-weight: bold;
      font-size: 16px;
      margin-bottom: 8px;
    }
    
    .revenue {
      font-size: 24px;
      font-weight: bold;
      color: #333;
    }
    
    .sales {
      font-size: 14px;
      color: #666;
      margin-top: 4px;
    }
    
    .leaderboard-table {
      margin-top: 24px;
    }
  `]
})
export class MerchantLeaderboardComponent {
  period = 'month';
  displayedColumns = ['rank', 'name', 'revenue', 'sales', 'growth'];
  Math = Math;
  
  merchants = [
    { name: 'Pizza Palace', revenue: 10500, sales: 445, growth: 15 },
    { name: 'Gym & Fitness', revenue: 9800, sales: 392, growth: 22 },
    { name: 'Beauty Spa', revenue: 8900, sales: 356, growth: -5 },
    { name: 'Book Store', revenue: 7600, sales: 287, growth: 8 },
  ];
}
















import { Component } from '@angular/core';

@Component({
  selector: 'app-analytics-charts',
  template: `
    <div class="analytics-charts">
      <h1>📈 Platform Analytics</h1>
      
      <div class="chart-section">
        <mat-card>
          <mat-card-header>
            <mat-card-title>Revenue Trend (30 Days)</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="chart-placeholder">
              <div class="chart-icon">📈</div>
              <div>Line chart showing daily revenue</div>
              <small>Integrate with Chart.js or ng2-charts</small>
            </div>
          </mat-card-content>
        </mat-card>
      </div>

      <div class="charts-grid">
        <mat-card>
          <mat-card-header>
            <mat-card-title>Sales by Category</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="chart-placeholder">
              <div class="chart-icon">🥧</div>
              <div>Pie chart</div>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card>
          <mat-card-header>
            <mat-card-title>User Growth</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="chart-placeholder">
              <div class="chart-icon">📊</div>
              <div>Bar chart</div>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card>
          <mat-card-header>
            <mat-card-title>Top Merchants</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="chart-placeholder">
              <div class="chart-icon">🏆</div>
              <div>Horizontal bar</div>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card>
          <mat-card-header>
            <mat-card-title>Redemption Rates</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="chart-placeholder">
              <div class="chart-icon">📉</div>
              <div>Area chart</div>
            </div>
          </mat-card-content>
        </mat-card>
      </div>

      <div class="kpi-section">
        <h2>Key Performance Indicators</h2>
        <div class="kpi-grid">
          <div class="kpi-card">
            <div class="kpi-value">97.2%</div>
            <div class="kpi-label">Transaction Success Rate</div>
            <div class="kpi-trend positive">▲ 2.1%</div>
          </div>
          <div class="kpi-card">
            <div class="kpi-value">$23.4</div>
            <div class="kpi-label">Average Order Value</div>
            <div class="kpi-trend positive">▲ 5.3%</div>
          </div>
          <div class="kpi-card">
            <div class="kpi-value">4.2</div>
            <div class="kpi-label">Orders per User</div>
            <div class="kpi-trend negative">▼ 0.8%</div>
          </div>
          <div class="kpi-card">
            <div class="kpi-value">68%</div>
            <div class="kpi-label">Redemption Rate</div>
            <div class="kpi-trend positive">▲ 12%</div>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .analytics-charts {
      padding: 24px;
    }
    
    .chart-section {
      margin: 24px 0;
    }
    
    .charts-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 20px;
      margin: 24px 0;
    }
    
    .chart-placeholder {
      height: 200px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      background: #f5f5f5;
      border-radius: 8px;
      color: #666;
    }
    
    .chart-icon {
      font-size: 48px;
      margin-bottom: 12px;
    }
    
    .kpi-section h2 {
      margin: 32px 0 16px 0;
    }
    
    .kpi-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 16px;
    }
    
    .kpi-card {
      background: white;
      padding: 24px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      text-align: center;
    }
    
    .kpi-value {
      font-size: 36px;
      font-weight: bold;
      color: #333;
    }
    
    .kpi-label {
      font-size: 14px;
      color: #666;
      margin: 8px 0;
    }
    
    .kpi-trend {
      font-size: 14px;
      font-weight: bold;
    }
    
    .kpi-trend.positive {
      color: #27ae60;
    }
    
    .kpi-trend.negative {
      color: #e74c3c;
    }
  `]
})
export class AnalyticsChartsComponent {}
















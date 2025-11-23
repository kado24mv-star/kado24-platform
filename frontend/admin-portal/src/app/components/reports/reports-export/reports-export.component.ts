import { Component } from '@angular/core';

@Component({
  selector: 'app-reports-export',
  template: `
    <div class="reports-export">
      <h1>📊 Reports & Export</h1>
      
      <div class="report-types">
        <mat-card class="report-card">
          <mat-card-header>
            <mat-card-title>📈 Revenue Report</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <p>Platform revenue, merchant payouts, and financial summary</p>
            <mat-form-field>
              <mat-label>Period</mat-label>
              <mat-select value="month">
                <mat-option value="week">This Week</mat-option>
                <mat-option value="month">This Month</mat-option>
                <mat-option value="quarter">This Quarter</mat-option>
                <mat-option value="year">This Year</mat-option>
                <mat-option value="custom">Custom Range</mat-option>
              </mat-select>
            </mat-form-field>
          </mat-card-content>
          <mat-card-actions>
            <button mat-raised-button color="primary">Generate</button>
            <button mat-button>Export CSV</button>
          </mat-card-actions>
        </mat-card>

        <mat-card class="report-card">
          <mat-card-header>
            <mat-card-title>📊 Transaction Report</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <p>All platform transactions with detailed breakdown</p>
            <mat-form-field>
              <mat-label>Period</mat-label>
              <mat-select value="month">
                <mat-option value="week">This Week</mat-option>
                <mat-option value="month">This Month</mat-option>
                <mat-option value="all">All Time</mat-option>
              </mat-select>
            </mat-form-field>
          </mat-card-content>
          <mat-card-actions>
            <button mat-raised-button color="primary">Generate</button>
            <button mat-button>Export Excel</button>
          </mat-card-actions>
        </mat-card>

        <mat-card class="report-card">
          <mat-card-header>
            <mat-card-title>🏪 Merchant Performance</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <p>Sales by merchant, rankings, and growth metrics</p>
            <mat-form-field>
              <mat-label>Sort By</mat-label>
              <mat-select value="revenue">
                <mat-option value="revenue">Revenue</mat-option>
                <mat-option value="sales">Sales Volume</mat-option>
                <mat-option value="growth">Growth Rate</mat-option>
              </mat-select>
            </mat-form-field>
          </mat-card-content>
          <mat-card-actions>
            <button mat-raised-button color="primary">Generate</button>
            <button mat-button>Export PDF</button>
          </mat-card-actions>
        </mat-card>

        <mat-card class="report-card">
          <mat-card-header>
            <mat-card-title>👥 User Analytics</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <p>User growth, engagement, and retention metrics</p>
            <mat-form-field>
              <mat-label>Metrics</mat-label>
              <mat-select value="all">
                <mat-option value="all">All Metrics</mat-option>
                <mat-option value="growth">Growth Only</mat-option>
                <mat-option value="engagement">Engagement</mat-option>
              </mat-select>
            </mat-form-field>
          </mat-card-content>
          <mat-card-actions>
            <button mat-raised-button color="primary">Generate</button>
            <button mat-button>Export</button>
          </mat-card-actions>
        </mat-card>
      </div>

      <mat-card class="schedule-section">
        <mat-card-header>
          <mat-card-title>📅 Scheduled Reports</mat-card-title>
        </mat-card-header>
        <mat-card-content>
          <p>Automatically generate and email reports</p>
          <button mat-raised-button color="accent">+ Schedule New Report</button>
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: [`
    .reports-export {
      padding: 24px;
    }
    
    .report-types {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 20px;
      margin: 24px 0;
    }
    
    .report-card {
      height: fit-content;
    }
    
    mat-form-field {
      width: 100%;
      margin: 12px 0;
    }
    
    .schedule-section {
      margin-top: 24px;
    }
  `]
})
export class ReportsExportComponent {}



































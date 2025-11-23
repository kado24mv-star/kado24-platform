import { Component } from '@angular/core';

@Component({
  selector: 'app-platform-settings',
  template: `
    <div class="platform-settings">
      <h1>Platform Settings</h1>
      
      <mat-card class="settings-section">
        <mat-card-header>
          <mat-card-title>Commission Settings</mat-card-title>
        </mat-card-header>
        <mat-card-content>
          <div class="setting-row">
            <div>
              <div class="setting-label">Platform Commission Rate</div>
              <div class="setting-description">Percentage charged on each transaction</div>
            </div>
            <mat-form-field class="setting-input">
              <input matInput type="number" value="8" min="0" max="100">
              <span matSuffix>%</span>
            </mat-form-field>
          </div>
          
          <div class="setting-row">
            <div>
              <div class="setting-label">Merchant Payout Rate</div>
              <div class="setting-description">Percentage paid to merchants</div>
            </div>
            <div class="setting-value">92%</div>
          </div>
        </mat-card-content>
      </mat-card>

      <mat-card class="settings-section">
        <mat-card-header>
          <mat-card-title>Payout Settings</mat-card-title>
        </mat-card-header>
        <mat-card-content>
          <div class="setting-row">
            <div>
              <div class="setting-label">Payout Frequency</div>
              <div class="setting-description">How often merchants receive payments</div>
            </div>
            <mat-form-field class="setting-input">
              <mat-select value="weekly">
                <mat-option value="weekly">Weekly (Every Friday)</mat-option>
                <mat-option value="biweekly">Bi-weekly</mat-option>
                <mat-option value="monthly">Monthly</mat-option>
              </mat-select>
            </mat-form-field>
          </div>
          
          <div class="setting-row">
            <div>
              <div class="setting-label">Minimum Payout Amount</div>
              <div class="setting-description">Minimum balance before payout</div>
            </div>
            <mat-form-field class="setting-input">
              <input matInput type="number" value="50">
              <span matPrefix>$</span>
            </mat-form-field>
          </div>
        </mat-card-content>
      </mat-card>

      <mat-card class="settings-section">
        <mat-card-header>
          <mat-card-title>Platform Features</mat-card-title>
        </mat-card-header>
        <mat-card-content>
          <mat-slide-toggle checked>Enable Gifting</mat-slide-toggle><br>
          <mat-slide-toggle checked>Enable Reviews & Ratings</mat-slide-toggle><br>
          <mat-slide-toggle checked>Enable Map View</mat-slide-toggle><br>
          <mat-slide-toggle>Enable Social Login</mat-slide-toggle><br>
          <mat-slide-toggle>Enable Offline Mode</mat-slide-toggle>
        </mat-card-content>
      </mat-card>

      <div class="actions">
        <button mat-raised-button color="primary">Save Changes</button>
        <button mat-button>Reset to Defaults</button>
      </div>
    </div>
  `,
  styles: [`
    .platform-settings {
      padding: 24px;
    }
    
    .settings-section {
      margin-bottom: 24px;
    }
    
    .setting-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 16px 0;
      border-bottom: 1px solid #eee;
    }
    
    .setting-label {
      font-weight: bold;
      font-size: 16px;
    }
    
    .setting-description {
      font-size: 12px;
      color: #666;
      margin-top: 4px;
    }
    
    .setting-input {
      width: 200px;
    }
    
    .setting-value {
      font-size: 24px;
      font-weight: bold;
      color: #4facfe;
    }
    
    mat-slide-toggle {
      margin: 12px 0;
    }
    
    .actions {
      display: flex;
      gap: 16px;
      justify-content: center;
      margin-top: 24px;
    }
  `]
})
export class PlatformSettingsComponent {}



































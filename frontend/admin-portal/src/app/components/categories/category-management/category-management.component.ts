import { Component } from '@angular/core';

@Component({
  selector: 'app-category-management',
  template: `
    <div class="category-management">
      <div class="header">
        <h1>Category Management</h1>
        <button mat-raised-button color="primary" (click)="addCategory()">
          + Add Category
        </button>
      </div>

      <div class="categories-grid">
        <mat-card *ngFor="let category of categories" class="category-card">
          <div class="category-icon">{{category.icon}}</div>
          <div class="category-name">{{category.name}}</div>
          <div class="category-count">{{category.voucherCount}} vouchers</div>
          <div class="category-actions">
            <button mat-icon-button (click)="editCategory(category.id)">
              <mat-icon>edit</mat-icon>
            </button>
            <button mat-icon-button (click)="toggleCategory(category.id)">
              <mat-icon>{{category.isActive ? 'visibility' : 'visibility_off'}}</mat-icon>
            </button>
            <button mat-icon-button (click)="deleteCategory(category.id)">
              <mat-icon>delete</mat-icon>
            </button>
          </div>
        </mat-card>
      </div>
    </div>
  `,
  styles: [`
    .category-management {
      padding: 24px;
    }
    
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 24px;
    }
    
    .categories-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 20px;
    }
    
    .category-card {
      text-align: center;
      padding: 24px;
    }
    
    .category-icon {
      font-size: 48px;
      margin-bottom: 12px;
    }
    
    .category-name {
      font-size: 18px;
      font-weight: bold;
      margin-bottom: 8px;
    }
    
    .category-count {
      font-size: 14px;
      color: #666;
      margin-bottom: 16px;
    }
    
    .category-actions {
      display: flex;
      justify-content: center;
      gap: 8px;
    }
  `]
})
export class CategoryManagementComponent {
  categories = [
    { id: 1, name: 'Food & Dining', icon: '🍽️', voucherCount: 142, isActive: true },
    { id: 2, name: 'Entertainment', icon: '🎭', voucherCount: 89, isActive: true },
    { id: 3, name: 'Health & Beauty', icon: '💆', voucherCount: 67, isActive: true },
    { id: 4, name: 'Shopping', icon: '🛍️', voucherCount: 54, isActive: true },
    { id: 5, name: 'Travel & Hotels', icon: '✈️', voucherCount: 32, isActive: true },
    { id: 6, name: 'Services', icon: '🔧', voucherCount: 28, isActive: true },
  ];

  addCategory() {
    const name = prompt('Category Name:');
    const icon = prompt('Category Icon (emoji):');
    if (name && icon) {
      alert('Category added!');
    }
  }

  editCategory(id: number) {
    console.log('Edit category:', id);
  }

  toggleCategory(id: number) {
    console.log('Toggle category:', id);
  }

  deleteCategory(id: number) {
    if (confirm('Delete this category?')) {
      alert('Category deleted');
    }
  }
}



































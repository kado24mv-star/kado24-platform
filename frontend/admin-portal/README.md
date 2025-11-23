# Kado24 Admin Portal

Angular web application for platform administrators to manage the Kado24 marketplace.

## Features

- Admin authentication
- Platform dashboard with metrics
- Merchant approval workflow
- Voucher moderation
- Transaction monitoring
- User management
- Analytics and reporting
- Platform configuration

## Setup

```bash
# Install dependencies
npm install

# Run development server
ng serve

# Build for production
ng build --configuration production
```

Access at: http://localhost:4200

## Backend Integration

Connects to:
- Auth Service (8081) - Admin login
- Admin Portal Backend (8089) - Admin API
- All other services via admin backend

## Default Admin Credentials

- Email: admin@kado24.com
- Password: Admin@123456

## Key Components

### Dashboard
- Platform statistics
- Recent activity
- Quick actions

### Merchant Management
- Pending merchant applications
- Approve/reject merchants
- Merchant details
- Performance metrics

### Transaction Monitoring
- All transactions list
- Transaction details
- Fraud detection alerts
- Revenue reports

### User Management
- User list with search
- User details
- Account status management
- Activity logs

### Analytics
- Revenue charts
- User engagement metrics
- Popular vouchers
- Merchant performance

## Project Structure

```
src/app/
├── components/
│   ├── dashboard/
│   ├── merchants/
│   ├── transactions/
│   ├── users/
│   └── analytics/
├── services/
│   ├── api.service.ts
│   ├── auth.service.ts
│   └── merchant.service.ts
├── guards/
│   └── auth.guard.ts
└── models/
```

## Status

**Current:** Basic structure and authentication implemented  
**Next:** Complete merchant approval and transaction monitoring screens







































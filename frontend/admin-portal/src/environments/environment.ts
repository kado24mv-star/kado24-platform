export const environment = {
  production: false,
  
  // Empty URLs - use relative paths so webpack proxy handles routing
  apiGatewayUrl: '',
  
  // All requests use relative paths (proxied by webpack to correct services)
  authServiceUrl: '',
  userServiceUrl: '',
  voucherServiceUrl: '',
  orderServiceUrl: '',
  merchantServiceUrl: '',
  adminBackendUrl: '',
  
  // API Endpoints
  api: {
    auth: {
      login: '/api/v1/auth/login',
      logout: '/api/v1/auth/logout',
    },
    admin: {
      dashboard: '/api/admin/dashboard',
      merchantsPending: '/api/admin/merchants/pending',
      merchantApprove: '/api/admin/merchants/{id}/approve',
      merchantReject: '/api/admin/merchants/{id}/reject',
      transactions: '/api/admin/transactions',
      users: '/api/admin/users',
      usersPending: '/api/v1/admin/verifications/pending',
      userVerify: '/api/v1/admin/verifications/{id}/verify',
      userReject: '/api/v1/admin/verifications/{id}/reject',
      statistics: '/api/admin/statistics',
    },
  },
};


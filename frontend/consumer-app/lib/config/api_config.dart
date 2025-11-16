class ApiConfig {
  // API Gateway URL (APISIX)
  static const String apiGatewayUrl = 'http://localhost:9080';
  
  // All requests go through API Gateway
  static const String authServiceUrl = apiGatewayUrl;
  static const String userServiceUrl = apiGatewayUrl;
  static const String voucherServiceUrl = apiGatewayUrl;
  static const String orderServiceUrl = apiGatewayUrl;
  static const String walletServiceUrl = apiGatewayUrl;
  static const String redemptionServiceUrl = apiGatewayUrl;
  static const String merchantServiceUrl = apiGatewayUrl;
  static const String mockPaymentServiceUrl = apiGatewayUrl;
  
  // API Endpoints
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin = '/api/v1/auth/login';
  static const String authSendOtp = '/api/v1/auth/send-otp';
  static const String authVerifyOtp = '/api/v1/auth/verify-otp';
  static const String authForgotPassword = '/api/v1/auth/forgot-password';
  static const String authResetPassword = '/api/v1/auth/reset-password';
  static const String authRefresh = '/api/v1/auth/refresh';
  static const String authLogout = '/api/v1/auth/logout';
  
  static const String userProfile = '/api/v1/users/profile';
  static const String userUpdate = '/api/v1/users/profile';
  
  static const String vouchersList = '/api/v1/vouchers';
  static const String vouchersSearch = '/api/v1/vouchers/search';
  static const String vouchersCategories = '/api/v1/categories';
  static const String vouchersDetail = '/api/v1/vouchers';
  
  static const String ordersCreate = '/api/v1/orders';
  static const String ordersList = '/api/v1/orders';
  static const String ordersDetail = '/api/v1/orders';
  
  static const String walletList = '/api/v1/wallet';
  static const String walletDetail = '/api/v1/wallet';
  
  static const String mockPaymentInit = '/api/mock/payment/init';
  static const String mockPaymentProcess = '/api/mock/payment/process';
  
  // For Android Emulator, use 10.0.2.2 instead of localhost
  // For iOS Simulator, use localhost
  // For physical device, use your computer's IP address
  static String getBaseUrl(String service) {
    // Auto-detect platform and adjust URL
    return service;
  }
}


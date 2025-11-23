class ApiConfig {
  // API Gateway URL (APISIX)
  static const String apiGatewayUrl = 'http://localhost:9080';
  
  // All requests go through API Gateway
  static String getAuthUrl() => apiGatewayUrl;
  static String getMerchantUrl() => apiGatewayUrl;
  static String getVoucherUrl() => apiGatewayUrl;
  static String getRedemptionUrl() => apiGatewayUrl;
  static String getPayoutUrl() => apiGatewayUrl;
  static String getOrderUrl() => apiGatewayUrl;
}


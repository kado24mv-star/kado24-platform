# =============================================
# Integration Test Configuration
# =============================================

# Base URLs
$script:API_GATEWAY_URL = "http://localhost:9080"
$script:AUTH_SERVICE_URL = "http://localhost:8081"
$script:USER_SERVICE_URL = "http://localhost:8082"
$script:VOUCHER_SERVICE_URL = "http://localhost:8083"
$script:MERCHANT_SERVICE_URL = "http://localhost:8088"

# OAuth2 Configuration
$script:OAUTH2_CLIENT_ID = "kado24-backend"
$script:OAUTH2_CLIENT_SECRET = "kado24-backend-secret"
$script:OAUTH2_TOKEN_ENDPOINT = "$AUTH_SERVICE_URL/oauth2/token"
$script:OAUTH2_JWKS_ENDPOINT = "$AUTH_SERVICE_URL/oauth2/jwks"
$script:OIDC_DISCOVERY_ENDPOINT = "$AUTH_SERVICE_URL/.well-known/openid-configuration"

# Test Credentials
$script:TEST_ADMIN_EMAIL = "admin@kado24.com"
$script:TEST_ADMIN_PASSWORD = "Admin@123456"
$script:TEST_MERCHANT_PHONE = "+60123456789"

# Test Timeouts
$script:HTTP_TIMEOUT = 30
$script:SERVICE_STARTUP_TIMEOUT = 120

# Test Results
$script:TEST_RESULTS = @{
    Total = 0
    Passed = 0
    Failed = 0
    Skipped = 0
    FailedTests = @()
}

# Export functions
function Get-Config {
    return @{
        ApiGatewayUrl = $script:API_GATEWAY_URL
        AuthServiceUrl = $script:AUTH_SERVICE_URL
        UserServiceUrl = $script:USER_SERVICE_URL
        VoucherServiceUrl = $script:VOUCHER_SERVICE_URL
        MerchantServiceUrl = $script:MERCHANT_SERVICE_URL
        OAuth2ClientId = $script:OAUTH2_CLIENT_ID
        OAuth2ClientSecret = $script:OAUTH2_CLIENT_SECRET
        OAuth2TokenEndpoint = $script:OAUTH2_TOKEN_ENDPOINT
        OAuth2JwksEndpoint = $script:OAUTH2_JWKS_ENDPOINT
        OidcDiscoveryEndpoint = $script:OIDC_DISCOVERY_ENDPOINT
        TestAdminEmail = $script:TEST_ADMIN_EMAIL
        TestAdminPassword = $script:TEST_ADMIN_PASSWORD
        TestMerchantPhone = $script:TEST_MERCHANT_PHONE
    }
}


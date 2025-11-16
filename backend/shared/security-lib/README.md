# Kado24 Security Library

Shared security configurations, JWT token handling, OAuth2 setup, and authentication utilities for Kado24 platform.

## 📦 Installation

Add this dependency to your service's `pom.xml`:

```xml
<dependency>
    <groupId>com.kado24</groupId>
    <artifactId>security-lib</artifactId>
    <version>1.0.0</version>
</dependency>
```

## 🔧 Build

```bash
cd backend/shared/security-lib
mvn clean install
```

## 📚 Components

### JWT Token Provider

**`JwtTokenProvider`**: Core JWT token management

- Generate access tokens (24h expiry)
- Generate refresh tokens (7 days expiry)
- Validate tokens
- Extract claims (username, userId, roles)

### JWT Authentication Filter

**`JwtAuthenticationFilter`**: Spring Security filter for JWT validation

- Extracts JWT from `Authorization: Bearer <token>` header
- Validates token signature and expiration
- Sets Spring Security authentication context
- Supports query parameter tokens for WebSocket connections

### Token Blacklist Service

**`TokenBlacklistService`**: Redis-based token revocation

- Blacklist tokens on logout
- Check if token is revoked
- Automatic expiration matching token TTL

### Security Configuration

**`SecurityConfig`**: Base Spring Security configuration

- Stateless session management
- JWT filter integration
- CORS configuration
- Public endpoint configuration
- Method-level security enabled

### Password Utilities

**`PasswordEncoderUtil`**: Password encoding and validation

- BCrypt encoding (strength 10)
- Password strength validation
- Password matching

## 💡 Usage Examples

### Generate JWT Tokens

```java
@Autowired
private JwtTokenProvider jwtTokenProvider;

// Generate access token
String accessToken = jwtTokenProvider.generateAccessToken(username, role, userId);

// Generate refresh token
String refreshToken = jwtTokenProvider.generateRefreshToken(username);

// Validate token
boolean isValid = jwtTokenProvider.validateToken(token);

// Extract information
String username = jwtTokenProvider.getUsernameFromToken(token);
Long userId = jwtTokenProvider.getUserIdFromToken(token);
String roles = jwtTokenProvider.getRolesFromToken(token);
```

### Token Blacklist (Logout)

```java
@Autowired
private TokenBlacklistService tokenBlacklistService;

// Blacklist token on logout
Date expiration = jwtTokenProvider.getExpirationDateFromToken(token);
tokenBlacklistService.blacklistToken(token, expiration.getTime());

// Check if token is blacklisted
boolean isBlacklisted = tokenBlacklistService.isTokenBlacklisted(token);
```

### Password Encoding

```java
// Encode password
String encodedPassword = PasswordEncoderUtil.encode("myPassword123");

// Verify password
boolean matches = PasswordEncoderUtil.matches("myPassword123", encodedPassword);

// Validate password strength
boolean isStrong = PasswordEncoderUtil.isStrongPassword("MyP@ssw0rd");
String message = PasswordEncoderUtil.getPasswordStrengthMessage("weak");
```

### Service Configuration

In your service's `application.yml`:

```yaml
jwt:
  secret: ${JWT_SECRET:your-secret-key-minimum-256-bits-change-in-production}
  expiration: 86400000  # 24 hours
  refresh-expiration: 604800000  # 7 days

spring:
  data:
    redis:
      host: localhost
      port: 6379
      password: kado24_redis_pass
```

### Enable Security in Your Service

```java
@SpringBootApplication
@ComponentScan(basePackages = {"com.kado24.myservice", "com.kado24.security"})
public class MyServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyServiceApplication.class, args);
    }
}
```

### Custom Security Configuration

```java
@Configuration
public class CustomSecurityConfig {
    
    @Bean
    public SecurityFilterChain customFilterChain(HttpSecurity http, 
                                                  JwtAuthenticationFilter jwtFilter) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/v1/auth/**").permitAll()
                .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/v1/merchant/**").hasAnyRole("MERCHANT", "ADMIN")
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
            
        return http.build();
    }
}
```

### Protect Controller Methods

```java
@RestController
@RequestMapping("/api/v1/users")
public class UserController {
    
    // Anyone authenticated can access
    @GetMapping("/profile")
    public ResponseEntity<UserProfile> getProfile() {
        // Current user automatically available via SecurityContextHolder
        return ResponseEntity.ok(userProfile);
    }
    
    // Only ADMIN role can access
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/all")
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(users);
    }
    
    // Only MERCHANT or ADMIN roles can access
    @PreAuthorize("hasAnyRole('MERCHANT', 'ADMIN')")
    @PostMapping("/vouchers")
    public ResponseEntity<Voucher> createVoucher() {
        return ResponseEntity.ok(voucher);
    }
}
```

### Get Current User Information

```java
@Service
public class UserService {
    
    public User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        // Fetch user from database using username
        return userRepository.findByPhoneNumber(username).orElseThrow();
    }
    
    public boolean hasRole(String role) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth.getAuthorities().stream()
            .anyMatch(a -> a.getAuthority().equals("ROLE_" + role));
    }
}
```

### Extract User Info from Request

```java
@RestController
public class MyController {
    
    @GetMapping("/profile")
    public ResponseEntity<Profile> getProfile(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String username = (String) request.getAttribute("username");
        
        // Use userId and username
        return ResponseEntity.ok(profile);
    }
}
```

## 🔐 Security Best Practices

### JWT Secret

Always use a strong secret key (minimum 256 bits) and store it securely:

```bash
# Generate a strong secret
openssl rand -base64 32

# Set as environment variable
export JWT_SECRET="your-generated-secret-here"
```

### Password Requirements

The library enforces strong passwords:
- Minimum 8 characters
- At least 3 of: uppercase, lowercase, digit, special character

### Token Management

1. **Access tokens**: Short-lived (24h), included in every request
2. **Refresh tokens**: Long-lived (7 days), used only to get new access tokens
3. **Blacklist**: Always blacklist tokens on logout

### CORS Configuration

Default CORS allows all origins (`*`). In production, restrict to your domains:

```java
configuration.setAllowedOrigins(Arrays.asList(
    "https://consumer.kado24.com",
    "https://merchant.kado24.com",
    "https://admin.kado24.com"
));
```

## 🧪 Testing

```java
@SpringBootTest
@AutoConfigureMockMvc
class SecurityTests {
    
    @Autowired
    private JwtTokenProvider jwtTokenProvider;
    
    @Test
    void testTokenGeneration() {
        String token = jwtTokenProvider.generateAccessToken("user123", "CONSUMER", 1L);
        assertNotNull(token);
        assertTrue(jwtTokenProvider.validateToken(token));
        assertEquals("user123", jwtTokenProvider.getUsernameFromToken(token));
    }
    
    @Test
    void testPasswordEncoding() {
        String raw = "MyPassword123";
        String encoded = PasswordEncoderUtil.encode(raw);
        assertTrue(PasswordEncoderUtil.matches(raw, encoded));
    }
}
```

## 📝 Configuration Reference

### Application Properties

```yaml
# JWT Configuration
jwt:
  secret: ${JWT_SECRET:default-secret-change-me}
  expiration: 86400000  # 24 hours in milliseconds
  refresh-expiration: 604800000  # 7 days in milliseconds

# Spring Security
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8081

# Redis (for token blacklist)
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD}
```

## 🎯 Integration with Services

### Auth Service
- Generates tokens on login
- Refreshes tokens
- Revokes tokens on logout

### Resource Services (User, Voucher, etc.)
- Validate tokens via JWT filter
- Extract user information
- Enforce role-based access

### API Gateway (APISIX)
- First line of defense
- Validates JWT before routing
- Passes token to services

## 📚 Additional Resources

- [JWT.io](https://jwt.io/) - JWT debugger
- [Spring Security Documentation](https://spring.io/projects/spring-security)
- [OAuth 2.0 Specification](https://oauth.net/2/)




















# Update Backend Services to Tomcat Deployment

All backend service Dockerfiles have been updated from `eclipse-temurin:17-jre-alpine` to `tomcat:10-jre17`.

## Changes Made

1. **Base Image**: Changed from `eclipse-temurin:17-jre-alpine` to `tomcat:10-jre17`
2. **Deployment**: Changed from JAR execution to WAR deployment to Tomcat webapps
3. **Port Configuration**: Each service's Tomcat instance is configured with the correct port

## Required Next Steps

### 1. Update pom.xml Files to Package as WAR

For each service, update the `pom.xml` to package as WAR instead of JAR:

```xml
<packaging>war</packaging>
```

And add the following dependency (if not already present):

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-tomcat</artifactId>
    <scope>provided</scope>
</dependency>
```

### 2. Update Main Application Class

For each service's main application class, extend `SpringBootServletInitializer`:

```java
@SpringBootApplication
public class YourServiceApplication extends SpringBootServletInitializer {
    
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(YourServiceApplication.class);
    }
    
    public static void main(String[] args) {
        SpringApplication.run(YourServiceApplication.class, args);
    }
}
```

### 3. Service Ports

Each service is configured with the following ports:

- **auth-service**: 8081
- **user-service**: 8082
- **voucher-service**: 8083
- **order-service**: 8084
- **wallet-service**: 8086
- **redemption-service**: 8087
- **merchant-service**: 8088
- **admin-portal-backend**: 8089
- **notification-service**: 8091
- **payout-service**: 8092
- **analytics-service**: 8093
- **mock-payment-service**: 8095

### 4. Build and Deploy

After updating pom.xml files:

```bash
# Build each service
mvn clean package

# The build will create a WAR file in target/ directory
# Docker will copy this WAR to Tomcat webapps/ROOT.war
```

## Benefits of Tomcat Deployment

1. **Standard Servlet Container**: Uses industry-standard Tomcat
2. **Better Resource Management**: Tomcat handles connection pooling and resource management
3. **Easier Monitoring**: Standard Tomcat management interfaces
4. **Flexibility**: Can deploy multiple applications to same Tomcat instance (if needed)

## Notes

- WAR files are deployed as `ROOT.war` to serve from root context path
- Tomcat automatically starts when container starts
- Environment variables are still passed through to the application
- All existing functionality should work the same way


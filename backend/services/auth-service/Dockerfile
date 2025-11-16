FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/*.jar app.jar

ENV POSTGRES_HOST=postgres \
    POSTGRES_PORT=5432 \
    POSTGRES_DB=kado24_db \
    POSTGRES_USER=kado24_user \
    POSTGRES_PASSWORD=kado24_pass \
    DB_HOST=postgres \
    DB_PORT=5432 \
    DB_NAME=kado24_db \
    DB_USER=kado24_user \
    DB_PASSWORD=kado24_pass \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    REDIS_PASSWORD=kado24_redis_pass \
    KAFKA_BOOTSTRAP_SERVERS=kafka:9093

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]


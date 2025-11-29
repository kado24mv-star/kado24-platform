FROM tomcat:10-jre17

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Set working directory
WORKDIR /usr/local/tomcat

# Copy WAR file to Tomcat webapps (rename to ROOT.war for root context)
# Note: Update pom.xml to package as WAR instead of JAR
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

# Environment variables
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
    KAFKA_BOOTSTRAP_SERVERS=kafka:9093 \
    SERVER_PORT=8081

# Configure Tomcat to use port 8081
RUN sed -i 's/port="8080"/port="8081"/' /usr/local/tomcat/conf/server.xml

EXPOSE 8081

# Tomcat starts automatically via CMD in base image


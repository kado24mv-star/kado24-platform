FROM tomcat:10-jre17

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Set working directory
WORKDIR /usr/local/tomcat

# Copy WAR file to Tomcat webapps
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

# Configure Tomcat to use port 8087
ENV SERVER_PORT=8087
RUN sed -i 's/port="8080"/port="8087"/' /usr/local/tomcat/conf/server.xml

EXPOSE 8087

# Tomcat starts automatically via CMD in base image

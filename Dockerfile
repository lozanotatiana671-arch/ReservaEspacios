FROM tomcat:10.1-jdk21-temurin
COPY target/ReservaEspacios-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080

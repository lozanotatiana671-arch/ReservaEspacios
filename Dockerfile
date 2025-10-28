# Etapa 1: Construcción con Maven
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
RUN mvn -B -DskipTests clean package

# Etapa 2: Ejecución con Tomcat
FROM tomcat:10.1-jdk21-temurin
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080

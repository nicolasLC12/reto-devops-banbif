
FROM maven:3.9-eclipse-temurin-17 AS compilacion

WORKDIR /aplicacion
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src

RUN mvn clean package -DskipTests
FROM eclipse-temurin:17-jre

WORKDIR /aplicacion
COPY --from=compilacion /aplicacion/target/*.jar aplicacion.jar


EXPOSE 8080
ENTRYPOINT ["java", "-jar", "aplicacion.jar"]

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/app.jar app.jar
CMD ["java","-jar","app.jar"]

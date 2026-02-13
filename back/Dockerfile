# Stage 1: Build the application
FROM gradle:8.12.0-jdk21-alpine AS build

WORKDIR /app

# Copy gradle files
COPY build.gradle settings.gradle ./
COPY gradle gradle
COPY gradlew gradlew.bat ./

# Download dependencies
RUN gradle dependencies --no-daemon || true

# Copy source code
COPY src src

# Build the application
RUN gradle bootJar --no-daemon

# Stage 2: Run the application
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy the built jar from build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Expose port 8080
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

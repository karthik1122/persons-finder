# -------- Stage 1: Build --------
FROM gradle:8.5-jdk17-alpine AS builder

WORKDIR /home/gradle/project

# Copy Gradle files for dependency caching
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle ./gradle

# Pre-cache dependencies
RUN gradle dependencies --no-daemon || true

# Copy source code
COPY src ./src

# Build fat jar
RUN gradle clean bootJar --no-daemon

# -------- Stage 2: Runtime --------
FROM eclipse-temurin:17-jre-alpine

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy jar from builder
COPY --from=builder /home/gradle/project/build/libs/*.jar app.jar

# Use non-root user
USER appuser

# Expose port
EXPOSE 8080

# Container-aware JVM flags
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
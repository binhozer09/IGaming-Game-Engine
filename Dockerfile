# Multi-stage build for Render and other Docker hosts
FROM gradle:9.1-jdk21-alpine AS build
WORKDIR /workspace
COPY --chown=gradle:gradle . .
RUN chmod +x ./gradlew && ./gradlew --no-daemon clean installDist

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /workspace/build/install/casino-engine/ ./
RUN useradd --system --create-home --uid 10001 appuser && chown -R appuser:appuser /app
USER appuser
ENV HTTP_PORT=10000
ENV GRPC_PORT=5050
EXPOSE 10000 5050
CMD ["sh", "-c", "export HTTP_PORT=${PORT:-${HTTP_PORT:-10000}}; exec /app/bin/casino-engine"]

ARG LEAN_VERSION=4.8.0-rc2

FROM ghcr.io/lambda-feedback/evaluation-function-base/lean:${LEAN_VERSION} as build

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN lake build

FROM ghcr.io/lambda-feedback/evaluation-function-base/scratch:latest

# Copy the evaluation function binary from the build stage
COPY --from=build /app/.lake/build/bin/evaluation /app/evaluation

# Enable debug logging
ENV LOG_LEVEL="debug"

# Command to start the evaluation function with
ENV FUNCTION_COMMAND="/app/evaluation"

# Interface to use for the evaluation function
ENV FUNCTION_INTERFACE="file"

ARG LEAN_VERSION=4.8.0-rc2

FROM ghcr.io/lambda-feedback/evaluation-function-base/lean:${LEAN_VERSION} as build

COPY . .

RUN lake build

# Use the scratch image for the final layer to reduce the image size
FROM ghcr.io/lambda-feedback/evaluation-function-base/scratch:latest

# Copy the evaluation function binary from the build stage
COPY --from=build /app/.lake/build/bin/evaluation /app/evaluation

# Set to "debug" to enable debug logging
ENV LOG_LEVEL="info"

# Command to start the evaluation function with
ENV FUNCTION_COMMAND="/app/evaluation"

# Interface to use for the evaluation function
ENV FUNCTION_INTERFACE="file"

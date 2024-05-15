FROM ghcr.io/lambda-feedback/evaluation-function-base/lean:latest as build

COPY . .

RUN lake build

FROM ghcr.io/lambda-feedback/evaluation-function-base/scratch:latest

# Copy the evaluation function binary from the build stage
COPY --from=build /app/.lake/build/bin/evaluation_function /app/evaluation_function

# Enable debug logging
ENV LOG_LEVEL="debug"

# Command to start the evaluation function with
ENV FUNCTION_COMMAND="/app/evaluation_function"

# Interface to use for the evaluation function
ENV FUNCTION_INTERFACE="file"

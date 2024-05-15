FROM ghcr.io/lambda-feedback/evaluation-function-base/lean:latest as base

COPY . .

FROM ghcr.io/lambda-feedback/evaluation-function-base/scratch:latest

# Command to start the evaluation function with
ENV FUNCTION_COMMAND=""

# Args to start the evaluation function with
ENV FUNCTION_ARGS="-f,/app/evaluation_function.wl"

# Interface to use for the evaluation function
ENV FUNCTION_INTERFACE="file"

# Copy the evaluation function to the app directory
COPY ./evaluation_function.wl /app/evaluation_function.wl
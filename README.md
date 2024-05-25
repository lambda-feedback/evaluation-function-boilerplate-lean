# Lean Language Evaluation Function

This repository contains the boilerplate code needed to create a containerized evaluation function written in Lean 4 Language.

## Usage

### Run the Docker Image

The pre-built Docker image comes with [`shimmy`](https://github.com/lambda-feedback/shimmy) installed. This is a small application that listens for incoming HTTP requests, validates the incoming data and forwards it to the underlying evaluation function.

The pre-built Docker image is available on the GitHub Container Registry. You can run the image using the following command:

```bash
docker run -p 8080:8080 ghcr.io/lambda-feedback/my-lean-evaluation-function:latest
```

### Run the Binary

**Raw Mode**

To run the evaluation function, you need to build the binary first. See the [Building the Evaluation Function](#building-the-evaluation-function) section for more information.

Then, use the following command to run the evaluation function:

```bash
.lake/build/bin/evaluation request.json response.json
```

This will run the evaluation function using the input data from `request.json` and write the output to `response.json`.

**Shimmy**

To have a more user-friendly experience, you can use [`shimmy`](https://github.com/lambda-feedback/shimmy) to run the evaluation function. This is a small application that listens for incoming HTTP requests, validates the incoming data and forwards it to the underlying evaluation function.

To run the evaluation function using `shimmy`, use the following command:

```bash
shimmy -c ".lake/build/bin/evaluation" -i file
```

## Deployment

<!-- As shimmy detects the underlying execution environment, the Docker image can be deployed to various platforms, such as AWS Lambda. -->

## Development

This chapter will guide you through the development process of the evaluation function.

### Prerequisites

In order to develop, test and build the evaluation function, you need to have the following tools installed:

- [Lean 4](https://lean-lang.org/lean4/doc/quickstart.html)
- [Docker](https://docs.docker.com/get-docker/)

The lean toolchain will automatically install the right version of Lean 4 for you as soon as you're working on the evaluation function. You can find the toolchain version in the `lean-toolchain` file.

### Repository Structure

```bash
.github/workflows/
    build.yml       # builds the public evaluation function image
    deploy.yml      # deploys the evaluation function to Lambda Feedback

src/                # evaluation function source code
    Evaluation.lean # module containing the evaluation function
    Main.lean       # module containing the `main` function used to build the executable

tests/              # testing code
    Main.lean       # module containing tests and `main` function run by `lake test`

util/               # utility source code
    Testing.lean    # module containing utility for running tests

config.json         # evaluation function deployment configuration file
lakefile.lean       # Lake build configuration
lean-toolchain      # Lean toolchain version configuration
```

### Building the Evaluation Function

To build the evaluation function, run the following command:

```bash
lake build
```

This will build a binary executable using the default of the evaluation function, which is configured in `lakefile.lean`.

The executable can be found in `.lake/build/bin/`.

### Running Tests

To run the tests, run the following command:

```bash
lake test
```

This will use the lake test executor to run the module declared as test runner in `lakefile.lean`. You can find the test module in `tests/Main.lean`.

### Building the Docker Image

To build the Docker image, run the following command:

```bash
docker build -t my-lean-evaluation-function .
```

The Dockerfile accepts the following build arguments:

- `LEAN_VERSION`: *(optional)* the version of Lean 4 to use.
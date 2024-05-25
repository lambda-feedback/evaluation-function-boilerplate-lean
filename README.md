# Lean Language Evaluation Function

This repository contains the boilerplate code needed to create a containerized evaluation function written in Lean 4 Language.


## Quickstart

This chapter helps you to quickly creating a new Lean 4 evaluation function using this template repository.

#### 1. Create a new repository

- In GitHub, choose `Use this template` > `Create a new repository` in the repository toolbar.

- Choose the owner, and pick a name for the new repository.

  > If you want to deploy the evaluation function to Lambda Feedback, make sure to choose the Lambda Feedback organization as the owner.

- Set the visibility to `Public` or `Private`.

  > If you want to use GitHub [deployment protection rules](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#deployment-protection-rules), make sure to set the visibility to `Public`.

- Click on `Create repository`.

#### 2. Clone the new repository

Clone the new repository to your local machine using the following command:

```bash
git clone <repository-url>
```

#### 3. Configure the evaluation function

When deploying to Lambda Feedback, set the evaluation function name in the `config.json` file. Read the [Deploy to Lambda Feedback](#deploy-to-lambda-feedback) section for more information.

#### 4. Develop the evaluation function

You're ready to start developing your evaluation function. Head over to the [Development](#development) section to learn more.


## Usage

### Run the Docker Image

The pre-built Docker image comes with [`shimmy`](https://github.com/lambda-feedback/shimmy) installed.

> Shimmy is a small application that listens for incoming HTTP requests, validates the incoming data and forwards it to the underlying evaluation function. Learn more about shimmy in the [Documentation](https://github.com/lambda-feedback/shimmy).

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

To have a more user-friendly experience, you can use [`shimmy`](https://github.com/lambda-feedback/shimmy) to run the evaluation function.

> Shimmy is a small application that listens for incoming HTTP requests, validates the incoming data and forwards it to the underlying evaluation function. Learn more about shimmy in the [Documentation](https://github.com/lambda-feedback/shimmy).

To run the evaluation function using `shimmy`, use the following command:

```bash
shimmy -c ".lake/build/bin/evaluation" -i file
```

## Development

This chapter will guide you through the development process of the evaluation function.

### Prerequisites

In order to develop, test and build the evaluation function, you need to have the following tools installed:

- [Lean 4](https://lean-lang.org/lean4/doc/quickstart.html)
- [Docker](https://docs.docker.com/get-docker/)

> The lean toolchain will automatically install the right version of Lean 4 for you as soon as you're working on the evaluation function. You can find the toolchain version in the `lean-toolchain` file.

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


## Deployment

This section guides you through the deployment process of the evaluation function. If you want to deploy the evaluation function to Lambda Feedback, follow the steps in the [Lambda Feedback](#lambda-feedback) section. Otherwise, you can deploy the evaluation function to other platforms using the [Other Platforms](#other-platforms) section.

### Deploy to Lambda Feedback

Deploying the evaluation function to Lambda Feedback is simple and straightforward, as long as the repository is within the [Lambda Feedback organization](https://github.com/lambda-feedback).

After configuring the repository, a [GitHub Actions workflow](.github/workflows/deploy.yml) will automatically build and deploy the evaluation function to Lambda Feedback as soon as changes are pushed to the main branch of the repository.

**Configuration**

The deployment configuration is stored in the `config.json` file. Choose a unique name for the evaluation function and set the `EvaluationFunctionName` field in [`config.json`](config.json).

> The evaluation function name must be unique within the Lambda Feedback organization, and must be in `lowerCamelCase`. You can find a example configuration below:

```json
{
  "EvaluationFunctionName": "compareStringsWithLean"
}
```

### Deploy to other Platforms

## FAQ

### Pull Changes from the Template Repository

If you want to pull changes from the template repository to your repository, follow these steps:

1. Add the template repository as a remote:

```bash
git remote add template https://github.com/lambda-feedback/evaluation-function-boilerplate-lean.git
```

2. Fetch changes from all remotes:

```bash
git fetch --all
```

3. Merge changes from the template repository:

```bash
git merge template/main --allow-unrelated-histories
```

> Make sure to resolve any conflicts and keep the changes you want to keep.

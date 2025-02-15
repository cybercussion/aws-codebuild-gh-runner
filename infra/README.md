# Cloudformation Setup for Codebuild Github Runner

## Pre-requisites

1. Assumes you've installed the [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. You may need to set your default profile or export AWS_PROFILE environment variable.
3. Need to establish a codestar connection for Github (one time setup)
   1. There is not much point to use IaC for this as it has a manual action.
4. Need to authorize this with Github.
5. Need to put the ARN in SSM:Parameter Store for later use.

```bash
aws codestar-connections create-connection \
  --provider-type GitHub \
  --connection-name github-cybercussion
```

Get the ARN output from this command and use it in the next.

```bash
aws ssm put-parameter \
  --name "/github/connection/arn" \
  --type String \
  --value "arn:aws:codestar-connections:us-east-1:123456789012:connection/xyz123"

aws ssm put-parameter \
  --name "/github/connection/name" \
  --type String \
  --value "github-cybercussion"
```

## Setup Cloudformation Stack in your AWS Account(s)

1. Please edit the `parameters-accountx.json` file to match your needs.
2. Run the CLI Command OR, feel free to manually run this in AWS Console via Cloudformation UI, Create Stack etc.

```bash
aws cloudformation create-stack --stack-name github-runner-stack \
  --template-body file://infra/cloudformation/github-runner.yaml \
  --parameters file://infra/cloudformation/parameters-account1.json \
  --capabilities CAPABILITY_NAMED_IAM
```

## Setup Terraform/Terragrunt

Assuming you have [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) and [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) installed.

At the time this was done: `Terraform v1.5.7` and `terragrunt version 0.73.6`

```bash
cd infra/terraform/accounts/nonprod/shared/codebuild-github-runner
terragrunt run-all init
terragrunt run-all validate
terragrunt run-all plan
```

If all looks good you can perform `terragrunt run-all apply`

## Untested features

Labeled multi-account concepts with shortening the Github Action: `codebuild-<your runner name>-${{ github.run_id }}-${{ github.run_attempt }}`

Below can possibly register the CodeBuild runner as `self-hosted-nonprod`.

Then if you stood up one in Account 1 (nonprod) and Account 2 (prod) you could do something like:

```yaml
runs-on: ${{ github.ref_name == 'main' && 'self-hosted-prod' || 'self-hosted-nonprod' }}
# vs
runs-on: ${{ 
  github.ref_name == 'main' && 
  format('codebuild-github-runner-prod-{0}-{1}', github.run_id, github.run_attempt) || 
  format('codebuild-github-runner-nonprod-{0}-{1}', github.run_id, github.run_attempt) 
}}
```

### Concept of labeling would have to be added to Cloudformtion/Terraform

```yaml
version: 0.2
env:
  variables:
    RUNNER_LABEL: "self-hosted-nonprod"
phases:
  build:
    commands:
      - echo "Setting up GitHub Actions Runner"
      - mkdir actions-runner && cd actions-runner
      - curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.312.0/actions-runner-linux-x64-2.312.0.tar.gz
      - tar xzf actions-runner.tar.gz
      - echo "Registering Runner with GitHub"
      - GITHUB_TOKEN=$(curl -s --request POST --url "https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/runners/registration-token" --header "Authorization: token $(aws ssm get-parameter --name /github/codestar/token --with-decryption --query Parameter.Value --output text)" | jq -r .token)
      - ./config.sh --url https://github.com/${GITHUB_OWNER}/${GITHUB_REPO} --token $GITHUB_TOKEN --labels "$RUNNER_LABEL" --unattended
      - ./run.sh
```

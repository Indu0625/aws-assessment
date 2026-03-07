AWS DevOps Assessment

Multi-Region Serverless Infrastructure with Terraform

---

Overview

This project provisions a multi-region serverless AWS architecture using Terraform Infrastructure as Code (IaC).

The solution deploys identical infrastructure stacks in:

- us-east-1 (N. Virginia)
- eu-west-1 (Ireland)

Authentication is handled through a centralized Amazon Cognito User Pool, while compute services run in both regions.

The system includes:

- Multi-region Terraform deployment
- API Gateway secured by Cognito JWT authentication
- Lambda compute functions
- DynamoDB storage
- ECS Fargate container tasks
- SNS verification messaging
- CI/CD validation via GitHub Actions

---

Prerequisites

Ensure the following tools are installed before deployment.
| Tool | Version |
|-----|------|
| Terraform | >=1.5 |
| AWS CLI | >=2.x |

Configure AWS credentials:

aws configure

Required IAM permissions for deployment:

- AmazonCognitoPowerUser
- AmazonDynamoDBFullAccess
- AWSLambda_FullAccess
- AmazonAPIGatewayAdministrator
- AmazonECS_FullAccess
- AmazonSNSFullAccess

---

Architecture

Authentication is centralized in us-east-1, while compute services are deployed in both regions.

| Layer      | us-east-1 (Primary)            | eu-west-1 (Secondary)      |
|-----------|--------------------------------|----------------------------|
| Auth      | Cognito User Pool + Client     | Uses us-east-1 pool        |
| API       | API Gateway (HTTP API)         | API Gateway (HTTP API)     |
| Compute   | Lambda (Greeter + Dispatcher)  | Lambda (Greeter + Dispatcher) |
| Storage   | DynamoDB (GreetingLogs)        | DynamoDB (GreetingLogs)    |
| Container | ECS Fargate Cluster            | ECS Fargate Cluster        |
| Messaging | SNS publish                    | SNS publish                |
---

Request Flow

1️ Client authenticates with Cognito and receives a JWT token.

2 The JWT is added to the request header:
Authorization: Bearer <jwt_token>

3 Client calls the API endpoint:

GET /greet
POST /dispatch

4 API Gateway validates JWT via Cognito authorizer.

5 Lambda functions execute.

Greeter Lambda

- writes request in DynamoDB
- Publishes verification payload to SNS
- Returns executing region

Dispatcher Lambda

- Calls ECS RunTask
- ECS container publishes verification payload to SNS

---

Project Structure

aws-assessment/

├── main.tf
├── variables.tf
├── outputs.tf

├── modules/
│   └── regional_stack/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf

├── lambda/
│   ├── greeter/
│   │   └── index.js
│   └── dispatcher/
│       └── dispatcher.js

├── scripts/
│   └── test.sh

├── .github/
│   └── workflows/
│       └── terraform-ci.yml

└── README.md

---

Multi-Region Provider Setup

Two  AWS provider aliases are defined in terraform

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"
}

Modules are deployed once per region.

module "stack_us" {
  source = "./modules/regional_stack"
  providers = { aws = aws.us_east_1 }
}

module "stack_eu" {
  source = "./modules/regional_stack"
  providers = { aws = aws.eu_west_1 }
}

---

Deployment

1. Clone Repository

git clone https://github.com/Indu0625/aws-assessment
cd aws-assessment

---

2. Configure Variables

Create "terraform.tfvars" (do not commit):

email = "avulaindu096@gmail.com"
github_repo = "https://github.com/Indu0625/aws-assessment"
congnito_test_password = "yoursecurep@ss1"

---

3. Initialize Terraform

terraform init

---

4. Validate Configuration

terraform fmt -check
terraform validate

---

5. Review Plan

terraform plan -out=tfplan

---

6. Deploy Infrastructure

terraform apply tfplan

Terraform outputs API endpoints:

us_api_endpoint = https://gpr80v4dm0.execute-api.us-east-1.amazonaws.com
eu_api_endpoint = https://fxb2ynheka.execute-api.eu-west-1.amazonaws.com

---

######Running the Test Script

Bash test script is included to validate the deployment.
The script performs the following actions:
1) Authenticates with Amazon Cognito to obtain a JWT token
2) Sends requests to the /greet endpoint in both regions
3)Sends requests to the /dispatch endpoint to trigger ECS tasks
4)Verifies that the returned region matches the expected region
5)Displays request latency for both regions
6)Run the Test Script

########Make the script executable:

chmod +x scripts/test.sh
Run the script:

./scripts/test.sh

Example output:

[PASS] /greet us-east-1 → region=us-east-1
[PASS] /greet eu-west-1 → region=eu-west-1
[PASS] /dispatch us-east-1 → ECS task triggered
[PASS] /dispatch eu-west-1 → ECS task triggered

---

SNS Verification Payloads

The assessment requires SNS verification messages to be sent.

Lambda Payload

{
 "email": "avulaindu096@gmail.com",
 "source": "Lambda",
 "region": "<executing_region>",
 "repo": "https://github.com/Indu0625/aws-assessment"
}

ECS Payload

{
 "email": "avulaindu096@gmail.com",
 "source": "ECS",
 "region": "<executing_region>",
 "repo": "https://github.com/Indu0625/aws-assessment"
}

Target SNS topic:

arn:aws:sns:us-east-1:637226132752:Candidate-Verification-Topic

---

CI/CD Pipeline

A GitHub Actions pipeline validates the Terraform configuration.

Pipeline location:

.github/workflows/terraform-ci.yml

Pipeline stages:

Stage----> Description
fmt-check------> Verify Terraform formatting
init------> Initialize Terraform modules
validate------> Validate configuration syntax
checkov------> Static security scan
plan------> Generate infrastructure plan
test------> Placeholder for automated tests

---

API Reference

Endpoint            Behaviour
GET /greet          Logs request to DynamoDB and publishes SNS payload
POST /dispatch      Triggers ECS Fargate task

Both endpoints require Cognito authentication.

Authorization: Bearer <jwt_token>

---

Teardown

Destroy all infrastructure after verification to avoid AWS charges.

terraform destroy

Verify removal of:

- Cognito User Pool
- Lambda functions
- DynamoDB tables
- API Gateway APIs
- ECS clusters

---

Author

Indu Avula

GitHub
https://github.com/Indu0625/aws-assessment

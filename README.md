AWS DevOps Skill Assessment

Implementation of the AWS DevOps Skill Assessment using Terraform Infrastructure as Code, multi-region deployment, CI/CD automation, and SNS verification.

---

1. Overview

This project implements a multi-region serverless architecture on AWS using Terraform.

The infrastructure is deployed across the following AWS regions:

- us-east-1
- eu-west-1

The system exposes API endpoints through API Gateway, processes requests using AWS Lambda, logs request data to DynamoDB, and publishes verification messages to SNS as required by the assessment.

AWS Services Used

- Amazon API Gateway (HTTP API)
- AWS Lambda
- Amazon DynamoDB
- Amazon Cognito (JWT Authentication)
- Amazon SNS
- Amazon ECS Fargate
- Terraform (Infrastructure as Code)
- GitHub Actions (CI/CD)

---

2. Architecture

Each region deploys an identical infrastructure stack using Terraform modules.

System flow:

Client → API Gateway → Lambda → DynamoDB
↘ SNS Verification

Greeter Lambda

The Greeter Lambda performs the following actions:

- Logs requests into DynamoDB
- Publishes a verification message to SNS
- Returns the current AWS region

---

3. Multi-Region Deployment

Infrastructure is deployed across two regions using reusable Terraform modules.

Region| Purpose
us-east-1| Primary region
eu-west-1| Secondary region

Each region deploys:

- API Gateway
- Lambda functions
- DynamoDB table
- Cognito authorizer

---

4. API Endpoints

Terraform outputs the API Gateway endpoints after deployment.

Greet Endpoint

GET /greet

Functionality:

- Invokes the Greeter Lambda
- Logs request information to DynamoDB
- Sends SNS verification payload
- Returns the region response

Example response:

{
 "region": "us-east-1"
}

---

Dispatch Endpoint

POST /dispatch

Functionality:

- Invokes the Dispatcher Lambda
- Dispatcher triggers an ECS Fargate task
- ECS publishes verification payload to SNS

---

5. SNS Verification

As required by the assessment, verification messages are published to the SNS topic:

arn:aws:sns:us-east-1:637226132752:Candidate-Verification-Topic

Example payload:

{
 "email": "avulaindu096@gmail.com",
 "source": "Lambda",
 "region": "us-east-1",
 "repo": "https://github.com/Indu0625/aws-assessment"
}

This payload format is used for both:

- Lambda verification
- ECS verification

---

6. Terraform Structure

Project structure:

aws-assessment
│
├── main.tf
├── variables.tf
├── outputs.tf
│
├── modules
│   └── regional_stack
│       └── main.tf
│
├── lambda
│   ├── greeter
│   └── dispatcher
│
├── .github
│   └── workflows
│       └── terraform-ci.yml
│
└── README.md

The regional_stack module deploys infrastructure in each region.

---

7. CI/CD Pipeline

A GitHub Actions pipeline is included to automate infrastructure validation.

Pipeline stages:

1. Terraform format check
2. Terraform initialization
3. Terraform validation
4. Security scan using Checkov
5. Terraform plan generation
6. Test execution placeholder

Pipeline file:

.github/workflows/terraform-ci.yml

---

8. Deployment Steps

Initialize Terraform:

terraform init

Validate configuration:

terraform validate

Generate execution plan:

terraform plan

Deploy infrastructure:

terraform apply

---

9. Terraform Outputs

After deployment Terraform outputs the API Gateway endpoints.

Run:

terraform output

Example output:

us_api_endpoint = https://gpr80v4dm0.execute-api.us-east-1.amazonaws.com/greet
eu_api_endpoint = https://fxb2ynheka.execute-api.eu-west-1.amazonaws.com

These endpoints can be used to test the APIs.

---

10. Repository

GitHub Repository:

https://github.com/Indu0625/aws-assessment

---

11. Author

Indu Avula

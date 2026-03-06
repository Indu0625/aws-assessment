# AWS Serverless Infrastructure with Terraform

This repository contains Infrastructure as Code (IaC) written in **Terraform** to deploy a simple serverless architecture on AWS.  
The project demonstrates Terraform best practices along with a **CI/CD pipeline using GitHub Actions**.

---
# Architecture Overview
The infrastructure provisions the following AWS services:

- **AWS Lambda** – Serverless compute to process requests
- **Amazon API Gateway** – HTTP endpoint to trigger Lambda
- **Amazon DynamoDB** – NoSQL database for data storage

Architecture flow:

Client → API Gateway → Lambda → DynamoDB

---
Repository Structure
aws-assessment
│
├── modules/
│   └── regional_stack/
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
└── README.md
### Description

- **modules/**  
  Contains reusable Terraform modules.

- **regional_stack/**  
  Defines AWS resources like Lambda and DynamoDB.

- **.github/workflows/**  
  Contains the GitHub Actions CI/CD pipeline.

- **providers.tf**  
  Defines Terraform providers (AWS).

- **variables.tf**  
  Contains configurable input variables.

- **outputs.tf**  
  Displays Terraform output values after deployment.

---

# CI/CD Pipeline

The project includes a **GitHub Actions CI pipeline** that automatically runs when code is pushed to the **main branch**.

Pipeline file: .github/workflows/deploy.yml
---

# CI/CD Stages

### 1. Terraform Formatting Check

Ensures Terraform code follows standard formatting.
terraform fmt -check -recursive
---

### 2. Terraform Validation

Validates Terraform configuration syntax.
terraform validate
---

### 3. Security Scan

The pipeline integrates **Checkov**, an open-source security scanner for Infrastructure as Code.

Checkov scans the Terraform configuration to detect security misconfigurations.

Example checks include:

- Encryption settings
- IAM configuration
- Lambda configuration
- DynamoDB security settings

---

### 4. Terraform Plan

Generates an execution plan showing infrastructure changes.
terraform plan
For this assessment, AWS credentials are **not provided to the CI/CD runner**, so the pipeline runs the plan step in a way that does not block execution.

---

### 5. Test Execution Placeholder

The pipeline includes a placeholder step representing where automated tests would run after deployment.

Example:echo "Automated test script would run here"
---

# Running Terraform Locally

Initialize Terraform:terraform init
Validate configuration:terraform validate
Generate execution plan:terraform plan
Apply infrastructure:terraform apply
---

# Security Note

The pipeline includes a **Checkov security scan** to analyze the Terraform configuration for potential security issues.

For the purpose of this assessment, the scan runs in **soft-fail mode**, allowing the pipeline to complete while still reporting security recommendations.

---

# CI/CD Workflow

Every push to the **main branch** triggers the following pipeline:
Code Push ↓ Terraform Format Check ↓ Terraform Validate ↓ Security Scan (Checkov) ↓ Terraform Plan ↓ Test Placeholder

---

# Author

Indu



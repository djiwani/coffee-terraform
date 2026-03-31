# Four All The Dogs Cafe — Serverless AWS Infrastructure

Terraform project that provisions the complete AWS backend for a serverless coffee ordering platform. Infrastructure is fully codified and can be deployed from scratch with a single command.

## Architecture

![Architecture](https://img.shields.io/badge/AWS-Serverless-orange)

**Customer Ordering Flow**
- Static frontend hosted on S3, served globally via CloudFront with WAF protection
- Customers get temporary AWS credentials via Cognito Identity Pool (unauthenticated)
- Orders submitted to API Gateway using AWS Signature Version 4 signed requests
- Lambda processes orders, writes to DynamoDB, and publishes SNS email notifications

**Admin Dashboard Flow**
- Admins authenticate via Cognito User Pool (email/password)
- JWT token used to access protected API Gateway endpoint
- Lambda retrieves and returns all orders sorted by timestamp

## AWS Services

| Service | Purpose |
|---|---|
| API Gateway | HTTP API with IAM and JWT authorization |
| Lambda | Order processing and retrieval functions |
| DynamoDB | Order storage (PAY_PER_REQUEST billing) |
| Cognito User Pool | Admin authentication |
| Cognito Identity Pool | Guest credential vending for customers |
| SNS | Real-time email notifications on new orders |
| CloudWatch | Structured logging and error alarms |
| S3 | Static frontend hosting |
| CloudFront | CDN with HTTPS enforcement and WAF |
| IAM | Least-privilege roles and policies |

## Infrastructure

- **26 AWS resources** provisioned via Terraform
- **Two auth methods** — AWS IAM signing for customers, JWT for admins
- **CORS** handled natively at API Gateway level
- **CloudWatch alarms** integrated with SNS for error alerting

## Prerequisites

- Terraform >= 5.0
- AWS CLI configured with appropriate credentials
- Node.js Lambda functions in `lambda/` directory

## Deploy
```bash
terraform init
terraform plan
terraform apply
```

## Tear Down
```bash
terraform destroy
```

## Project Structure
```
coffee-terraform/
  main.tf          # Provider configuration
  variables.tf     # Input variables
  dynamodb.tf      # Orders table
  lambda.tf        # Lambda functions and permissions
  apigateway.tf    # HTTP API, routes, integrations, authorizer
  cognito.tf       # User Pool and Identity Pool
  iam.tf           # Roles and policies
  sns.tf           # Topic and email subscription
  outputs.tf       # API endpoint, Cognito IDs
  lambda/
    lambda-orderProcessor.js
    lambda-orderRetrieve.js
```

## Live Demo

[cafe.fourallthedogs.com](https://cafe.fourallthedogs.com)
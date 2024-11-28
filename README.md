# AWS EKS Cluster Terraform Configuration

## Overview
This project provisions an Amazon EKS (Elastic Kubernetes Service) cluster using Terraform, including VPC, subnets, IAM roles, and node groups.

## Project Structure
├── provider.tf # AWS and Kubernetes provider configurations ├── eks-cluster.tf # EKS cluster and node group definitions └── vpc.tf # VPC, subnet, and networking resources
## Prerequisites
- AWS CLI installed and configured
- Terraform >= 1.0.0
- kubectl installed
- Valid AWS credentials

## Provider Versions
- AWS Provider: ~> 5.78.0
- Kubernetes Provider: Latest version

## Quick Start
1. Initialize Terraform:
```bash
terraform init

Review planned changes:
- ``terraform plan``
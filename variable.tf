# Region variable definition
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

# Add this variable declaration
variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}
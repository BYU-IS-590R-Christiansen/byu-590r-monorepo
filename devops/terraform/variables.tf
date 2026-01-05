variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-1"
}

variable "key_name" {
  description = "Name of the AWS key pair for EC2 instance"
  type        = string
  default     = "byu-590r"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "byu-590r"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance (Ubuntu 22.04)"
  type        = string
  default     = "ami-04f34746e5e1ec0fe"
}

variable "books_dir" {
  description = "Path to the book images directory"
  type        = string
  default     = "../../backend/public/assets/books"
}

variable "environment" {
  description = "Environment name (development, production, local)"
  type        = string
  default     = "production"
}


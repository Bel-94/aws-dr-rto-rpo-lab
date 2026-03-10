terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    #code for downloading random provider
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
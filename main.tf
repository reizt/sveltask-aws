terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.44.0"
    }
  }
  required_version = ">= 1.7.5"

  cloud {
    organization = "reizt"
    workspaces {
      name = "sveltask-aws"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      application = "sveltask"
    }
  }
}

provider "aws" {
  alias = "us-east-1"

  region = "us-east-1"
  default_tags {
    tags = {
      application = "sveltask"
    }
  }
}

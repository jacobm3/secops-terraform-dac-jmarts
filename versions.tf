terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 7.32"
    }
    
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}

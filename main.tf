# ──────────────────────────────────────────────
# Provider
# ──────────────────────────────────────────────
# We use google-beta because Chronicle resources are newer and more
# stable in the beta provider. Every resource needs provider = google-beta
# since the google_ prefix defaults to the GA provider otherwise.
# Authenticates via Application Default Credentials — in CI this comes
# from the service account key or Workload Identity; locally you can
# use `gcloud auth application-default login`.

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# ──────────────────────────────────────────────
# Backend (optional — uncomment for team use)
# ──────────────────────────────────────────────
# Store Terraform state in a GCS bucket so multiple people can collaborate.
# Create the bucket first:
#   gsutil mb -p YOUR_PROJECT gs://YOUR_BUCKET
#   gsutil versioning set on gs://YOUR_BUCKET
#
# terraform {
#   backend "gcs" {
#     bucket = "my-secops-tf-state"
#     prefix = "data-tables"
#   }
# }

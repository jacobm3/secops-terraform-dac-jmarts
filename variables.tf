# ──────────────────────────────────────────────
# Required variables
# ──────────────────────────────────────────────

variable "project_id" {
  description = "The Google Cloud project ID that contains your SecOps instance."
  type        = string
}

variable "region" {
  description = "The region of your SecOps instance, for example 'us' or 'europe-west2'."
  type        = string
}

variable "instance" {
  description = "The Chronicle / SecOps instance UUID (same as your customer ID)."
  type        = string
}

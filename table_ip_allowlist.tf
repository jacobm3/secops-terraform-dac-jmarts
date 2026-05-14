# ──────────────────────────────────────────────
# Data Table: IP Allowlist
# ──────────────────────────────────────────────
# Trusted IP addresses that should not trigger alerts.
#
# To add/remove IPs, edit tables/ip_allowlist.csv — no Terraform knowledge needed.

locals {
  ip_allowlist_rows = csvdecode(file("${path.module}/tables/ip_allowlist.csv"))
}

resource "google_chronicle_data_table" "ip_allowlist" {
  provider = google-beta
  location      = var.region
  instance      = var.instance
  data_table_id = "ip_allowlist"
  description   = "Trusted IP addresses that should not trigger alerts."

  column_info {
    original_column = "ip_address"
    column_index    = 0
    column_type     = "STRING"
  }

  column_info {
    original_column = "description"
    column_index    = 1
    column_type     = "STRING"
  }

  column_info {
    original_column = "added_by"
    column_index    = 2
    column_type     = "STRING"
  }
}

resource "google_chronicle_data_table_row" "ip_allowlist" {
  provider = google-beta
  for_each = { for row in local.ip_allowlist_rows : row.ip_address => row }

  location      = var.region
  instance      = var.instance
  data_table_id = google_chronicle_data_table.ip_allowlist.data_table_id

  values = [
    each.value.ip_address,
    each.value.description,
    each.value.added_by,
  ]
}

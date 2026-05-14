# ──────────────────────────────────────────────
# Data Table: Vulnerability Priority
# ──────────────────────────────────────────────
# Maps CVEs to internal priority levels for alert triage.
#
# To update, edit tables/vuln_priority.csv.

locals {
  vuln_priority_rows = csvdecode(file("${path.module}/tables/vuln_priority.csv"))
}

resource "google_chronicle_data_table" "vuln_priority" {
  provider = google-beta
  location      = var.region
  instance      = var.instance
  data_table_id = "vuln_priority"
  description   = "Maps CVEs to internal priority levels for alert triage."

  column_info {
    original_column = "cve_id"
    column_index    = 0
    column_type     = "STRING"
  }

  column_info {
    original_column = "priority"
    column_index    = 1
    column_type     = "STRING"
  }

  column_info {
    original_column = "notes"
    column_index    = 2
    column_type     = "STRING"
  }
}

resource "google_chronicle_data_table_row" "vuln_priority" {
  provider = google-beta
  for_each = { for row in local.vuln_priority_rows : row.cve_id => row }

  location      = var.region
  instance      = var.instance
  data_table_id = google_chronicle_data_table.vuln_priority.data_table_id

  values = [
    each.value.cve_id,
    each.value.priority,
    each.value.notes,
  ]
}

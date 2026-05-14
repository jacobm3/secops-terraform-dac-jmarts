# ──────────────────────────────────────────────
# Outputs
# ──────────────────────────────────────────────

output "ip_allowlist_table_name" {
  description = "Full resource name of the IP allowlist data table."
  value       = google_chronicle_data_table.ip_allowlist.name
}

output "vuln_priority_table_name" {
  description = "Full resource name of the vulnerability priority data table."
  value       = google_chronicle_data_table.vuln_priority.name
}

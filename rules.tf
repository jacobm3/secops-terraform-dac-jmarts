# ──────────────────────────────────────────────
# Detection Rules
# ──────────────────────────────────────────────
# Each rule has two parts:
#   1. A .yl2 file in rules/  — the actual detection logic (YARA-L).
#   2. An entry in the map below — deployment settings.
#
# To add a rule:
#   1. Write your YARA-L file in rules/my_rule.yl2
#   2. Add an entry to the map below.
#
# To edit detection logic:
#   Just edit the .yl2 file and open a PR.
#
# To disable a rule without deleting it:
#   Set enabled = false in the map below.

locals {
  rules = {

    dac_login_from_blocked_country = {
      file      = "rules/login_from_blocked_country.yl2"
      enabled   = false
      alerting  = false
    }

    dac_brute_force_login = {
      file      = "rules/brute_force_login.yl2"
      enabled   = false
      alerting  = false
    }

    # ── Add new rules here ──────────────────────
    #
    # my_new_rule = {
    #   file      = "rules/my_new_rule.yl2"
    #   enabled   = true
    #   alerting  = true
    # }

  }
}

# ──────────────────────────────────────────────
# Rule definitions — creates the rule in Chronicle
# ──────────────────────────────────────────────

resource "google_chronicle_rule" "rules" {
  provider = google-beta
  for_each = local.rules

  location = var.region
  instance = var.instance
  text     = file("${path.module}/${each.value.file}")
}

# Workaround: the Chronicle API has a propagation delay after rule creation.
# Without this pause, rule_deployment fails with "Root object was present,
# but now absent". This is a known provider bug.
resource "time_sleep" "wait_for_rules" {
  depends_on      = [google_chronicle_rule.rules]
  create_duration = "60s"
}

# ──────────────────────────────────────────────
# Rule deployments — controls whether the rule is live
# ──────────────────────────────────────────────

resource "google_chronicle_rule_deployment" "rules" {
  provider   = google-beta
  for_each   = local.rules
  depends_on = [time_sleep.wait_for_rules]

  location = var.region
  instance = var.instance
  rule     = google_chronicle_rule.rules[each.key].rule_id
  enabled  = each.value.enabled
  alerting = each.value.alerting
}

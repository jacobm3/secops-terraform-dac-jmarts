# Google SecOps Detection as Code - Terraform

## Data Tables

Manage [Google Security Operations (SecOps) data tables](https://docs.cloud.google.com/chronicle/docs/investigation/data-tables) as code using Terraform.

Data tables are multicolumn lookup tables you can populate with your own data inside Google SecOps.
They let you enrich, filter, and correlate events in YARA-L rules. This repo keeps your table
definitions and their row data in version control, with CI/CD that plans on every PR and applies on
merge.

## YARA-L (YL2) detection rules

This repo also manages your [YARA-L 2.0](https://cloud.google.com/chronicle/docs/detection/yara-l-2-0-overview)
detection rules as code. YARA-L is the detection language used by Google SecOps to match patterns across
normalized event data — single-event or multi-event correlation, time windows, and lookups into the
data tables defined above. Rule source files live in `rules/` with a `.yl2` extension, and `rules.tf`
controls per-rule deployment settings (enabled, alerting). The same PR workflow that plans/applies
table changes also covers rules: edit a `.yl2` file, open a PR, merge to deploy. See
[Adding a detection rule](#adding-a-detection-rule) below.

## Repository layout

```
.
├── main.tf                 # Provider configuration
├── variables.tf            # Input variables (project, region, instance)
├── terraform.tfvars.example# Copy to terraform.tfvars and fill in your values
├── table_ip_allowlist.tf   # One table_*.tf file per data table
├── table_vuln_priority.tf
├── tables/                 # One CSV per table — the actual row data
│   ├── ip_allowlist.csv
│   └── vuln_priority.csv
├── rules.tf                # Rule config map + deployment settings
├── rules/                  # One .yl2 file per detection rule
│   ├── dac_login_from_blocked_country.yl2
│   └── dac_brute_force_login.yl2
├── outputs.tf              # Useful outputs
├── versions.tf             # Terraform & provider version pins
├── .github/
│   └── workflows/
│       ├── plan.yml        # Runs `terraform plan` on PRs
│       └── apply.yml       # Runs `terraform apply` when PR merges
└── examples/               # Snippets showing how to add your own tables
    └── add_a_table.tf.example
```

## Prerequisites

1. A Google Cloud project with the Chronicle API enabled.
2. A Google SecOps instance (you need the instance UUID — the "customer ID").
3. A GCP service account with **Chronicle Editor** (`roles/chronicle.editor`) or an
   equivalent custom role that includes `chronicle.dataTables.*` permissions.
4. Workload Identity Federation **or** a service account key configured as a
   GitHub Actions secret (see below).

## Quick start (local)

```bash
# 1. Clone
git clone <this-repo-url> && cd terraform-secops-data-tables

# 2. Set your variables
cp terraform.tfvars.example terraform.tfvars
#    edit terraform.tfvars — fill in project, region, instance

# 3. Authenticate
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/sa-key.json
#    or use: gcloud auth application-default login

# 4. Init + plan
terraform init
terraform plan

# 5. Apply
terraform apply
```

## Adding a new data table

1. Create a CSV file in `tables/` with a header row matching your column names.
   For example, `tables/my_table.csv`:
   ```
   hostname,environment,owner
   web-01,production,sre-team
   db-02,staging,platform-team
   ```
2. Create a `table_*.tf` file in the repo root that defines the table schema
   and loops over the CSV. Copy `examples/add_a_table.tf.example` as a
   starting point.
3. Open a pull request — GitHub Actions will run `terraform plan` and post the
   diff as a PR comment.
4. Get the PR reviewed and approved.
5. Merge — GitHub Actions runs `terraform apply` automatically.

**To update existing rows**, just edit the CSV and open a PR. No Terraform
knowledge needed — the plan output will show exactly which rows are added,
changed, or removed.

## Adding a detection rule

1. Write your YARA-L rule in `rules/my_rule.yl2`.
2. Add an entry to the `local.rules` map in `rules.tf`:
   ```hcl
   my_rule = {
     file      = "rules/my_rule.yl2"
     enabled   = true
     alerting  = true
   }
   ```
3. Open a PR, review the plan, merge.

**To edit rule logic**, just edit the `.yl2` file. To **disable a rule**
without removing it, set `enabled = false` in the map.

## GitHub Actions setup

The workflows need these **repository secrets** (Settings → Secrets and variables → Actions):

| Secret | Description |
|---|---|
| `GCP_PROJECT_ID` | Your Google Cloud project ID |
| `GCP_SA_KEY` | Base64-encoded service account JSON key **or** use Workload Identity Federation (see below) |
| `SECOPS_INSTANCE` | Your SecOps / Chronicle instance UUID |
| `SECOPS_REGION` | Region for your instance, e.g. `us` |

### Using Workload Identity Federation (recommended)

If you prefer keyless auth, replace the auth step in both workflows with
[google-github-actions/auth](https://github.com/google-github-actions/auth)
and remove the `GCP_SA_KEY` secret. The workflows include a commented-out
example for this.

## Terraform state

By default state is stored locally. For a real team you should enable a
[GCS backend](https://developer.hashicorp.com/terraform/language/backend/gcs).
Uncomment the `backend "gcs"` block in `main.tf` and create the bucket first.

## Reference docs

- [Google SecOps data tables overview](https://docs.cloud.google.com/chronicle/docs/investigation/data-tables)
- [Terraform: google_chronicle_datatable](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/chronicle_datatable)
- [Terraform: google_chronicle_datatable_row](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/chronicle_datatable_row)
- [SecOps Terraform landing page](https://cloud.google.com/chronicle/docs/terraform)

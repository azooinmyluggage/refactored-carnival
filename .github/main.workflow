workflow "New workflow" {
  on = "push"
  resolves = ["./.github/azure_assign"]
}

action "./.github/azure_deploy" {
  uses = "./.github/azure_deploy"
  args = "pulkit a garwal"
  secrets = ["SAMPLE_SECRET"]
}

action "./.github/azure_assign" {
  uses = "./.github/azure_assign"
  needs = ["./.github/azure_deploy"]
  secrets = ["SAMPLE_SECRET"]
  args = "$SAMPLE_SECRET"
}

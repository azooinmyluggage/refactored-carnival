workflow "New workflow" {
  on = "push"
  resolves = ["./.github/azure_deploy"]
}

action "./.github/azure_deploy" {
  uses = "./.github/azure_deploy"
  args = "pulkit agarwal"
}

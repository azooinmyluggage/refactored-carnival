workflow "New workflow" {
  on = "push"
  resolves = ["./.github/azure_deploy"]
}

action "GitHub Action for Azure" {
  uses = "actions/azure@b3ba9e7"
  env = {
    AZURE_SERVICE_APP_ID = "9cb1a03d-4a31-455b-9d33-96766bc41b91"
    AZURE_SERVICE_PASSWORD = "yu37/hzVLQ+BMK053a7x8/Y/uXjuW7oZqOplGbMFOrI="
    AZURE_SERVICE_TENANT = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  }
  args = "--version "
}

action "./.github/azure_deploy" {
  needs = ["GitHub Action for Azure"]
  uses = "./.github/azure_deploy"
  args = "pulkit agarwal"
}

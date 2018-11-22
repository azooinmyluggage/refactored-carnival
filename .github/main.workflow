workflow "Build and Deploy to Azure AKS" {
  resolves = [
    "Azure/github-actions/arm@master",
    "Push to Container Registry",
  ]
  on = "pull_request"
}

action "Login - Container Registry" {
  uses = "actions/docker/login@6495e70"
  env = {
    DOCKER_REGISTRY_URL = "githubactions.azurecr.io"
    DOCKER_USERNAME = "githubactions"
  }
  secrets = ["DOCKER_PASSWORD"]
}

action "Build container image" {
  uses = "actions/docker/cli@6495e70"
  args = "build -t githubactions ."
  needs = [
    "Login - Container Registry",
  ]
}

action "Tag image" {
  uses = "actions/docker/tag@6495e70"
  args = "githubactions githubactions.azurecr.io/githubactions"
  needs = ["Build container image"]
}

action "Push to Container Registry" {
  uses = "actions/docker/cli@6495e70"
  args = "push githubactions.azurecr.io/githubactions:latest"
  needs = ["Tag image"]
}

action "Azure/github-actions/arm@master" {
  uses = "Azure/github-actions/arm@master"
  needs = ["Push to Container Registry"]
  env = {
    AZURE_RESOURCE_GROUP = "githubactionrg"
    AZURE_TEMPLATE_LOCATION = "githubactionstemplate.json"
    AZURE_TEMPLATE_PARAM_FILE = "githubparameters.json"
  }
}

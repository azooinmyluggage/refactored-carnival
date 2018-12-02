workflow "GH Actions for Azure" {
  resolves = [
    "Deploy to Azure WebappContainer",
    "Push to Container Registry",
    "Azure Login",
  ]
  on = "push"
}

action "Login Registry" {
  uses = "actions/docker/login@6495e70"
  env = {
    DOCKER_REGISTRY_URL = "githubactionsacr.azurecr.io"
    DOCKER_USERNAME = "githubactionsacr"
  }
  secrets = ["DOCKER_PASSWORD"]
}

action "Build container image" {
  uses = "actions/docker/cli@6495e70"
  args = "build -t githubactionsacr.azurecr.io/githubactions ."
  needs = ["Login Registry"]
}

action "Tag image" {
  uses = "actions/docker/tag@6495e70"
  args = "githubactionsacr.azurecr.io/githubactions githubactionsacr.azurecr.io/githubactions"
  needs = ["Build container image"]
}

action "Push to Container Registry" {
  uses = "actions/docker/cli@6495e70"
  args = "push githubactionsacr.azurecr.io/githubactions"
  needs = ["Tag image"]
}

action "Azure Login" {
  uses = "Azure/github-actions/azure-login@master"
  needs = ["Push to Container Registry"]
  env = {
    AZURE_SUBSCRIPTION = "RMPM"
    AZURE_SERVICE_TENANT = "72f988bf-86f1-41af-91ab-2d7cd011db47"
    AZURE_SERVICE_APP_ID = "0c508c6b-533a-47a8-a7df-ec8d6481792a"
  }
  secrets = ["AZURE_SERVICE_PASSWORD"]
}

action "Create WebappContainers" {
  uses = "Azure/github-actions/arm@1922d68686a21f7f96e6911bd0daec0eaad0c06d"
  env = {
    AZURE_RESOURCE_GROUP = "githubactionrg"
    AZURE_TEMPLATE_LOCATION = "githubactionstemplate.json"
    AZURE_TEMPLATE_PARAM_FILE = "githubparameters.json"
  }
  needs = ["Azure Login"]
}

action "Deploy to Azure WebappContainer" {
  uses = "Azure/github-actions/web-app-container@master"
  env = {
    CONTAINER_IMAGE_NAME = "githubactions"
    AZURE_APP_NAME = "ga-webapp"
    DOCKER_REGISTRY_URL = "githubactionsacr.azurecr.io"
    DOCKER_USERNAME = "githubactionsacr"
  }
  needs = ["Create WebappContainers"]
}

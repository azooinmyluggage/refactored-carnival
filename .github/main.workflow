workflow "GH Actions for Azure" {
  resolves = [
    "Deploy to Azure WebappContainer",
    "Push to Container Registry",
    "Azure/github-actions/aks@master",
  ]
  on = "push"
}

action "Login Registry" {
  uses = "actions/docker/login@6495e70"
  env = {
    DOCKER_USERNAME = "aksactionacr"
    DOCKER_REGISTRY_URL = "aksactionacr.azurecr.io"
  }
  secrets = ["DOCKER_PASSWORD"]
}

action "Build container image" {
  uses = "actions/docker/cli@6495e70"
  args = "build -t aksactionacr.azurecr.io/aksaction ."
  needs = ["Login Registry"]
}

action "Tag image" {
  uses = "actions/docker/tag@6495e70"
  args = "aksactionacr.azurecr.io/aksaction aksactionacr.azurecr.io/aksaction"
  needs = ["Build container image"]
}

action "Push to Container Registry" {
  uses = "actions/docker/cli@6495e70"
  args = "push aksactionacr.azurecr.io/aksaction"
  needs = ["Tag image"]
}

action "Azure Login" {
  uses = "Azure/github-actions/login@master"
  needs = ["Push to Container Registry"]
  env = {
    AZURE_SUBSCRIPTION = "RMPM"
    AZURE_SERVICE_TENANT = "72f988bf-86f1-41af-91ab-2d7cd011db47"
    AZURE_SERVICE_APP_ID = "1d05d3c7-d015-4c23-a3b6-59813ca41b6d"
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
  uses = "Azure/github-actions/containerwebapp@master"
  env = {
    AZURE_APP_NAME = "ga-webapp"
    CONTAINER_IMAGE_NAME = "aksaction"
    DOCKER_REGISTRY_URL = "aksactionacr.azurecr.io"
    DOCKER_USERNAME = "aksactionacr"
  }
  needs = ["Create WebappContainers"]
}

action "Azure/github-actions/aks@master" {
  uses = "Azure/github-actions/aks@master"
  needs = ["Azure Login"]
  env = {
    DOCKER_REGISTRY_URL = "aksactionacr.azurecr.io"
    AKS_CLUSTER_NAME = "aksactioncluster"
    CONTAINER_IMAGE_NAME = "aksaction"
    DOCKER_USERNAME = "aksactionacr"
  }
}

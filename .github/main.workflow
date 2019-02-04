workflow "GH Actions for Azure" {
  resolves = [
    "Deploy to Azure WebappContainer",
    "Azure/github-actions/aks@master",
    "Azure/github-actions/releasepipelines@master",
  ]
  on = "push"
}

action "Login Registry" {
  uses = "actions/docker/login@6495e70"
  env = {
    DOCKER_USERNAME = "actionacr"
    DOCKER_REGISTRY_URL = "actionacr.azurecr.io"
  }
  secrets = ["DOCKER_PASSWORD"]
}

action "Build container image" {
  uses = "actions/docker/cli@6495e70"
  args = "build -t actionacr.azurecr.io/actionacr ."
  needs = ["Login Registry"]
}

action "Tag image" {
  uses = "actions/docker/tag@6495e70"
  args = "actionacr.azurecr.io/actionacr actionacr.azurecr.io/actionacr:$GITHUB_SHA"
  needs = ["Build container image"]
}

action "Push to Container Registry" {
  uses = "actions/docker/cli@6495e70"
  args = "push actionacr.azurecr.io/actionacr"
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
    DOCKER_REGISTRY_URL = "actionacr.azurecr.io"
    DOCKER_USERNAME = "actionacr"
    CONTAINER_IMAGE_NAME = "actionacr"
  }
  needs = ["Create WebappContainers"]
}

action "Azure/github-actions/aks@master" {
  uses = "Azure/github-actions/aks@master"
  needs = ["Azure Login"]
  secrets = ["DOCKER_PASSWORD"]
  env = {
    AKS_CLUSTER_NAME = "actionk8s"
    DOCKER_REGISTRY_URL = "actionacr.azurecr.io"
    DOCKER_USERNAME = "actionacr"
    CONTAINER_IMAGE_NAME = "actionacr.azurecr.io/actionacr"
    CONTAINER_IMAGE_TAG = "${GITHUB_SHA}"
  }
}

action "Azure/github-actions/releasepipelines@master" {
  uses = "Azure/github-actions/releasepipelines@master"
  needs = ["Push to Container Registry"]
  env = {
    AZURE_PIPELINE_NAME = "New release pipeline"
    AZURE_PIPELINE_PROJECT = "actionsplkt"
    AZURE_PIPELINE_ORGANIZATION = "pulkit-agarwal"
  }
  secrets = ["AZURE_PIPELINE_TOKEN"]
}

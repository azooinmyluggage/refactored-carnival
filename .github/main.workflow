workflow "Azure Actions " {
  resolves = [
    "Deploy to Azure WebappContainer",
    "Azure/github-actions/aks-deploy@master",
    "Azure/github-actions/aks-deploy@master-1",
    "Deploy to Functionapp Container",
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
    AZURE_SERVICE_APP_ID = "0a60f5e2-ed4a-4cfd-bfe2-1b45e6d97c9e"
    AZURE_SERVICE_TENANT = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  }
  secrets = ["AZURE_SERVICE_PASSWORD"]
}

action "Create WebappContainers" {
  uses = "Azure/github-actions/arm@master"
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
  secrets = ["DOCKER_PASSWORD"]
}

action "Azure/github-actions/aks-deploy@master" {
  uses = "Azure/github-actions/aks-deploy@master"
  needs = ["Azure Login"]
  env = {
    CONTAINER_IMAGE_NAME = "githubactions:latest"
    AKS_CLUSTER_NAME = "githubactions"
    HELM_RELEASE_NAME = "githubservice-azlogin"
  }
}

action "Azure/github-actions/aks-deploy@master-1" {
  uses = "Azure/github-actions/aks-deploy@master"
  needs = ["Push to Container Registry"]
  secrets = ["DOCKER_PASSWORD", "KUBE_CONFIG_DATA"]
  env = {
    HELM_RELEASE_NAME = "githubservice"
    CONTAINER_IMAGE_NAME = "githubactions:latest"
    DOCKER_REGISTRY_URL = "githubactionsacr.azurecr.io"
    DOCKER_USERNAME = "githubactionsacr"
  }
}

action "Create functionapp" {
  uses = "Azure/github-actions/arm@master"
  needs = ["Azure Login"]
  env = {
    AZURE_RESOURCE_GROUP = "githubactionrg"
    AZURE_TEMPLATE_LOCATION = "functiontemplate.json"
    AZURE_TEMPLATE_PARAM_FILE = "functionparameters.json"
  }
}

action "Deploy to Functionapp Container" {
  uses = "Azure/github-actions/function-app-container@master"
  needs = ["Create functionapp"]
  secrets = ["DOCKER_PASSWORD"]
  env = {
    AZURE_APP_NAME = "ga-functionapp"
    DOCKER_USERNAME = "githubactionsacr"
    DOCKER_REGISTRY_URL = "githubactionsacr.azurecr.io"
    CONTAINER_IMAGE_NAME = "githubactions"
  }
}

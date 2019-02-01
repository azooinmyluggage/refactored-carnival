workflow "GH Actions for Azure" {
  resolves = [
    "Azure AKS Deploy",
  ]
  on = "push"
}

action "Login Registry" {
  uses = "actions/docker/login@6495e70"
  env = {
    DOCKER_USERNAME = "aksdemoactionacr"
    DOCKER_REGISTRY_URL = "aksdemoactionacr.azurecr.io"
  }
  secrets = ["DOCKER_PASSWORD"]
}

action "Build container image" {
  uses = "actions/docker/cli@6495e70"
  args = "build -t aksdemoactionacr.azurecr.io/aksdemoactionacr1 ."
  needs = ["Login Registry"]
}

action "Tag image" {
  uses = "actions/docker/tag@6495e70"
  args = "aksdemoactionacr.azurecr.io/aksdemoactionacr1:latest aksdemoactionacr.azurecr.io/aksdemoactionacr1"
  needs = ["Build container image"]
}

action "Push to Container Registry" {
  uses = "actions/docker/cli@6495e70"
  args = "push aksdemoactionacr.azurecr.io/aksdemoactionacr1"
  needs = ["Tag image"]
}

action "Azure Login - 2" {
  uses = "Azure/github-actions/login@master"
  needs = ["Push to Container Registry"]
  env = {
    AZURE_SUBSCRIPTION = "RMDev"
    AZURE_SERVICE_TENANT = "72f988bf-86f1-41af-91ab-2d7cd011db47"
    AZURE_SERVICE_APP_ID = "dab4e54f-dbf1-42f7-acce-44fc3ccc8a89"
    AZURE_SERVICE_PASSWORD = "ba9f8e84-a016-4157-827c-1265593262ce"
  }
}

action "Azure AKS Deploy" {
  uses = "Azure/github-actions/aks@master"
  needs = ["Azure Login - 2"]
  secrets = ["DOCKER_PASSWORD"]
  env = {
    DOCKER_REGISTRY_URL = "aksdemoactionacr.azurecr.io"
    DOCKER_USERNAME = "aksdemoactionacr"
    CONTAINER_IMAGE_NAME = "aksdemoactionacr.azurecr.io/aksdemoactionacr1"
    AKS_CLUSTER_NAME = "desattirtest"
  }
}

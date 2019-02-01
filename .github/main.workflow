workflow "GH Actions for Azure" {
  resolves = [
    "Azure AKS Deploy",
  ]
  on = "push"
}

action "Azure Login - 2" {
  uses = "Azure/github-actions/login@master"
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
    CONTAINER_IMAGE_NAME = "aksdemoactionacr.azurecr.io/aksdemoactionacr"
    AKS_CLUSTER_NAME = "desattirtest"
  }
}

workflow "Build and Deploy to Azure AKS" {
  resolves = ["Deploy to AKS"]
  on = "commit_comment"
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
  args = "githubactions:latest githubactions.azurecr.io/githubactions:latest"
  needs = ["Build container image"]
}

action "Push to Container Registry" {
  uses = "actions/docker/cli@6495e70"
  args = "push githubactions.azurecr.io/githubactions:latest"
  needs = ["Tag image"]
}



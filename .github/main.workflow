workflow "New workflow" {
  on = "push"
  resolves = ["GitHub Action for Docker"]
}

action "Docker Registry" {
  uses = "actions/docker/login@6495e70"
  env = {
    DOCKER_USERNAME = "azureactions"
    DOCKER_PASSWORD = "paSSw0rd12#$"
  }
}

action "GitHub Action for Docker" {
  needs = ["Docker Registry"]
  uses = "actions/docker/cli@6495e70"
  args = "pull hello-world"
}

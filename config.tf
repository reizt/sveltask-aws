# Local Variables
locals {
  app                 = "sveltask"
  region              = "ap-northeast-1"
  ecr_repository_name = "sveltask-app"
  domain_name         = "todo.reizt.dev"

  gha = {
    user_name = "reizt"
    repo_name = "sveltask-app"
  }
}

terraform {
  backend "remote" {
    organization = "tomakabe"

    workspaces {
      name = "dev"
    }
  }
}

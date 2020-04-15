terraform {
  backend "remote" {
    organization = "tomakabe"

    workspaces {
      name = "aks-eval"
    }
  }
}

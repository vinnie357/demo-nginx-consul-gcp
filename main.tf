terraform {
  # backend "remote" {
  # The name of your Terraform Cloud organization.
  # organization = "vinnief5dev"

  #  # The name of the Terraform Cloud workspace to store Terraform state files in.
  #  workspaces {
  #    name = "demo-nginx-consul"
  #  }
  #}
}

# provider
provider "google" {
  project = var.gcpProjectId
  region  = var.gcpRegion
  zone    = var.gcpZone
}

# project
resource "random_pet" "buildSuffix" {
  keepers = {
    prefix = var.projectPrefix
  }
  length    = 2
  separator = "-"
}

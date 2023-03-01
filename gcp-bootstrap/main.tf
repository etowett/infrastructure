terraform {
  required_version = ">= 1.3.7, < 2.0.0"

  backend "gcs" {
    bucket = "super001-gapps-tf-state"
    prefix = "platform"
  }
}

provider "google" {
  project = "gapps-platform"
}

locals {
  stages = [
    "stage",
  ]
  projects = { for s in local.stages : s => "cx-gapps-${s}" }
}

module "projects" {
  source   = "../modules/project_factory"
  for_each = local.projects

  name  = each.value
  stage = each.key
}

output "projects" {
  value = module.projects
}

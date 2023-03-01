terraform {
  required_version = ">= 1.3.7, < 2.0.0"

  backend "gcs" {
    bucket                      = "super001-cx-gapps-stage-tf-state"
    impersonate_service_account = "cx-gapps-stage-cicd-sa@cx-gapps-stage-cicd-8wg1.iam.gserviceaccount.com"
  }
}

provider "google" {
  impersonate_service_account = local.cicd_sa
  project                     = local.project_id
}

locals {
  env                = "stage"
  region             = "europe-west1"
  project_id         = "cx-gapps-stage-8wg1"
  cicd_sa            = "cx-gapps-stage-cicd-sa@cx-gapps-stage-cicd-8wg1.iam.gserviceaccount.com"
  private_cidr_range = "10.20.0.0/24"
  public_cidr_range  = "10.20.1.0/24"
  repos = {
    starfish-run = {
      name     = "goquizbox"
      filename = "/deploy/cb-cloudrun.yaml"
    }
    loaning-gke = {
      name     = "goquizbox"
      filename = "/deploy/cb-gke.yaml"
    }
    apisim-gke = {
      name     = "apisim"
      filename = "/deploy/cb/gke.yaml"
    }
    comms-gke = {
      name     = "comms"
      filename = "/deploy/cb/gke.yaml"
    }
  }
}

module "network" {
  source = "../../modules/network"

  env                = local.env
  region             = local.region
  private_cidr_range = local.private_cidr_range
  public_cidr_range  = local.public_cidr_range
}

output "network" {
  value = module.network
}

module "gke" {
  source = "../../modules/gke"

  env                = local.env
  region             = local.region
  name               = "comms"
  network_name       = module.network.name
  public_subnet_name = module.network.public_subnet_name
  machine_type       = "n1-standard-2"
}

output "gke" {
  value = module.gke
}

module "postgres" {
  source = "../../modules/cloudsql"

  env        = local.env
  region     = local.region
  name       = "comms"
  db_version = "POSTGRES_14"
  db_tier    = "db-custom-1-3840"
  authorized_networks = [
    {
      name  = "allow-all-inbound"
      value = "0.0.0.0/0"
    },
  ]
  network_id  = module.network.id
  db_name     = "super001"
  db_user     = "root"
  db_password = "xxxxx"
}

output "postgres" {
  value = module.postgres
}

module "redis" {
  source = "../../modules/redis"

  env            = local.env
  region         = local.region
  name           = "comms"
  network_id     = module.network.id
  memory_size_gb = 4
}

output "redis" {
  value = module.redis
}

resource "google_secret_manager_secret" "secret" {
  secret_id = "github-machine-credentials"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret-version" {
  secret = google_secret_manager_secret.secret.id

  secret_data = "eutychus:xxxxx"
}

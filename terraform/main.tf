terraform {
  required_providers {
    clevercloud = {
      source  = "CleverCloud/clevercloud"
      version = "1.0.1"
    }
  }
  backend "s3" {
    bucket                      = "lucas-backends-terraform"
    key                         = "cleverPoll/state/terraform.tfstate"
    region                      = "sbg" # Random us region not used for ovh backend
    endpoints                   = { s3 = "https://s3.sbg.io.cloud.ovh.net" }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_path_style              = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "clevercloud" {
  token        = var.token
  secret       = var.secret
  endpoint     = var.endpoint
  organisation = var.organisation
}

resource "clevercloud_postgresql" "postgresql_database" {
  region = "par"
  name   = "tf-cleverPoll-PSQL"
  plan   = "xxs_sml"
}

resource "clevercloud_redis" "redis_database" {
  region = "par"
  name   = "tf-cleverPoll-redis"
  plan   = "s_mono"
}

resource "clevercloud_nodejs" "frontend" {
  name               = "tf-cleverPoll-frontend"
  region             = "par"
  min_instance_count = 1
  max_instance_count = 2
  smallest_flavor    = "pico"
  biggest_flavor     = "S"
  environment = {
    "NODE_ENV" = "production",
  }
  deployment {
    repository = "https://github.com/Lucas-atabey/cleverPool-frontend.git"
  }
}

resource "clevercloud_python" "backend" {
  name               = "tf-cleverPoll-backend"
  region             = "par"
  min_instance_count = 1
  max_instance_count = 2
  python_version     = "3"
  smallest_flavor    = "pico"
  biggest_flavor     = "S"
  environment = {
    "ADMIN_PASSWORD"     = var.admin_password,
    "ADMIN_USER"         = var.admin_user,
    "CC_POST_BUILD_HOOK" = "clevercloud/post-build",
    "CC_PYTHON_MODULE"   = "run:app",
    "CC_PYTHON_VERSION"  = "3",
    "WSGI_WORKERS"       = "4",
    "WSGI_THREADS"       = "2",
    "HARAKIRI"           = "120",
    "SECRET_KEY"         = var.secret_key
  }
  dependencies = [
    clevercloud_postgresql.postgresql_database.id,
    clevercloud_redis.redis_database.id
  ]
  deployment {
    repository = "https://github.com/Lucas-atabey/cleverPool-backend.git"
  }
  depends_on = [clevercloud_postgresql.postgresql_database, clevercloud_redis.redis_database, clevercloud_nodejs.frontend]
}

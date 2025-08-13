variable "token" {
  description = "Clever cloud consumer key for authentication"
  type        = string
  sensitive   = true
}

variable "secret" {
  description = "Clever cloud consumer secret for authentication"
  type        = string
  sensitive   = true
}

variable "endpoint" {
  description = "Clever cloud API endpoint"
  type        = string
  sensitive   = true
}

variable "organisation" {
  description = "Clever cloud organisation name"
  type        = string
  sensitive   = true
}

variable "admin_user" {
  description = "Admin user for the backend"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the backend"
  type        = string
}

variable "secret_key" {
  description = "Secret key for the backend"
  type        = string
  sensitive   = true
}

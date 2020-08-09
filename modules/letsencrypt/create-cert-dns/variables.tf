variable "dns_provider" {
  type = string
  default = "route53"
}

variable "domains" {
  type = list(string)
}

variable "subject_alternative_names" {
  description = "List of alternative names"
  type = map(string)
  default = {}
}

variable "count_certs" {
  description = "Number of certificates to create."
  default = 1
}

variable "server_url" {
  default = "production"
}

variable "server_urls" {
  type = map(string)
  default = {
    "staging" = "https://acme-staging-v02.api.letsencrypt.org/directory"
    "production" = "https://acme-v02.api.letsencrypt.org/directory"
  }
}

variable "reg_email" {
  default = "nobody@example.com"
}

variable "key_type" {
  default = 4096
}

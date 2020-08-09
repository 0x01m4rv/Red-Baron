variable "domain" {}

variable "type" {}

variable "count_records" {
  description = "Number of records to add."
  default = 1
}

variable "ttl" {
  default = 300
}

variable "records" {
  type = map(string)
}

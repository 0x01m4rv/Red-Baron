/*
variable "count_vm" {
  default = 1
}
*/

variable "tags" {
  type = map(string)
  default = {}
}

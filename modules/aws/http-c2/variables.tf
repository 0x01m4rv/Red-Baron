variable "subnet_id" {}

variable "vpc_id" {}

variable "count_vm" {
  default = 1
}

variable "ansible_playbook" {
  default = ""
  description = "Ansible Playbook to run"
}

variable "ansible_arguments" {
  default = []
  type    = list(string)
  description = "Additional Ansible Arguments"
}

variable "ansible_vars" {
  default = []
  type    = list(string)
  description = "Environment variables"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "install" {
  type = list(string)
  default = []
}

/*
variable "install" {
  type = map(string)
  default = {
    "empire" = "./data/scripts/install_empire.sh"
    "metasploit" = "./data/scripts/install_metasploit.sh"
    "cobaltstrike" = "./data/scripts/install_cobalt_strike.sh"
  }
}
*/

variable "amis" {
  type = map(string)
  default = {

    // Taken from https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
    /*
    "ap-northeast-1" = "ami-b6b568d0"
    "ap-northeast-2" = "ami-b7479dd9"
    "ap-south-1" = "ami-02aded6d"
    "ap-southeast-1" = "ami-d76019b4"
    "ap-southeast-2" = "ami-8359bae1"
    "ca-central-1" = "ami-3709b053"
    "eu-central-1" = "ami-8bb70be4"
    "eu-west-1" = "ami-ce76a7b7"
    "eu-west-2" = "ami-a6f9ebc2"
    "sa-east-1" = "ami-f5c7b899"
    "us-east-1" = "ami-71b7750b"
    "us-east-2" = "ami-dab895bf"
    "us-west-1" = "ami-58eedd38"
    "us-west-2" = "ami-c032f6b8"
    */

    // Taken from https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
    /*
    "af-south-1"     = "ami-051f6d21720ab0921"
    "ap-east-1"      = "ami-0234df4580db96359"
    "ap-northeast-1" = "ami-09ae668c1b0b21584"
    "ap-northeast-2" = "ami-01035dd3d1c0390df"
    "ap-south-1"     = "ami-02bca44cea7019243"
    "ap-southeast-1" = "ami-0b095a60a51b2f382"
    "ap-southeast-2" = "ami-05d83a37058be6303"
    "ca-central-1"   = "ami-0eb661106633d453a"
    "eu-central-1"   = "ami-0d22e47f4c8d6bdeb"
    "eu-north-1"     = "ami-0922c9ee3634eaeb2"
    "eu-south-1"     = "ami-0526a6053ac93c947"
    "eu-west-1"      = "ami-0442db6463774080a"
    "eu-west-2"      = "ami-026d8fce12c6274d4"
    "eu-west-3"      = "ami-08f6dee157dd2c33a"
    "me-south-1"     = "ami-04cdc7375fa8556d3"
    "sa-east-1"      = "ami-0601c44f0dcd08170"
    "us-east-1"      = "ami-0fa7bfda343e69030"
    "us-east-2"      = "ami-01d0a26bb43892d21"
    "us-west-1"      = "ami-08154b65d822f9429"
    "us-west-2"      = "ami-072ad3956e05c814c"
    */

    // Taken from https://wiki.debian.org/Cloud/AmazonEC2Image/Buster
    "af-south-1"     = "ami-0e43803b2c4e176b0"
    "ap-east-1"      = "ami-f1165680"
    "ap-northeast-1" = "ami-025e5dec754f6ddbd"
    "ap-northeast-2" = "ami-080768259c09cb7a0"
    "ap-south-1"     = "ami-0004bf05a2432c350"
    "ap-southeast-1" = "ami-066eeae61f083f121"
    "ap-southeast-2" = "ami-068211b3bc5e0d179"
    "ca-central-1"   = "ami-0867d05b02eed78f4"
    "eu-central-1"   = "ami-04989b617bd4f8f95"
    "eu-north-1"     = "ami-0e0ed860953d90a95"
    "eu-south-1"     = "ami-04347f7257091e950"
    "eu-west-1"      = "ami-019745dc682c2e518"
    "eu-west-2"      = "ami-07ba0e1e1d5b872b9"
    "eu-west-3"      = "ami-000311a1d85fc1ede"
    "me-south-1"     = "ami-0385afb25760d5fc2"
    "sa-east-1"      = "ami-023b6b51ea301d07c"
    "us-east-1"      = "ami-0c24eddbea3a65909"
    "us-east-2"      = "ami-0806f7fe82d5b1455"
    "us-west-1"      = "ami-00ddd725492165b87"
    "us-west-2"      = "ami-01f29bf534f24ebd2"
  }
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "allow_cidr" {
  type = list(string)
  description = "List of CIDR addresses to allow, e.g. your and your colleagues IP addresses, use /32 for a single IP"
}

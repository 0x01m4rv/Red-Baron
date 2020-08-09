terraform {
  required_version = ">= 0.11.0"
}

data "external" "get_public_ip" {
  program = ["bash", "./data/scripts/get_public_ip.sh" ]
}

resource "aws_security_group" "http-c2" {
  name = "http-c2"
  description = "Security group created by Red Baron"
  vpc_id = var.vpc_id
  tags = var.tags

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    //cidr_blocks = ["${data.external.get_public_ip.result["ip"]}/32"]
    cidr_blocks = var.allow_cidr
  }
  ingress {
    from_port = 80
    to_port = 83
    protocol = "tcp"
    /*
    cidr_blocks = ["${linode_linode.http-rdir-1.ip_address}/32",
                   "${linode_linode.http-rdir-2.ip_address}/32", 
                   "${linode_linode.http-rdir-3.ip_address}/32", 
                   "${var.my_ip}/32"]
    */
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 444
    protocol = "tcp"
    /*
    cidr_blocks = ["${linode_linode.http-rdir-1.ip_address}/32",
                   "${linode_linode.http-rdir-2.ip_address}/32", 
                   "${linode_linode.http-rdir-3.ip_address}/32", 
                   "${var.my_ip}/32"]
    */

    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 60000
    to_port = 61000
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Cobalt Strike Team Server"
    from_port = 50050
    to_port   = 50050
    protocol  = "tcp"
    cidr_blocks = var.allow_cidr
  }
  ingress {
    description = "Metasploit / CS Implants"
    from_port   = 4444
    to_port     = 4454
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "Metasploit / CS Implants 2"
    from_port   = 5555
    to_port     = 5565
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 53
    to_port = 53
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "hkp"
    from_port = 11371
    to_port = 11371
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "ICMP Echo Request (Ping)"
    from_port   = "8" # ICMP Type 8 (Echo Request)
    to_port     = "8" # ICMP Type 8 (Echo Request)
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

terraform {
  required_version = ">= 0.11.0"
}

data "aws_region" "current" {}

resource "random_id" "server" {
  count = var.count_vm
  byte_length = 4
}

/*
resource "tls_private_key" "ssh" {
  count = var.count_vm
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "http-rdir" {
  count = var.count_vm
  key_name = "http-rdir-key-${count.index}"
  public_key = tls_private_key.ssh.*.public_key_openssh[count.index]
  tags = var.tags
}
*/

resource "aws_instance" "http-rdir" {
  // Currently, variables in provider fields are not supported :(
  // This severely limits our ability to spin up instances in diffrent regions
  // https://github.com/hashicorp/terraform/issues/11578

  //provider = "aws.${element(var.regions, count.index)}"

  count = var.count_vm

  tags = merge( var.tags, {
    Name = "http-rdir-${var.name}-${random_id.server.*.hex[count.index]}"
  })
  /*
  volume_tags = merge( var.tags, {
    Name = "http-rdir-${var.name}-${random_id.server.*.hex[count.index]}"
  })
  */

  ami = var.amis[data.aws_region.current.name]
  instance_type = var.instance_type
  //key_name = aws_key_pair.http-rdir.*.key_name[count.index]
  key_name = var.key_name
  vpc_security_group_ids = ["${aws_security_group.http-rdir.id}"]
  subnet_id = var.subnet_id
  associate_public_ip_address = true

  user_data = templatefile("data/cloud-init/http-rdir.yml", { name = var.name, index = count.index })

  /*
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.ssh.*.private_key_pem[count.index]}\" > ./data/ssh_keys/${self.public_ip} && echo \"${tls_private_key.ssh.*.public_key_openssh[count.index]}\" > ./data/ssh_keys/${self.public_ip}.pub && chmod 600 ./data/ssh_keys/*"
  }

  provisioner "local-exec" {
    when = destroy
    command = "rm ./data/ssh_keys/${self.public_ip}*"
  }
  */

}

resource "null_resource" "remote_provisioner" {
  count = var.count_vm

  triggers = {
    instance_creation = aws_instance.http-rdir.*.id[count.index]
    /*
    install = join(",", var.install)
    policy_sha1 = jsonencode({
      for script in concat(list("./data/scripts/core_deps.sh"), var.install):
        script => sha1(file(script))
    })
    */
  }

  provisioner "file" {
    source      = "data/files/terminfo"
    destination = "/tmp/terminfo"

    connection {
      host = aws_instance.http-rdir.*.public_ip[count.index]
      type = "ssh"
      user = "admin"
      #private_key = tls_private_key.ssh.*.private_key_pem[count.index]
    }
  }

  provisioner "remote-exec" {
    inline = [
      # fucking debian nothing works!
      #"set -euxo pipefail",
      "set -eux",
      "sudo apt-get update",
      "sudo apt-get install -y tmux socat apache2 rsync mosh",
      "sudo a2enmod rewrite proxy proxy_http ssl",
      "sudo systemctl stop apache2",
      # done by cloud-init
      #"sudo hostnamectl set-hostname http-rdir-${var.name}-${count.index}",
      #"sudo sed -i -e 's/^127.0.0.1 localhost$/127.0.0.1 localhost http-rdir-${var.name}-${count.index}/' /etc/hosts || true",
      "sudo mv /tmp/terminfo/* /etc/terminfo/",
      "echo \"#!/bin/sh\\nsudo socat TCP4-LISTEN:80,fork,reuseaddr TCP4:${element(var.redirect_to, count.index)}:80\" > socat-80.sh",
      "echo \"#!/bin/sh\\nsudo socat TCP4-LISTEN:443,fork,reuseaddr TCP4:${element(var.redirect_to, count.index)}:443\" > socat-443.sh",
      "echo \"#!/bin/sh\\ntmux new -d -s \\\"http-rdir-${var.name}-${count.index}\\\" \\\"./socat-80.sh\\\" ';' split \\\"./socat-443.sh\\\"\" >> tmux-socat.sh",
      "chmod +x socat-80.sh socat-443.sh tmux-socat.sh",
      "./tmux-socat.sh"
    ]

    connection {
        host = aws_instance.http-rdir.*.public_ip[count.index]
        type = "ssh"
        user = "admin"
        #private_key = tls_private_key.ssh.*.private_key_pem[count.index]
    }
  }


}
resource "null_resource" "ansible_provisioner" {
  count = signum(length(var.ansible_playbook)) == 1 ? var.count_vm : 0

  depends_on = [aws_instance.http-rdir]

  triggers = {
    droplet_creation = join("," , aws_instance.http-rdir.*.id)
    policy_sha1 = sha1(file(var.ansible_playbook))
  }

  provisioner "local-exec" {
    command = "ansible-playbook ${join(" ", compact(var.ansible_arguments))} --user=admin --private-key=./data/ssh_keys/${aws_instance.http-rdir.*.public_ip[count.index]} -e host=${aws_instance.http-rdir.*.public_ip[count.index]} ${var.ansible_playbook}"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "ssh_config" {

  count    = var.count_vm

  template = file("./data/templates/ssh_config.tpl")

  # Unnecessary, vars has implicit dependencies
  # Best to avoid explicit dependencies, Terraform #21545 #17034
  #depends_on = [aws_instance.http-rdir]

  vars = {
    #name = "http_rdir_${aws_instance.http-rdir.*.public_ip[count.index]}"
    name = "http_rdir_${var.name}-${count.index}"
    hostname = aws_instance.http-rdir.*.public_ip[count.index]
    user = "admin"
    #identityfile = "${path.root}/data/ssh_keys/${aws_instance.http-rdir.*.public_ip[count.index]}"
  }

}

resource "null_resource" "gen_ssh_config" {

  count = var.count_vm

  triggers = {
    template_rendered = data.template_file.ssh_config.*.rendered[count.index]
    server = random_id.server.*.hex[count.index]
    file_name = "./data/ssh_configs/config_http_rdir_${var.name}-${count.index}"
  }

  provisioner "local-exec" {
    #command = "echo '${data.template_file.ssh_config.*.rendered[count.index]}' > ./data/ssh_configs/config_${random_id.server.*.hex[count.index]}"
    command = "echo '${data.template_file.ssh_config.*.rendered[count.index]}' > ${self.triggers.file_name}"
  }

  provisioner "local-exec" {
    when = destroy
    #command = "rm ./data/ssh_configs/config_${self.triggers.server}"
    command = "rm ${self.triggers.file_name}"
  }

}

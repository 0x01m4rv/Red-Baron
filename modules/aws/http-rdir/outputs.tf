output "instance_ids" {
  value = aws_instance.http-rdir.*.id
}

output "ips" {
  value = aws_instance.http-rdir.*.public_ip
}

output "ssh_user" {
  value = "admin"
}

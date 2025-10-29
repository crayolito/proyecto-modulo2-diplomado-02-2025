output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "IP pública de la instancia"
  value       = aws_instance.main.public_ip
}

output "security_group_id" {
  description = "ID del security group"
  value       = aws_security_group.ec2_sg.id
}

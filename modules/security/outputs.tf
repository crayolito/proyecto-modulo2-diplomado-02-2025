output "ec2_role_arn" {
  description = "ARN del rol IAM para EC2"
  value       = aws_iam_role.ec2_role.arn
}

output "instance_profile_name" {
  description = "Nombre del instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "secure_security_group_id" {
  description = "ID del security group seguro"
  value       = aws_security_group.secure_ec2_sg.id
}

output "waf_arn" {
  description = "ARN del WAF"
  value       = aws_wafv2_web_acl.main.arn
}

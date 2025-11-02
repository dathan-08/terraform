output "elastic_ip" {
  description = "Elastic IP Address"
  value       = aws_eip.two_tier_eip.public_ip
}

output "app_url" {
  description = "Application URL (Flask)"
  value       = "http://${aws_eip.two_tier_eip.public_ip}:8080"
}
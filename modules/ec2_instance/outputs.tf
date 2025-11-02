output "Public-ip-address" {
  value = aws_instance.example.public_ip
}

output "app_url" {
  description = "Application URL (Flask)"
  value       = "http://${aws_instance.example.public_ip}:8080"
}
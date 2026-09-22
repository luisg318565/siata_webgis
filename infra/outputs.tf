output "instance_public_ip" {
  description = "IP publica de la instancia EC2"
  value       = aws_instance.siata_server.public_ip
}

output "geovisor_url" {
  description = "URL del geovisor web"
  value       = "http://${aws_instance.siata_server.public_ip}/"
}

output "backend_docs_url" {
  description = "URL de la documentacion del backend"
  value       = "http://${aws_instance.siata_server.public_ip}:8000/docs"
}

output "geoserver_url" {
  description = "URL de administracion de GeoServer"
  value       = "http://${aws_instance.siata_server.public_ip}:8080/geoserver/web/"
}
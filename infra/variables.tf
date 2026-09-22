variable "aws_region" {
  description = "Region de AWS donde se despliega la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "Nombre del key pair de EC2 para acceso SSH"
  type        = string
}

variable "geoserver_admin_password" {
  description = "Contraseña de administrador de GeoServer"
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "Contraseña de la base de datos PostgreSQL"
  type        = string
  sensitive   = true
}
terraform {
  required_providers {
    docker = { source = "kreuzwerker/docker" }
    aws    = { source = "hashicorp/aws" }
    time   = { source = "hashicorp/time" }
  }
}

provider "docker" {}

# 1. Contenedor Floci (Mock de S3)
resource "docker_image" "floci" {
  name = "floci/floci:latest"
}

resource "docker_container" "floci" {
  name  = "floci"
  image = docker_image.floci.image_id
  ports {
    internal = 4566
    external = 4566
  }
}

# Espera a que Floci termine de arrancar antes de crear el bucket
resource "time_sleep" "esperar_floci" {
  depends_on      = [docker_container.floci]
  create_duration = "10s"
}

# 2. Proveedor AWS apuntando a Floci
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true
  endpoints {
    s3 = "http://localhost:4566"
  }
}

# 3. Bucket S3 en Floci
resource "aws_s3_bucket" "b" {
  bucket     = "cloudstudy"
  depends_on = [time_sleep.esperar_floci]
}

# 4. Subida de archivos estáticos del sitio
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.b.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  etag         = filemd5("${path.module}/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "conceptos" {
  bucket       = aws_s3_bucket.b.id
  key          = "conceptos.html"
  source       = "${path.module}/conceptos.html"
  etag         = filemd5("${path.module}/conceptos.html")
  content_type = "text/html"
}

resource "aws_s3_object" "contacto" {
  bucket       = aws_s3_bucket.b.id
  key          = "contacto.html"
  source       = "${path.module}/contacto.html"
  etag         = filemd5("${path.module}/contacto.html")
  content_type = "text/html"
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.b.id
  key          = "css/style.css"
  source       = "${path.module}/css/style.css"
  etag         = filemd5("${path.module}/css/style.css")
  content_type = "text/css"
}

# Output para ver el sitio directo
output "website_url" {
  value = "http://localhost:4566/cloudstudy/index.html"
}

# CloudStudy - TP Cloud Computing

Sitio web estático alojado en un bucket **S3 simulado con Floci** (contenedor **Docker**),
desplegado como código con **Terraform**.

## Estructura

```
.
├── main.tf          # Terraform: contenedor Floci + bucket S3 + archivos del sitio
├── index.html
├── conceptos.html
├── contacto.html
└── css/style.css
```

## Requisitos

- Docker (Docker Desktop abierto y corriendo)
- Terraform

## Cómo desplegarlo

```bash
terraform init
terraform apply      # escribir "yes" cuando lo pida
```

Al terminar, abrir en el navegador: <http://localhost:4566/cloudstudy/index.html>

> Si el `apply` falla con un error de conexión, esperar unos segundos y volver a ejecutar `terraform apply`.

Para borrar todo (contenedor y bucket):

```bash
terraform destroy
```

## Qué hace el main.tf

1. Descarga y levanta el contenedor `floci/floci` en el puerto 4566 (simula AWS S3).
2. Configura el proveedor AWS apuntando a `http://localhost:4566` con credenciales de prueba.
3. Crea el bucket `cloudstudy`.
4. Sube `index.html`, `conceptos.html`, `contacto.html` y `css/style.css` al bucket.
5. Muestra la URL del sitio como `output`.

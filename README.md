# Reto DevOps

## 1. Descripción del proyecto

Implementación de una aplicación REST desarrollada con Java y Spring Boot, 
contenerizada con Docker y desplegada en AWS ECS Fargate mediante un pipeline CI/CD automatizado con GitHub Actions.

La infraestructura se administra utilizando Terraform y el estado se almacena remotamente en Amazon S3.

## 2. Tecnologías utilizadas

- Java 17 y Spring Boot
- Maven
- Docker
- Amazon Elastic Container Registry (ECR)
- Amazon Elastic Container Service (ECS Fargate)
- AWS IAM y autenticación OIDC
- Amazon VPC y Security Groups
- Amazon CloudWatch Logs
- Amazon S3
- Terraform
- Git y GitHub
- GitHub Actions

## 3. Arquitectura de la solución

El flujo de despliegue es el siguiente:

1. El desarrollador publica cambios en la rama `main` de GitHub.
2. GitHub Actions ejecuta el pipeline CI/CD.
3. GitHub Actions obtiene credenciales temporales de AWS mediante OIDC.
4. Docker construye la imagen de la aplicación.
5. La imagen se publica en Amazon ECR.
6. Se registra una nueva revisión de la definición de tarea de ECS.
7. Amazon ECS Fargate actualiza el servicio con la nueva imagen.
8. La aplicación queda disponible mediante su endpoint HTTP.

La infraestructura de AWS se define con Terraform y utiliza un backend remoto en S3 para almacenar el estado.

## 4. Endpoint de la aplicación

**Método:  GET

**Ruta: `/hola`

**Puerto: `8080`

Ejemplo de respuesta:

```json
{
  "aplicacion": "reto-examen",
  "mensaje": "Hola Mundo desde BanBif",
  "estado": "correcto"
}
```

La IP pública corresponde a la tarea ECS en ejecución y puede cambiar cuando se reemplaza la tarea.

## 5. Ejecución local con Docker

Construir la imagen:

```bash
docker build -t reto-examen:1.0 .
```

Ejecutar el contenedor:

```bash
docker run --rm -p 8081:8080 reto-examen:1.0
```

Probar la aplicación:

```text
http://localhost:8081/hola
```

## 6. Infraestructura como código

La carpeta `terraform/` contiene la configuración de infraestructura de AWS.

Comandos principales:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

La infraestructura incluye un clúster ECS, servicio Fargate, definición de tarea, VPC, subred pública, 
configuración de red, grupo de seguridad, rol IAM de ejecución y registros de CloudWatch.

El estado de Terraform se administra mediante un backend remoto en Amazon S3 con versionado habilitado.

## 7. Integración y despliegue continuo

El workflow se encuentra en:

```text
.github/workflows/deploy.yml
```

El pipeline se ejecuta al publicar cambios en `main` y también permite ejecuciones manuales.

Sus principales etapas son:

1. Descargar el código fuente.
2. Autenticarse en AWS mediante OIDC.
3. Iniciar sesión en Amazon ECR.
4. Construir y publicar la imagen Docker.
5. Obtener la definición actual de tarea ECS.
6. Actualizar la imagen del contenedor.
7. Desplegar la nueva revisión en ECS Fargate.
8. Esperar la estabilización del servicio.

## 8. Seguridad

- Autenticación de GitHub Actions mediante OIDC.
- Uso de credenciales temporales en lugar de claves AWS permanentes en el workflow.
- Control de acceso mediante roles y políticas IAM.
- Configuración del acceso al contenedor mediante Security Groups.
- Exclusión de archivos locales y sensibles mediante `.gitignore`.

## 9. Validación del despliegue

Se verificó satisfactoriamente:

- Ejecución del pipeline de GitHub Actions.
- Publicación de la imagen en Amazon ECR.
- Actualización del servicio ECS.
- Ejecución de una tarea Fargate.
- Respuesta HTTP del endpoint `/hola`.
- Consistencia de la infraestructura mediante `terraform plan`.

## 10. Consideraciones

La arquitectura implementada corresponde a un entorno de demostración técnica. Utiliza una subred pública y acceso HTTP al puerto 8080.

Para un entorno productivo se recomienda incorporar HTTPS, un Application Load Balancer, múltiples zonas de disponibilidad y controles de seguridad adicionales.

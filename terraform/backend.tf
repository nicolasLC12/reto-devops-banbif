
terraform {
  backend "s3" {
    bucket       = "reto-banbif-terraform-state-161987605856"
    key          = "reto-examen/terraform.tfstate"
    region       = "us-east-1"
    profile      = "reto-banbif"
    encrypt      = true
    use_lockfile = true
  }
}

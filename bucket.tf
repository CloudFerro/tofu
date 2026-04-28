module "bucket" {
  source = "./modules/bucket"

  bucket = var.bucket

  ec2_credential_count      = var.ec2_credential_count
  ec2_credential_project_id = var.ec2_credential_project_id
  ec2_credential_user_id    = var.ec2_credential_user_id
  ec2_credential_region     = var.ec2_credential_region
}

resource "openstack_objectstorage_container_v1" "bucket" {
  region             = var.bucket.region
  name = var.bucket.name
  container_read     = var.bucket.container_read
  container_sync_to  = var.bucket.container_sync_to
  container_sync_key = var.bucket.container_sync_key
  container_write    = var.bucket.container_write
  metadata           = var.bucket.metadata
  content_type       = var.bucket.content_type
  storage_policy     = var.bucket.storage_policy
  force_destroy      = var.bucket.force_destroy
}

resource "openstack_identity_ec2_credential_v3" "ec2_credentials" {
  count = var.ec2_credential_count

  region     = var.ec2_credential_region
  project_id = var.ec2_credential_project_id
  user_id    = var.ec2_credential_user_id
}

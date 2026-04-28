output "bucket" {
  description = "Created object storage container."
  value = {
    id     = openstack_objectstorage_container_v1.bucket.id
    name   = openstack_objectstorage_container_v1.bucket.name
    region = openstack_objectstorage_container_v1.bucket.region
  }
}

output "ec2_credentials" {
  description = "Created EC2 credential pairs (access + secret). Marked sensitive."
  value = [
    for cred in openstack_identity_ec2_credential_v3.ec2_credentials : {
      access     = cred.access
      secret     = cred.secret
      user_id    = cred.user_id
      project_id = cred.project_id
    }
  ]
  sensitive = true
}

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.4.0"
    }

    null = {
    source  = "hashicorp/null"
    version = ">= 3.2.1"
    }
  }
}


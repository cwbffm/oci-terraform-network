provider "oci" {
  auth                = "APIKey"
  region              = var.region
  config_file_profile = var.config_file_profile
}

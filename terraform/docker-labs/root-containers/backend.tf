terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://minio.thein3rovert.dev"
    }
    bucket                      = "terraform-state"
    key                         = "root-container/terraform.tfstate"
    region                      = "eu-central-1"
    
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style             = true
  }
}

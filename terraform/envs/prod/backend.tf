terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://s3.thein3rovert.dev"
    }
    bucket                      = "terraform-state"
    key                         = "terraform/prod/terraform.tfstate"
    region                      = "garage"
    
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style             = true
  }
}

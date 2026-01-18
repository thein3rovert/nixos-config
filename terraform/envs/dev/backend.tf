terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://s3.thein3rovert.dev"
    }
    bucket = "thein3rovert-bucket"
    key    = "terraform-state/dev/terraform-state.tfstate"
    region = "garage"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

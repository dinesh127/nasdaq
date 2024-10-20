terraform {
  backend "s3" {
    bucket         = "dini-dev-tf-state-bucket"
    key            = "tfstatefile/nasdaq/terraform.tfstate"
    region         = "us-east-2"  # Replace with your bucket's region
    encrypt        = true
  }
}

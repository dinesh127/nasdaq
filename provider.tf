provider "aws" {
  alias  = "singapore"
  region = var.region_singapore
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "aws" {
  alias  = "ireland"
  region = var.region_ireland
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

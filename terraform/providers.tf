provider "aws" {
  region = "us-east-1" # Primary
}

provider "aws" {
  alias  = "west"
  region = "us-west-2" # Secondary
}

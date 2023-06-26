module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "images"
  hash_key = "email"
  range_key = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    },
    {
      name = "email"
      type = "S"
    },
    ## The below are in the table but do not need to be declared here
    # {
    #   name = "image_location"
    #   type = "S"
    # },
    # {
    #   name = "score"
    #   type = "N"
    # },
    # {
    #   name = "data"
    #   type = "S"
    # }
  ]

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}
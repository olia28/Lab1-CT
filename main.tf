module "course" {
    source = "./modules/dynamoDB"
    name = "courses"
    table_name = "courses"
    hash_key = "id"
}

module "author" {
    source = "./modules/dynamoDB"
    name = "authors"
    table_name = "authors"
    hash_key = "id"
}

module "IAM" {
  source                = "./modules/IAM"
  name                  = "IAM"
  dynamoDB_authors_arn = module.author.dynamoDB_arn
  dynamoDB_courses_arn = module.course.dynamoDB_arn
}
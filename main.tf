module "course" {
    source = "./modules/dynamodb"
    name = "courses"
    table_name = "courses"
    hash_key = "id"
}

module "author" {
    source = "./modules/dynamodb"
    name = "authors"
    table_name = "authors"
    hash_key = "id"
}

module "iam" {
  source                = "./modules/iam"
  name                  = "iam"
  dynamodb_authors_arn = module.author.dynamodb_arn
  dynamodb_courses_arn = module.course.dynamodb_arn
}

module "lambda" {
    source = "./modules/lambda"
    name   = "lamda"
    stage  = "dev"

    get_all_authors_arn = module.iam.get_all_authors_role_arn
    save_course_arn     = module.iam.save_course_role_arn
    update_course_arn   = module.iam.update_course_role_arn
    get_all_courses_arn = module.iam.get_all_courses_role_arn
    get_one_course_arn  = module.iam.get_one_course_role_arn
    delete_course_arn   = module.iam.delete_course_role_arn
}
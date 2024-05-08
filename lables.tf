module "label" {
  source   = "cloudposse/label/null"
  version = "0.25.0"

  namespace  = var.namespace
  stage      = var.stage
  environment = var.environment
  label_order = var.label_order
}

module "label_front_application" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.label.context

  name = "front-application"

  tags = {
    Name = local.tag_name
  }

}
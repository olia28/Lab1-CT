#API 
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "my api"
  description = "API example with CORS."
}

#courses
resource "aws_api_gateway_resource" "courses" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "courses"
}

#authors
resource "aws_api_gateway_resource" "authors" {
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  path_part = "authors"
  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_method" "get_authors" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = aws_api_gateway_resource.authors.id
  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_integration" "get_authors" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.get_authors.http_method
  integration_http_method = "POST"
  type = "AWS"
  uri = var.get_all_authors_invoke_arn
  request_parameters = {"integration.request.header.X-Authorization" = "'static'"}
  request_templates = {
    "application/xml" = <<EOF
  {
     "body" : $input.json('$')
  }
  EOF
  }
  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_method_response" "get_authors" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.get_authors.http_method
  status_code = "200"
  response_models = { "application/json" = "Empty" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration" "authors_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.authors.id
  http_method             = aws_api_gateway_method.authors_options.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  # request_templates = {
  #   "application/json" = "{\"statusCode\": 200}"
  # }

  uri = var.get_all_authors_invoke_arn

  depends_on = [ aws_api_gateway_method.authors_options ]
}

resource "aws_api_gateway_integration_response" "authors_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.authors_options.http_method
  status_code = aws_api_gateway_method_response.authors_options_response.status_code

  response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }

    depends_on = [
     aws_api_gateway_method_response.authors_options_response
    ]
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.get_authors,
    aws_api_gateway_integration.get_courses,
  ]


  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name = "dev"
}

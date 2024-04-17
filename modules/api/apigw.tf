#API 
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "my api"
  description = "API example with CORS."
}


#courses
resource "aws_api_gateway_resource" "courses" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "courses"
}

# GET COURSES

resource "aws_api_gateway_method" "get_courses" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_courses" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.get_courses.http_method
  integration_http_method = "POST"
  type = "AWS"
  uri = var.get_all_courses_invoke_arn
  
  request_parameters  = {"integration.request.header.X-Authorization" = "'static'"}

     request_templates       = {
    "application/xml" = <<EOF
  {
     "body" : $input.json('$')
  }
  EOF
  }
  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_method_response" "get_courses" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.get_courses.http_method
  status_code = "200"

  response_models = { "application/json" = "Empty" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}


resource "aws_api_gateway_integration_response" "get_courses" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.get_courses.http_method
  status_code = aws_api_gateway_method_response.get_courses.status_code

response_templates = {
  "application/xml" = <<EOF
  {
     "body" : $input.json('$')
  }
  EOF
}


  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_lambda_permission" "api_gateway_invoke_courses" {
  statement_id  = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = var.get_all_courses_arn
  principal = "apigateway.amazonaws.com"
}

# Додавання методу OPTIONS для /courses
resource "aws_api_gateway_method" "courses_options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "courses_options_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.courses_options.http_method
  status_code = "200"

   response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
   }

   depends_on = [ aws_api_gateway_method.courses_options ]
}
# Прикріплення методу OPTIONS до ресурсу /authors
resource "aws_api_gateway_integration" "courses_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.courses_options.http_method
  integration_http_method = "POST"
  type = "AWS"
  # request_templates = {
  #   "application/json" = "{\"statusCode\": 200}"
  # }

  uri = var.get_all_courses_invoke_arn

  depends_on = [ aws_api_gateway_method.courses_options ]
}

resource "aws_api_gateway_integration_response" "courses_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.courses_options.http_method
  status_code = aws_api_gateway_method_response.courses_options_response.status_code

  response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }

    depends_on = [
     aws_api_gateway_method_response.courses_options_response
    ]
}


# COURSES POST 

resource "aws_api_gateway_model" "my_api" {
  rest_api_id  = aws_api_gateway_rest_api.my_api.id
  name = "mymodel"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = jsonencode({
    "$schema": "http://json-schema.org/schema#",
    "title": "json_courses",
    "type": "object",
    "properties": {
      "authorId": {"type": "string"},
      "duration": {"type": "string"},
      "title": {"type": "string"}
    },
    "required": ["authorId", "duration", "title",]
  })
}

resource "aws_api_gateway_request_validator" "my_api" {
  name = "POSTExampleRequestValidator"
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  validate_request_body = true
  validate_request_parameters = false
}

resource "aws_api_gateway_method" "post_courses" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "POST"
  authorization = "NONE"
request_validator_id = aws_api_gateway_request_validator.my_api.id

  request_models = {
    "application/json" = aws_api_gateway_model.my_api.name
  }
}

resource "aws_api_gateway_method_response" "post_courses" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.post_courses.http_method
  status_code = "200"

  response_models = { "application/json" = "Empty" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration" "post_courses" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.post_courses.http_method
  integration_http_method = "POST"
  type = "AWS"
  uri = var.save_course_invoke_arn
  
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



resource "aws_api_gateway_integration_response" "post_courses" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.post_courses.http_method
  status_code = aws_api_gateway_method_response.post_courses.status_code

response_templates = {
  "application/xml" = <<EOF
  {
     "body" : $input.json('$')
  }
  EOF
}


  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_lambda_permission" "api_gateway_invoke_post_courses" {
  statement_id  = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = var.save_course_arn
  principal = "apigateway.amazonaws.com"
}





# COURSE BY ID

resource "aws_api_gateway_resource" "course_by_id" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_resource.courses.id
  path_part = "{id}"
}

resource "aws_api_gateway_method" "get_course" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = "GET"
  authorization = "NONE"
  request_validator_id = aws_api_gateway_request_validator.my_api.id
}

resource "aws_api_gateway_method_response" "get_course" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.get_course.http_method
  status_code = "200"

  response_models = { "application/json" = aws_api_gateway_model.my_api.name }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration" "get_course" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.get_course.http_method
  integration_http_method = "POST"
  type = "AWS"
  uri = var.get_one_course_invoke_arn
  
  request_parameters = {"integration.request.header.X-Authorization" = "'static'"}

request_templates = {
  "application/json" = <<EOF
{
  "id": "$input.params('id')"
}
EOF
}

  content_handling = "CONVERT_TO_TEXT"
}



resource "aws_api_gateway_integration_response" "get_course" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.get_course.http_method
  status_code = aws_api_gateway_method_response.get_course.status_code

response_templates = {
  "application/json" = <<EOF
{
  "body" : $input.json('$')
}
EOF
}

  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_lambda_permission" "api_gateway_invoke_get_course" {
  statement_id  = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = var.get_one_course_arn
  principal = "apigateway.amazonaws.com"
}



#  METHOD PUT for /courses/{id}
resource "aws_api_gateway_method" "put_method" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "put" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.put_method.http_method
  integration_http_method = "POST"
  type = "AWS"
  uri = var.save_course_invoke_arn
  
  request_parameters      = {"integration.request.header.X-Authorization" = "'static'"}

     request_templates = {
      "application/xml" = <<EOF
        {
          "id": "$input.params('id')",
          "authorId": "$input.params('$.authorId')",
          "duration": "$input.params('$.duration')",
          "title": "$input.params('$.title')"
        }
      EOF
    }

  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_method_response" "put" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.put_method.http_method
  status_code = "200"

  response_models = { "application/json" = "Empty" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "put" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.put_method.http_method
  status_code = aws_api_gateway_method_response.put.status_code

  response_templates = {
    "application/xml" = <<EOF
    {
      "body" : $input.json('$')
    }
    EOF
  }

  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_lambda_permission" "api_gateway_invoke_put_course" {
  statement_id  = "AllowAPIGatewayInvokePUTLambda"
  action        = "lambda:InvokeFunction"
  function_name = var.save_course_arn
  principal     = "apigateway.amazonaws.com"
}



# DELETE 

resource "aws_api_gateway_method" "delete" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = "DELETE"
  authorization = "NONE"
  request_validator_id = aws_api_gateway_request_validator.my_api.id
}

resource "aws_api_gateway_method_response" "delete_course" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.delete.http_method
  status_code = "200"

  response_models = { "application/json" = aws_api_gateway_model.my_api.name }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration" "delete_course" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.delete.http_method
  integration_http_method = "POST"
  type = "AWS"
  uri = var.delete_course_invoke_arn
  
  request_parameters      = {"integration.request.header.X-Authorization" = "'static'"}

  request_templates = {
    "application/json" = <<EOF
      {
        "id": "$input.params('id')"
      }
    EOF
  }

  content_handling = "CONVERT_TO_TEXT"
}



resource "aws_api_gateway_integration_response" "delete_course" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.delete.http_method
  status_code = aws_api_gateway_method_response.delete_course.status_code

response_templates = {
  "application/json" = <<EOF
{
  "body" : $input.json('$')
}
EOF
}

  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_lambda_permission" "api_gateway_invoke_delete_course" {
  statement_id  = "AllowAPIGatewayInvokeDeleteLambda"
  action        = "lambda:InvokeFunction"
  function_name = var.delete_course_arn
  principal     = "apigateway.amazonaws.com"
}

# OPTIONS FOR ID

resource "aws_api_gateway_method" "id_options" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.course_by_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "id_options_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.id_options.http_method
  status_code = "200"

   response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
   }

   depends_on = [ aws_api_gateway_method.id_options ]
}

resource "aws_api_gateway_integration" "id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.id_options.http_method
  integration_http_method = "POST"
  type = "AWS"

  uri = var.get_one_course_invoke_arn

  depends_on = [ aws_api_gateway_method.id_options ]
}


resource "aws_api_gateway_integration_response" "id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.course_by_id.id
  http_method = aws_api_gateway_method.id_options.http_method
  status_code = aws_api_gateway_method_response.id_options_response.status_code

  response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }

    depends_on = [
     aws_api_gateway_method_response.id_options_response,
     aws_api_gateway_integration.id_options_integration
    ]
}

#authors

resource "aws_api_gateway_resource" "authors" {
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "authors"
  rest_api_id = aws_api_gateway_rest_api.my_api.id
}

resource "aws_api_gateway_method" "get_authors" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.authors.id
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
}

resource "aws_api_gateway_integration" "get_authors" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.get_authors.http_method
  integration_http_method = "POST"
  type = "AWS"
  uri = var.get_all_authors_invoke_arn
  
  request_parameters      = {"integration.request.header.X-Authorization" = "'static'"}

     request_templates       = {
    "application/xml" = <<EOF
  {
     "body" : $input.json('$')
  }
  EOF
  }
  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_method_response" "get_authors" {
  rest_api_id     = aws_api_gateway_rest_api.my_api.id
  resource_id     = aws_api_gateway_resource.authors.id
  http_method     = aws_api_gateway_method.get_authors.http_method
  status_code     = "200"
  response_models = { "application/json" = "Empty" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "get_authors" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.get_authors.http_method
  status_code = aws_api_gateway_method_response.get_authors.status_code

   # Transforms the backend JSON response to XML
   response_templates = {
     "application/xml" = <<EOF
   {
      "body" : $input.json('$')
   }
   EOF
  }
  response_parameters ={
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.get_all_authors_arn
  principal     = "apigateway.amazonaws.com"
}

# OPTIONS for /authors
resource "aws_api_gateway_method" "authors_options" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.authors.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Відповідь для методу OPTIONS
resource "aws_api_gateway_method_response" "authors_options_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.authors_options.http_method
  status_code = "200"

   response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
   }

   depends_on = [ aws_api_gateway_method.authors_options ]
}
# Прикріплення методу OPTIONS до ресурсу /authors
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


# Прикріплення відповіді до методу OPTIONS
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

provider "aws" {
  region = "eu-west-1"
}

resource "aws_lambda_function" "hello_clj" {
  function_name = "hello-lambda-clj"

  filename         = "../target/hello-lambda-clj.jar"
  source_code_hash = "${base64sha256(file("../target/hello-lambda-clj.jar"))}"

  handler = "hello.lambda.Handler"
  runtime = "java8"

  timeout = "1"

  role = "${aws_iam_role.hello_lambda_clj.arn}"
}

resource "aws_iam_role" "hello_lambda_clj" {
  name = "hello-lambda-clj"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_api_gateway_rest_api" "hello_lambda_clj" {
  name = "hello-lambda-clj"
}

resource "aws_api_gateway_method" "hello_lambda_clj" {
  rest_api_id   = "${aws_api_gateway_rest_api.hello_lambda_clj.id}"
  resource_id   = "${aws_api_gateway_rest_api.hello_lambda_clj.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_lambda_clj" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_lambda_clj.id}"
  resource_id = "${aws_api_gateway_method.hello_lambda_clj.resource_id}"
  http_method = "${aws_api_gateway_method.hello_lambda_clj.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.hello_clj.invoke_arn}"
}

resource "aws_api_gateway_deployment" "hello_lambda_clj" {
  depends_on = ["aws_api_gateway_integration.hello_lambda_clj"]

  rest_api_id = "${aws_api_gateway_rest_api.hello_lambda_clj.id}"
  stage_name  = "production"
}

resource "aws_lambda_permission" "hello_clj" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.hello_clj.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_deployment.hello_lambda_clj.execution_arn}/*/*"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.hello_lambda_clj.invoke_url}"
}

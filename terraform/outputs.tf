output "test" {
  value = " curl http://localstack:4566/restapis/${aws_api_gateway_rest_api.webserver-api.id}/test/_user_request_/ -vv"
}

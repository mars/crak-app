# Default routing for mars/crak buildpack.
#
# This Terraform config my be copied into the app and customized.

resource "kong_service" "react" {
  name     = "create-react-app"
  protocol = "http"
  host     = "127.0.0.1"
  port     = 3000
}

resource "kong_route" "web_root" {
  protocols  = ["https", "http"]
  paths      = ["/"]
  service_id = "${kong_service.react.id}"
}

provider "random" {
  version = "~> 2.0"
}

resource "random_id" "private_access_password" {
  byte_length = 32
}

output "private_access_password" {
  value = "${random_id.private_access_password.b64_url}"
}

resource "kong_plugin" "react_basic_auth" {
  name        = "basic-auth"
  service_id  = "${kong_service.react.id}"

  config = {
    hide_credentials = "true"
  }
}

resource "kong_consumer" "private_access" {
  username = "private"
}

resource "kong_consumer_plugin_config" "private_access_credentials" {
  consumer_id = "${kong_consumer.private_access.username}"
  plugin_name = "basic-auth"

  config = {
    username = "private"
    password = "${random_id.private_access_password.b64_url}"
  }
}

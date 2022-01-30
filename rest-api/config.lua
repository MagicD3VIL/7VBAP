local config = require("lapis.config")
local secrets = require("./secrets")

config("devel", {
  server = "nginx",
  host_ip = "127.0.0.1",
  port = 6633,
  num_workers = "auto",
  session_name = "rest_api",
  bcrypt_rounds = 10,
  secret = secrets.app_secret,
  secret_jwt = secrets.jwt_secret,
  secret_hmac = secrets.hmac_secret,
  hmac_digest = "sha256",
  code_cache = "off",
  measure_performance = true,
  mysql = {
    host = host_ip,
    user = "rest-api",
    password = secrets.mysql_password,
    database = "rest-api"
  }
})

config("release", {
  server = "nginx",
  host_ip = "127.0.0.1",
  port = 6633,
  num_workers = "auto",
  bcrypt_rounds = 10,
  session_name = "rest_api",
  secret = secrets.app_secret,
  secret_jwt = secrets.jwt_secret,
  secret_hmac = secrets.hmac_secret,
  hmac_digest = "sha256",
  code_cache = "on",
  mysql = {
    host = host_ip,
    user = "rest-api",
    password = secrets.mysql_password,
    database = "rest-api"
  }
})

local lapis = require("lapis")
local app = lapis.Application()
package.loaded.app = app

-- IMPORT ENDPOINTS
require ("./src/users")
require ("./src/threads")
require ("./src/posts")
require ("./src/tags")

-- LAPIS-RESTY IMPORT
local ngx = require("ngx")
local config = require("lapis.config").get()

-- JSON IMPORT
local cjson = require("cjson")

-- SECURITY IMPORT
local jwt = require ("resty.jwt")

-- SESSION INIT
app.session = require "resty.session".new({
  secret = config.secret,
  hmac = config.hmac_digest,
  storage = "shm",
  serializer = "json",
  cookie = {
    persistent = true,
    idletime = 0,
    lifetime = 604800,
    samesite = "Strict",
    secure = true,
    httponly = true
  },
  check = {
    ssi = false
  }
})


function app:jsonResponse(status, result) -- sends back a response with HTTP response code and JSON body
  ngx.status = status -- ngx.HTTP_* = https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/#http-status-constants
  
  if (status >= 200 and status <= 204) then
    ngx.say(cjson.encode({ success = true, result = result or nil }))
  else
    ngx.say(cjson.encode({ success = false, reason = result or nil }))
  end
  
  return ngx.exit(status)
end


function app:handle_error(err, trace)
  return app:jsonResponse(ngx.HTTP_INTERNAL_SERVER_ERROR, lapis.Application.handle_error(self, err, trace))
end


function app:handle_404()
  return app:jsonResponse(ngx.HTTP_NOT_FOUND, "Endpoint not found")
end


-- BEFORE FILTER
app:before_filter(function(self)
  local session = app.session
  session:open()
  
  local r = self.route_name
  local m = ngx.req.get_method():lower()
  
  if session.data.jwt == nil and not((r == "login" or r == "user") and m == "post") then
    return app:jsonResponse(ngx.HTTP_UNAUTHORIZED, "You need to log in to access this resource")
  end
  
  local jwt_obj = jwt:verify(config.secret_jwt, session.data.jwt)
  
  if (jwt_obj == nil or jwt_obj.verified == false) and not((r == "login") and m == "post") then
    return app:jsonResponse(ngx.HTTP_UNAUTHORIZED, "JWT verification failure")
  end
  
end)

return app

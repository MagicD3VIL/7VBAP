local app = require "app"

--/ import
local ngx = require("ngx")
local app_helpers = require("lapis.application")
local respond_to = require("lapis.application").respond_to
local json_params = require("lapis.application").json_params
local config = require("lapis.config").get()
local jwt = require ("resty.jwt")
local bcrypt = require("bcrypt")
local Model = require("lapis.db.model").Model
--\ import

local capture_errors, capture_errors_json, yield_error, assert_error = app_helpers.capture_errors, app_helpers.capture_errors_json, app_helpers.yield_error, app_helpers.assert_error

local Users = Model:extend("users", { primary_key = "uuid" })
local Credentials = Model:extend("credentials", { 
  primary_key = "user_uuid"
})


app:match("users", "/users(/:uuid)", respond_to({
  
  GET = capture_errors_json(json_params(function(self)
    
    local uuid = self.params.uuid or false
    
    if uuid == false then 
      local users = Users:select()
      
      return app:jsonResponse(ngx.HTTP_OK, users)
      
    else
      -- get user instance from the DB
      local user = Users:find({ uuid = uuid })
      
      if user == nil then
        return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No user found with this uuid")
      end
      
      return app:jsonResponse(ngx.HTTP_OK, user)
      
    end
    
  end)),


  POST = capture_errors_json(json_params(function(self)
    
    local params = {
      login = self.params.login or false,
      nickname = self.params.nickname or false,
      email = self.params.email or false
    }
    
    if params["login"] == nil then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "One of the requested parameters is nil")
    end
    
    local username, password = params["login"]:match("^(.+)@(.+)$")
    
    if username == nil or password == nil then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Could not get a valid username@password values")
    end
    
    password = bcrypt.digest(password, config.bcrypt_rounds)
    
    for k,v in pairs(params) do
      if v == false then 
        return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "One of the requested parameters is nil")
      end
    end
    
    if #username < 1 or #username > 32 then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Username must be between 3-32 chars long")
    end
    
    if #password ~= 60 then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Password must be equal to 60 chars")
    end
    
    if #params["nickname"] < 1 or #params["nickname"] > 32 then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Nickname must be between 1-32 chars long")
    end
    
    if #params["email"] < 1 or #params["email"] > 60 then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Email must be between 1-60 chars long")
    end
    
    local user, uuid = nil, nil
    local status, result = pcall(function()
        user = Users:create({
        username = username:lower(),
        nickname = params["nickname"],
        email = params["email"]:lower()
      })
      uuid = Users:find({ username = user["username"] })
      Credentials:create({
        uuid = uuid["uuid"],
        password = password
      })
    end)
    
    if status == false or user == nil then
      return app:jsonResponse(ngx.HTTP_CONFLICT, result)
    end
    
    return app:jsonResponse(ngx.HTTP_CREATED, uuid["uuid"])
    
  end)),


  PUT = capture_errors_json(json_params(function(self)
    
    app.session:open()
    
    local uuid = self.params.uuid or false
    
    if uuid == false then 
        return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "One of the requested parameters is nil")
    end
    
    -- return 403 if the uuid of the requestee is not same as the uuid requested to change, user cannot change other users
    local jwt_obj = jwt:load_jwt(app.session.data.jwt)
    if uuid ~= jwt_obj.payload.uuid then
      return app:jsonResponse(ngx.HTTP_FORBIDDEN, "You don't have permission to update this user")
    end
    
    if self.params.user == nil then 
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing object of type User")
    end
    
    local user_obj = {
      nickname = self.params.user.nickname or false, 
      email = self.params.user.email or false
    }
    
    -- checks for the User input object
    for k,v in pairs(user_obj) do
      if v == false then 
        return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Object of type User is invalid")
      end
    end
    
    if #user_obj["nickname"] < 1 or #user_obj["nickname"] > 32 then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Nickname must be between 1-32 chars long")
    end
    
    if #user_obj["email"] < 1 or #user_obj["email"] > 60 then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Email must be between 1-60 chars long")
    end
    
    -- find user in the database
    local user = Users:find(uuid)
    
    if user == nil then
      return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No user found with this uuid")
    end
    
    -- try to update user data in the database
    local status, result = pcall(function()
      user:update({
        nickname = user_obj["nickname"],
        email = user_obj["email"]:lower()
      })
    end)
  
    -- if DB query failed, assume conflict and return error generated by DB
    if status == false or user == nil then
      return app:jsonResponse(ngx.HTTP_CONFLICT, result)
    end
    
    return app:jsonResponse(ngx.HTTP_OK)
    
  end)),


  DELETE = capture_errors_json(json_params(function(self)
    
    app.session:open()
    
    local uuid = self.params.uuid or false
    
    if uuid == false then 
        return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "One of the requested parameters is nil")
    end
    
    -- return 403 if the uuid of the requestee is not same as the uuid requested to delete, user cannot delete other users than himself
    local jwt_obj = jwt:load_jwt(app.session.data.jwt)
    if uuid ~= jwt_obj.payload.uuid then
      return app:jsonResponse(ngx.HTTP_FORBIDDEN, "You don't have permission to delete this user")
    end
    
    -- get user instance from the DB
    local user = Users:find({ uuid = uuid })
    
    if user == nil then
      return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No user found with this uuid")
    end
    
    -- try to delete user data in the database
    local status, result = pcall(function()
      user:delete()
    end)
  
    -- if DB query failed, assume conflict and return error generated by DB
    if status == false or user == nil then
      return app:jsonResponse(ngx.HTTP_CONFLICT, result)
    end
    
    app.session:destroy()
    return app:jsonResponse(ngx.HTTP_OK)
    
  end))
  
}))

app:match("login", "/login", respond_to({
  
  POST = capture_errors_json(json_params(function(self)
    
    local login = self.params.login or false
    
    if login == false then 
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "One of the requested parameters is nil")
    end
    
    local username, password = login:match("^(.+)@(.+)$")
    
    if username == nil or password == nil then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Malformed login")
    end
    
    local user = Users:find({ username = username:lower() })
    
    if user == nil then
      return app:jsonResponse(ngx.HTTP_NOT_FOUND, "User not found")
    end
    
    local credentials = Credentials:find(user["uuid"])
    
    if credentials == nil then 
      return app:jsonResponse(ngx.HTTP_NOT_FOUND, "Credentials for the user " .. username .. " not found in the database.")
    end
    
    if bcrypt.verify(password, credentials["password"]) then
      local session = app.session
      session:open()
      if not session.started then
        session:start()
      end
      
      local jwt_token = jwt:sign(config.secret_jwt, {
        header = {typ = "JWT", alg = "HS256"},
        payload = {uuid = user["uuid"]}
      })
      
      session.data.jwt = jwt_token
      session:save()
      return app:jsonResponse(ngx.HTTP_OK, user)
    end
    
    return app:jsonResponse(ngx.HTTP_UNAUTHORIZED, "Invalid credentials")
    
  end))

}))

app:match("logout", "/logout", respond_to({
  
  POST = capture_errors_json(json_params(function(self)
    
    app.session:open()
    app.session:destroy()
    return app:jsonResponse(ngx.HTTP_OK)
    
  end))

}))
local app = require "app"

--/ import
local ngx = require("ngx")
local app_helpers = require("lapis.application")
local respond_to = require("lapis.application").respond_to
local json_params = require("lapis.application").json_params
local jwt = require ("resty.jwt")
local Model = require("lapis.db.model").Model
--\ import

local capture_errors, capture_errors_json, yield_error, assert_error = app_helpers.capture_errors, app_helpers.capture_errors_json, app_helpers.yield_error, app_helpers.assert_error

local Threads = Model:extend("threads", {
  timestamp = true,
  relations = {
    {"created_by", belongs_to = "users", key = "uuid"}
  }
})
local Users = Model:extend("users", { primary_key = "uuid" })


app:match("threads", "/threads(/:id[%d])", respond_to({
  
  GET = capture_errors_json(json_params(function(self)
    
    local id = self.params.id or false
    
    if id == false then 
      local threads = Threads:select()
      
      return app:jsonResponse(ngx.HTTP_OK, threads)
      
    else
      local thread = Threads:find(id)
      
      if thread == nil then
        return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No thread found with id " .. id)
      end
      
      return app:jsonResponse(ngx.HTTP_OK, thread)
    end
    
  end)),


  POST = capture_errors_json(json_params(function(self)
    
    app.session:open()
    
    local jwt_obj = jwt:load_jwt(app.session.data.jwt)
    
    local name = self.params.name or false
    local created_by = jwt_obj.payload.uuid
    
    if name == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'name'")
    end
    
    local thread = nil
    local status, result = pcall(function()
      thread = Threads:create({
        name = name,
        created_by = created_by
      })
    end)
    
    if status == false or thread == nil then
      return app:jsonResponse(ngx.HTTP_CONFLICT, result)
    end
    
    return app:jsonResponse(ngx.HTTP_CREATED, thread["id"])
    
  end)),


  PUT = capture_errors_json(json_params(function(self)
    
    app.session:open()
    
    local jwt_obj = jwt:load_jwt(app.session.data.jwt)
    
    local id = self.params.id or false
    local name = self.params.name or false
    local created_by = jwt_obj.payload.uuid
    
    
    if name == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'name'")
    end
    
    local thread = nil
    
    if id ~= false then
      thread = Threads:find(id)
    end
    
    if thread == nil then 
      local status, result = pcall(function()
        thread = Threads:create({
        name = name,
        created_by = created_by
      })
      end)

      if status == false or thread == nil then
        return app:jsonResponse(ngx.HTTP_CONFLICT, result)
      end
      
      return app:jsonResponse(ngx.HTTP_CREATED, thread["id"])

    -- return 403 if the uuid of the requestee is not same as the uuid registered as a creator of the thread, user cannot change other user's threads
    else
      if thread["created_by"] ~= created_by then
        return app:jsonResponse(ngx.HTTP_FORBIDDEN, "You don't have permission to update this thread")
      end
    
      thread:update({
        name = name
      })
    end
    
    return app:jsonResponse(ngx.HTTP_OK, thread["id"])
    
  end)),


  DELETE = capture_errors_json(json_params(function(self)
    
    app.session:open()
    
    local id = self.params.id or false
    
    if id == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'id'")
    end
    
    local thread = Threads:find(id)
    
    if thread == nil then
      return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No thread found with id " .. id)
    end
    
    local jwt_obj = jwt:load_jwt(app.session.data.jwt)
    if thread["created_by"] ~= jwt_obj.payload.uuid then
      return app:jsonResponse(ngx.HTTP_FORBIDDEN, "You don't have permission to delete this thread")
    end
    
    local status, result = pcall(function()
      thread:delete()
    end)
    
    if status == false or thread == nil then
      return app:jsonResponse(ngx.HTTP_CONFLICT, result)
    end
    
    return app:jsonResponse(ngx.HTTP_OK)
    
  end))
  
}))
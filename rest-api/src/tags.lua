local app = require "app"

--/ import
local ngx = require("ngx")
local app_helpers = require("lapis.application")
local respond_to = require("lapis.application").respond_to
local json_params = require("lapis.application").json_params
local Model = require("lapis.db.model").Model
--\ import

local capture_errors, capture_errors_json, yield_error, assert_error = app_helpers.capture_errors, app_helpers.capture_errors_json, app_helpers.yield_error, app_helpers.assert_error

local Tags = Model:extend("tags")


app:match("tags", "/tags(/:id[%d])", respond_to({
  
  GET = capture_errors_json(json_params(function(self)
    
    local id = self.params.id or false
    
    if id == false then 
      local tags = Tags:select()
      
      return app:jsonResponse(ngx.HTTP_OK, tags)
      
    else
      local tag = Tags:find(id)
      
      if tag == nil then
        return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No tag found with id " .. id)
      end
      
      return app:jsonResponse(ngx.HTTP_OK, tag)
    end
    
  end)),


  POST = capture_errors_json(json_params(function(self)
    
    local name = self.params.name or false
    
    if name == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'name'")
    end
    
    local tag = nil
    local status, result = pcall(function()
        tag = Tags:create({
        name = name
      })
    end)
    
    if status == false or tag == nil then
      return app:jsonResponse(ngx.HTTP_CONFLICT, result)
    end
    
    return app:jsonResponse(ngx.HTTP_CREATED, tag["id"])
    
  end)),


  PUT = capture_errors_json(json_params(function(self)
    
    local id = self.params.id or false
    local name = self.params.name or false
    
    if name == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'name'")
    end
    
    local tag = nil
    
    if id ~= false then
      tag = Tags:find(id)
    end
    
    if tag == nil then 
      local status, result = pcall(function()
        tag = Tags:create({
        name = name
      })
      end)
    
      if status == false or tag == nil then
        return app:jsonResponse(ngx.HTTP_CONFLICT, result)
      end
      
      return app:jsonResponse(ngx.HTTP_CREATED, tag["id"])

    else
      tag:update({
        name = name
      })
    end
    
    
    return app:jsonResponse(ngx.HTTP_OK, tag["id"])
    
  end)),


  DELETE = capture_errors_json(json_params(function(self)
    
    local id = self.params.id or false
    
    if id == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'id'")
    end
    
    local tag = Tags:find(id)
    
    if tag == nil then
      return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No tag found with id " .. id)
    end
    
    local status, result = pcall(function()
      tag:delete()
    end)
    
    if status == false or tag == nil then
      return app:jsonResponse(ngx.HTTP_CONFLICT, result)
    end
    
    return app:jsonResponse(ngx.HTTP_OK)
    
  end))
  
}))
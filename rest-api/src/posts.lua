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

local Posts = Model:extend("posts", {
  primary_key = {"thread", "id"},
  timestamp = true,
  relations = {
    {"thread", belongs_to = "threads", key = "id"},
    {"posted_by", belongs_to = "users", key = "uuid"}
  }
})
local Threads = Model:extend("threads", {
  timestamp = true,
  relations = {
    {"created_by", belongs_to = "users", key = "uuid"}
  }
})
local Users = Model:extend("users", { primary_key = "uuid" })


app:match("posts", "/threads/:thread[%d]/posts(/:id[%d])", respond_to({
  
  GET = capture_errors_json(json_params(function(self)
    
    local id = self.params.id or false
    local thread_id = self.params.thread or false
    
    if thread_id == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'thread'")
    end
    
    local thread = Threads:find(thread_id)
    
    if thread == nil then
        return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No thread found with id " .. thread_id)
    end
    
    if id == false then 
      local posts = Posts:select("where thread = ?", thread_id)
      
      if post == nil then
        return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No post found in thread " .. thread_id)
      end
      
      return app:jsonResponse(ngx.HTTP_OK, posts)
      
    else
      local post = Posts:find(thread_id, id)
      
      if post == nil then
        return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No post found in thread " .. thread_id .. " with id " .. id)
      end
      
      return app:jsonResponse(ngx.HTTP_OK, post)
    end
    
  end)),


  POST = capture_errors_json(json_params(function(self)
    
    app.session:open()
    
    local jwt_obj = jwt:load_jwt(app.session.data.jwt)
    
    local thread_id = self.params.thread or false
    local content = self.params.content or false
    local posted_by = jwt_obj.payload.uuid or false
    
    if content == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'content'")
    end
    
    if thread_id == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'thread'")
    end
    
    local thread = Threads:find(thread_id)
    
    if thread == nil then
        return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No thread found with id " .. thread_id)
    end
    
    local post_count = Posts:select("where thread = ?", thread_id, { fields = "COALESCE(MAX(id), 0) AS max" })
    
    if post_count == nil or tonumber(post_count[1]["max"]) == 0 then 
      post_count = 1 
    else
      post_count = tonumber(post_count[1]["max"]) + 1
    end
    
    local post = nil
    local status, result = pcall(function()
      post = Posts:create({
        id = post_count,
        thread = thread_id,
        posted_by = posted_by,
        content = content
      })
    end)
    
    if status == false or post == nil then
      return app:jsonResponse(ngx.HTTP_CONFLICT, result)
    end
    
    local location = {
      thread = thread["id"],
      post = post["id"]
    }
    
    return app:jsonResponse(ngx.HTTP_CREATED, location)
    
  end)),


  PUT = capture_errors_json(json_params(function(self)
    
    app.session:open()
    
    local jwt_obj = jwt:load_jwt(app.session.data.jwt)
    
    local thread_id = self.params.thread or false
    local content = self.params.content or false
    local posted_by = jwt_obj.payload.uuid or false
    local id = self.params.id or false
    
    if content == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'content'")
    end
    
    if thread_id == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'thread'")
    end
    
    local thread = Threads:find(thread_id)
    
    if thread == nil then
        return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No thread found with id " .. thread_id)
    end
    
    local post = nil
    
    if id ~= false then
      post = Posts:find(thread_id, id)
    end
    
    if post == nil then 
      local post_count = Posts:select("where thread = ?", thread_id, { fields = "COALESCE(MAX(id), 0) AS max" })
    
      if post_count == nil or tonumber(post_count[1]["max"]) == 0 then 
        post_count = 1 
      else
        post_count = tonumber(post_count[1]["max"]) + 1
      end
      
      local post = nil
      local status, result = pcall(function()
        post = Posts:create({
          id = post_count,
          thread = thread_id,
          posted_by = posted_by,
          content = content
        })
      end)
      
      if status == false or post == nil then
        return app:jsonResponse(ngx.HTTP_CONFLICT, result)
      end
      
      local location = {
        thread = thread["id"],
        post = post["id"]
      }
      
      return app:jsonResponse(ngx.HTTP_CREATED, location)

    -- return 403 if the uuid of the requestee is not same as the uuid registered as a creator of the post, user cannot change other user's posts
    else
      if post["posted_by"] ~= posted_by then
        return app:jsonResponse(ngx.HTTP_FORBIDDEN, "You don't have permission to update this post")
      end
      
      post:update({
        content = content
      })
      
      local location = {
      thread = thread["id"],
      post = post["id"]
      }
      
      return app:jsonResponse(ngx.HTTP_CREATED, location)
      
    end
    
  end)),


  DELETE = capture_errors_json(json_params(function(self)
    
    app.session:open()
    
    local jwt_obj = jwt:load_jwt(app.session.data.jwt)
    
    local thread_id = self.params.thread or false
    local content = self.params.content or false
    local posted_by = jwt_obj.payload.uuid or false
    local id = self.params.id or false
    
    
    if id == false then
      return app:jsonResponse(ngx.HTTP_BAD_REQUEST, "Missing parameter 'id'")
    end
    
    local post = Posts:find(thread_id, id)
    
    if post == nil then
      return app:jsonResponse(ngx.HTTP_NOT_FOUND, "No post found in thread " .. thread_id .. " with id " .. id)
    end
    
    if post["posted_by"] ~= posted_by then
      return app:jsonResponse(ngx.HTTP_FORBIDDEN, "You don't have permission to delete this post")
    end
    
    local status, result = pcall(function()
      post:delete()
    end)
    
    if status == false or post == nil then
      return app:jsonResponse(ngx.HTTP_CONFLICT, result)
    end
    
    return app:jsonResponse(ngx.HTTP_OK)
    
  end))
  
}))
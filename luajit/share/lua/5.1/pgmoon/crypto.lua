local md5
if ngx then
  md5 = ngx.md5
elseif pcall(function()
  return require("resty.openssl.digest")
end) then
  local openssl_digest = require("resty.openssl.digest")
  local hex_char
  hex_char = function(c)
    return string.format("%02x", string.byte(c))
  end
  local hex
  hex = function(str)
    return (str:gsub(".", hex_char))
  end
  md5 = function(str)
    return hex(openssl_digest.new("md5"):final(str))
  end
elseif pcall(function()
  return require("crypto")
end) then
  local crypto = require("crypto")
  md5 = function(str)
    return crypto.digest("md5", str)
  end
else
  md5 = function()
    return error("Either luaossl (recommended) or LuaCrypto is required to calculate md5")
  end
end
local hmac_sha256
hmac_sha256 = function(key, str)
  local openssl_hmac = require("resty.openssl.hmac")
  local hmac = assert(openssl_hmac.new(key, "sha256"))
  hmac:update(str)
  return assert(hmac:final())
end
local digest_sha256
digest_sha256 = function(str)
  local digest = assert(require("resty.openssl.digest").new("sha256"))
  digest:update(str)
  return assert(digest:final())
end
local kdf_derive_sha256
kdf_derive_sha256 = function(str, salt, i)
  local openssl_kdf = require("resty.openssl.kdf")
  local decode_base64
  decode_base64 = require("pgmoon.util").decode_base64
  salt = decode_base64(salt)
  local key, err = openssl_kdf.derive({
    type = "PBKDF2",
    md = "sha256",
    salt = salt,
    iter = i,
    pass = str,
    outlen = 32
  })
  if not (key) then
    return nil, "failed to derive pbkdf2 key: " .. tostring(err)
  end
  return key
end
return {
  md5 = md5,
  hmac_sha256 = hmac_sha256,
  digest_sha256 = digest_sha256,
  kdf_derive_sha256 = kdf_derive_sha256
}

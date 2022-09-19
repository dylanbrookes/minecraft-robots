local r = require("cc.require")
_ENV.require, _ENV.package = r.make(_ENV, "/code")
_ENV.args = { ... }

-- apply lualib_bundle to global env
local lb = require('/lualib_bundle')
for k, v in pairs(lb) do _ENV[k] = v end
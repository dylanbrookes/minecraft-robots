local r = require("cc.require")
_ENV.require, _ENV.package = r.make(_ENV, "/")
_ENV.args = { ... }
require("lualib_bundle")
local r = require("cc.require")
_ENV.require, _ENV.package = r.make(_ENV, "/code")
_ENV.args = { ... }
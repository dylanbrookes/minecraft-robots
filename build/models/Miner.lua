_nodejs = true;
local _ENV = require("castl.runtime");
local module = _obj({exports = _obj({})});
local exports = module.exports;
local Miner,cc__tweaked__types__1,____importDefault,__classCallCheck;

__classCallCheck = (function (this, a, b)
if not (_instanceof(a,b)) then
_throw(_new(TypeError,"Cannot call a class as a function"),0)
end

end);
____importDefault = ((function() local _lev=((function() if _bool(undefined) then return undefined["__importDefault"]; else return undefined; end end)()); return _bool(_lev) and _lev or (function (this, a)
do return (function() if _bool(((function() if _bool(a) then return a["__esModule"]; else return a; end end)())) then return a; else return _obj({
["default"] = a
}); end end)(); end
end) end)());
Object:defineProperty(exports,"__esModule",_obj({
["value"] = true
}));
cc__tweaked__types__1 = ____importDefault(_ENV,require(_ENV,"cc-tweaked-types"));
_e(cc__tweaked__types__1.default);
Miner = (function (this)
__classCallCheck(_ENV,this,a);
end);
return module.exports;
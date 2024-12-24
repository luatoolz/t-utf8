local t = require "t"
local u = t.utf8
return function(x) x=tostring(x); return u.len(x)~=string.len(x) or nil end
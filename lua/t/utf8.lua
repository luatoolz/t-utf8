local t = require 't'
local u = require 'lua-utf8'
local lib = {}

function lib.stripper(...)
  local self, to = ...
  if type(self)=='string' then return function(it) if type(it)=='string' then return lib.gsub(it, self, to or '') end end end
  if type(self)=='table' then
    return function(it)
      if type(it)=='string' then
        for _,v in ipairs(self) do
          if type(v)=='string' or type(v)=='function' then
            it = lib.gsub(it, v, '', 1) end end
        return it:null() end end end end

local function saver(...)
  local it=(...) or {}
  return function(x)
    if type(x)~='nil' then table.insert(it, x) else return it end end end

function lib.split(self, ...)
	if type(self)~='string' or self=='' then return end
  local sep, len = ..., select('#', ...)
  if len>1 then sep={...} end
  sep=sep or ' '
  if type(sep)=='table' then
    if #sep==0 then return nil end
    for i=1,#sep do if type(sep[i])~='string' then return nil end end
  end
  local rv = {}
  if type(sep)=='table' then
    sep=table.concat(sep, '')
    lib.gsub(self, '([^%s]+)' % lib.escape(sep), saver(rv))
  elseif type(sep)=='string' then
    lib.gsub(sep=='' and self or (self .. (sep or ' ')), sep=='' and '(.)' or string.format('(.-)(%s)', (sep~='' and sep~=' ') and lib.escape(sep) or "[%s\n]+"), saver(rv))
  end
  return rv end

function lib.splitter(...)
  local sep, len = ..., select('#', ...)
  if len>1 then sep={...} end
  return function(it)
    if type(it)=='string' then
      return lib.split(it, sep) end end end

function lib.gsplit(self, sep)
  return type(sep)~='string' and lib.gmatch(tostring(self), '.+') or
    lib.gmatch(tostring(self) .. (sep or ' '), sep=='' and '(.)' or string.format('(.-)%s', lib.escape(sep) or '%s+')) end

function lib.gsplitter(...)
  local self = ...
  return function(it)
    if type(it)=='string' then
      return lib.gsplit(it, self) end end end

function lib.gmatcher(...)
  local self = ...
  return function(it)
    it=tostring(it):null()
    if type(it)=='string' then
      return lib.gmatch(it, self) end
    return function() return end end end

function lib.smatcher(...)
  local self, compare = ...
  if type(compare)~='boolean' then compare=nil end
  return (not compare) and function(it)
    if type(it)=='nil' then return end
    if type(it)=='number' then it=tostring(it):null() end
    if type(it)=='string' then
      return lib.match(it, self)
    end
  end or function(it) if type(it)=='string' then
    return lib.match(it, self)==it or nil end end end

function lib.matcher(...)
  local self, compare = ...
  if type(compare)~='boolean' then compare=nil end
  if (not compare) and type(self)=='function' then return self end
  if type(self)=='string' then return lib.smatcher(self, compare) end
  if type(self)=='table' or type(self)=='function' then
    return function(it)
      if type(it)=='nil' then
        return end
      if type(it)=='boolean' then
        return end
      if type(it)=='number' or (getmetatable(it or {}) or {}).__tostring then
        it=tostring(it):null()
      end
      if type(it)=='string' then
        if type(self)=='function' and compare then return self(it)==it or nil end
        local rv, any = it
        for _,v in ipairs(self) do
          if type(v)=='boolean' then any=v
          elseif type(v)=='function' or (type(v)=='table' and (getmetatable(v) or {}).__call) then
            rv = v(rv)
          elseif type(v)=='string' then
            rv = lib.match(rv, v)
            if rv and any then
              if compare then return rv==v or nil end
              return rv end
          end
        end
        if compare then return rv==it or nil end
        return rv end end end end

return setmetatable(lib, {__index=u})
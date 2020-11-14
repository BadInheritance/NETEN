local printf = function(s,...)
    return io.write(s:format(...))
end -- f

module = {}
return setmetatable(module, {__call = function(_,...) return printf(...) end})
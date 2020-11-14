local module = {}
Vector = require("vector")

local Door = {}

local function new(x, y, closed)
  return setmetatable({
      origin = Vector.new(x, y),
      closed = closed,
  }, Door)
end

function Door:toggle()
    self.closed = not self.closed
end

module.new = new
return setmetatable(module, {__call = function(_,...) return new(...) end})

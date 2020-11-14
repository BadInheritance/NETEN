Window = {}

Vector = require("src/vector")

WindowSingleton = {

}

function WindowSingleton:init(arg)
    flags = {
        resizable = false
    }
    self.width = arg.width
    self.height = arg.height
    love.window.setMode(arg.width, arg.height, flags)
end 

function WindowSingleton:get_size()
    return Vector.new(self.width, self.height)
end

Window.init = function(arg) WindowSingleton:init(arg) end
Window.get_size = function() return WindowSingleton:get_size() end

-- return setmetatable(module, {__call = function(_,...) return new(...) end})
-- singleton = Window

return Window
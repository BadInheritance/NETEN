local DrawState = {}

function DrawState:new()
    color = {} 
    color.r = 0
    color.g = 0
    color.b = 0
    color.a = 0
    line_width = 0
    self.__index = self
    return setmetatable({
        color = color,
        line_width = line_width,
    }, self)
end


function DrawState:push()
    love.graphics.push()
    r, g, b, a = love.graphics.getColor()
    self.color.r = r
    self.color.g = g
    self.color.b = b
    self.color.a = a
end

function DrawState:pop()
    love.graphics.setColor(self.color.r, self.color.g, 
        self.color.b, self.color.a)
    love.graphics.setLineWidth(self.line_width)
    love.graphics.pop()
end

DrawStateSingleton = DrawState:new()
DrawStateSingleton:push()

DrawStateModule = {}
DrawStateModule.push = function(...) DrawStateSingleton:push(...) end
DrawStateModule.pop =  function(...) DrawStateSingleton:pop(...) end

return DrawStateModule
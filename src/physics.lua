Functional = require 'src/functional'
printf = require 'src/printf'
Window = require 'src/window'
HC = require 'ext/HC'

Physics = {
    rects = {}
}

function Physics:new()
    return self
end

function draw_debug_rect(rect)
    rect:draw()
end

function Physics:draw()
    Functional.foreach(self.rects, draw_debug_rect)
end

function Physics:add_rectangle(...)
    rect = HC.rectangle(...)
    table.insert(self.rects, rect)
end

function Physics:init() 
    local window_size = Window.get_size()
    Physics:add_rectangle(0, 0, window_size.x, 20)
    Physics:add_rectangle(0, window_size.y-20, window_size.x, 20)
    Physics:add_rectangle(0, 20, 20, window_size.y-40)
    Physics:add_rectangle(window_size.x-20, 20, 20, window_size.y-40)
    -- Physics:add_rectangle(0, 0, 100, 20)
end

PhysicsSingleton = Physics:new()

PhysicsModule = {}

PhysicsModule.init = function ()
    PhysicsSingleton:init()
end

PhysicsModule.draw = function ()
    PhysicsSingleton:draw()
end

return PhysicsModule
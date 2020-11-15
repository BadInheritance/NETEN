Functional = require 'src/functional'
printf = require 'src/printf'
Window = require 'src/window'
DrawState = require 'src/draw_state'
HC = require 'ext/HC'

Physics = {
    debug_draw_enabled = false,
    physics_time = 0,
    colliders = {},
    rects = {}
}

function Physics:new() return self end

function Physics:draw_debug_rect(rect)
    mode = "line"
    if (self.physics_time - rect.collision.last_collision_t) < 0.5 then
        mode = "fill"
    end
    rect:draw(mode)
end

function Physics:draw()
    DrawState:push()
    if self.debug_draw_enabled then
        local draw_debug_rect = function (x) self:draw_debug_rect(x) end
        Functional.foreach(self.rects, draw_debug_rect)
    end
    DrawState:pop()
end

function Physics:add_rectangle(...)
    rect = HC.rectangle(...)
    rect.collision = {
        last_collision_t = 0
    }
    table.insert(self.rects, rect)
end

function Physics:init(args)
    self.debug_draw_enabled = args.debug_draw_enabled
    local window_size = Window.get_size()
    -- Physics:add_rectangle(0, 0, 100, 20)
end

function Physics:update(dt)
    self.physics_time = self.physics_time + dt
    for _, collider in pairs(self.colliders) do
        for shape, delta in pairs(HC.collisions(collider.shape)) do
            assert(shape.collision, "remember to add a collision object in shape")
            shape.collision.last_collision_t = self.physics_time
            x, y = collider.shape:center()
            separating_vector = Vector.new(delta.x, delta.y)
            collider.on_collision(separating_vector)
        end
    end
end

-- A collider must be
-- Collider = {
--     shape,
--     on_collision
-- }

function Physics:add_collider(collider)
    assert(collider.shape)
    assert(collider.on_collision)

    table.insert(self.colliders, collider)
end

PhysicsSingleton = Physics:new()

PhysicsModule = {}

PhysicsModule.init = function(...) PhysicsSingleton:init(...) end

PhysicsModule.draw = function() PhysicsSingleton:draw() end

PhysicsModule.update = function(...) PhysicsSingleton:update(...) end

PhysicsModule.add_rectangle = function(...) PhysicsSingleton:add_rectangle(...) end

PhysicsModule.add_collider = function(collider)
    PhysicsSingleton:add_collider(collider)
end

return PhysicsModule

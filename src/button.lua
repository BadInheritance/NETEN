Object = require "src/classic"
Vector = require "src/vector"
printf = require "src/printf"
DrawState = require "src/draw_state"
GMath = require 'src/gmath'
HC = require 'ext/HC'

Button = Object:extend()

Button.set_assets = function(assets)
    Button.super.assets = assets
end

function Button:new()
    self.pos = Vector.new(300, 200)
    self.radius = 40
    self.shape = HC.circle(self.pos.x, self.pos.y, self.radius)
    self.pressed = false
end

function Ball:as_collider()
    return {
        shape = self.shape,
        on_collision = function(...) self:on_collision(...) end
    }
end

function Button:on_collision(separating_vector, other)
    printf("button on collision\n")
end
Functional = require "src/functional"
DrawState = require "src/draw_state"
module = {}

local WallManager = {}
WallManager.__index = WallManager

local Wall = {}
Wall.__index = Wall

function new_wall(x, y, w, h)
    return setmetatable(
        {x = x, y=y, w=w, h=h},
        Wall)
end

function new()
  return setmetatable({
      walls = {}
  }, WallManager)
end

function WallManager:init()
end

function WallManager:add_wall(x, y, w, h)
    margin = 10
    half_margin = margin/2
    Physics:add_rectangle(x-half_margin, y-half_margin, w+margin, h+margin)
    wall = new_wall(x, y, w, h)
    table.insert(self.walls, wall)
end

function WallManager:draw_walls()
    Functional.foreach(self.walls, function(wall)
        mode = "fill"
        love.graphics.setColor(200, 200, 0, 255)
        love.graphics.rectangle(mode, wall.x, wall.y, wall.w, wall.h)
        love.graphics.setColor(255, 255, 255, 255)
    end)
end

function WallManager:draw()
    DrawState:push()
    self:draw_walls()
    DrawState:pop()
end

module.new = new

return module


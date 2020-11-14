--! main

function love.load()
    Object = require "src/classic"
    require "src/ball"
    ball = Ball()
end

function love.update(dt)
    ball:update(dt)

end


function love.draw()
	ball:draw()
end
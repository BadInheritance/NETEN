---! ball
Object = require("src/classic")
Vector = require("vector")

Ball = Object:extend()

local function getMousePos()
    return Vector(love.mouse.getPosition())
end

function Ball:new()
    self.pos = Vector.new(100, 100)
    self.radius = 50
    self.selected = false
    self.direction = 0.0
    self.speed = 0.0
    self.friction_factor = 1
    self:set_status('idle')
end

function Ball:get_dir_vector()
    return Vector.fromAngle(self.direction) * self.speed
end

function Ball:checkBallPressed(point)
    return (point - self.pos):magSq() < self.radius^2
end

function Ball:draw_frameset()
    -- TODO: Keep this?
    love.graphics.setColor(200, 10, 10, 0.9)
    love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)

    local frame

    if self.current_frameset ~= nil then
	frame = self.current_frameset:get_current_frame()
    end
    if frame ~= nil then
	self:default_draw(frame.image, frame.quad)
    end
end

function Ball:update(...) self.current_status.update(self, ...) end
function Ball:draw(...) self.current_status.draw(self, ...) end
function Ball:set_status(state_name)
    local state = self.states[state_name]
    if state == nil then error("Unknown state: " .. state_name) end
    if self.current_status ~= state then
	self.current_status = state
	self.current_status_name = state_name
	self.status_change_time = love.timer.getTime()
	self.current_status.start(self)
    end
end

function Ball:default_draw(image, quad, pos)
    if pos == nil then pos = self.pos end

    -- debug:
    -- love.graphics.rectangle('line', pos.x, pos.y, image:getWidth(), image:getHeight())
    local w, h
    if quad == nil
    then w, h = image:getDimensions()
    else _, _, w, h = quad:getViewport()
    end

    local ox = w / 2
    local oy = h / 2

    if quad == nil
    then love.graphics.draw(image, pos.x, pos.y, 0, 1, 1, ox, oy)
    else love.graphics.draw(image, quad, pos.x, pos.y, 0, 1, 1, ox, oy)
    end
end

Ball.states = {
    idle = {
	start = function (ball)
	     -- accessing assets?
	    ball.current_frameset = GameState.assets.framesets.idle_frames
	    ball.current_frameset:start()
	end,
	draw = function (ball) ball:draw_frameset() end,
	update = function (ball, dt)
	    if love.mouse.isDown(1) and ball:checkBallPressed(getMousePos()) then
		ball:set_status('transforming')
	    end
	end,
    },
    transforming = {
	start = function(ball)
	    ball.current_frameset = GameState.assets.framesets.transform_frames
	    ball.current_frameset:start()
	end,
	draw = function (ball) ball:draw_frameset() end,
	update = function(ball, dt)
	    if not love.mouse.isDown(1) then
		local delta = ball.pos - getMousePos()
		ball.direction = delta:heading()
		ball.speed = delta:getmag()
		ball:set_status('rolling')
	    end
	end
    },
    rolling = {
	start = function(ball) ball.current_frameset = nil end,
	update = function(ball, dt)
	    ball.pos = ball.pos + ball.speed * dt * ball:get_dir_vector()
	    ball.speed = ball.speed - ball.friction_factor
	    if ball.speed <= 0 then
		ball:set_status('idle')
	    end
	end,
	draw = function(ball)
	    local frame = GameState.assets.framesets.transform_frames.frames[9]
	    ball:default_draw(frame.image, frame.quad)

	    local function drawMask()
		love.graphics.circle('fill', ball.pos.x, ball.pos.y, 40)
	    end
	    love.graphics.stencil(drawMask, 'replace', 1)
	    love.graphics.setStencilTest('greater', 0)

	    local image = GameState.assets.images.just_eyes
	    local dt = love.timer.getTime() - ball.status_change_time
	    local moveLen = 8.0
	    local moveTime = 0.6
	    local pos = ball.pos + ball:get_dir_vector() * ((dt % moveTime)/moveTime - 0.5) * 10
	    ball:default_draw(image, nil, pos)
	    love.graphics.setStencilTest()
	end
    }
}

return Ball

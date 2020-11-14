--! ball

Ball = Object:extend()

Status = {
    IDLE = 1,
    ROLLING = 2
}

function Ball.new(self)
    self.x = 100
    self.y = 100
    self.radius = 50
    self.selected = false
    self.direction = 0.0
    self.speed = 0.0
    self.status = Status.IDLE
    self.friction_factor = 1
end

function Ball.update(self, dt)
    if love.mouse.isDown(1) and self:checkBallPressed(love.mouse.getX(), love.mouse.getY()) == true and self.status ~= Status.ROLLING then
        self.selected = true
    end
    if self.selected and not love.mouse.isDown(1) then
        self.direction = math.atan2(self.y - love.mouse.getY(), self.x - love.mouse.getX())
        self.speed = math.sqrt( (self.y - love.mouse.getY())^2 + (self.x - love.mouse.getX())^ 2)
        self.selected = false
        self.status = Status.ROLLING
    end
    if self.status == Status.ROLLING then
        self.x = self.x + self.speed * math.cos(self.direction) * dt
        self.y = self.y + self.speed * math.sin(self.direction) * dt
        self.speed = self.speed - self.friction_factor
        if self.speed <= 0 then
            self.status = Status.IDLE
        end
    end
end

function Ball.draw(self)
    self.color = love.graphics.setColor(200, 10, 10, 0.9)
    love.graphics.circle("fill",self.x, self.y, self.radius)
end

function Ball.checkBallPressed(self, mouse_x, mouse_y)
	local dx = mouse_x - self.x
    local dy = mouse_y - self.y
	return dx^2 + dy^2 < self.radius^2
end

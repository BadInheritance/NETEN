module = {}

function new() 
local GameState = {
    assets = {
        images = {
            open_door = love.graphics.newImage("assets/images/open_door.png"),
            closed_door = love.graphics.newImage("assets/images/closed_door.png"),
	    just_eyes = love.graphics.newImage("assets/just_eyes.png"),

	    sheet_ball_idle = love.graphics.newImage("assets/Ball_Idle.png"),
	    sheet_ball_transform = love.graphics.newImage("assets/Ball_Transform.png")
        },
	framesets = {}
    },
    level = {
        index = 1,
        -- INITIALIZE -> RUNNING -> COMPLETED
        state = "INITIALIZE",
        content = {
            player = {
                origin = Vector.new(0, 0)
            },
            doors = {

            },
        }
    },
    time = {
        time_from_boot = 0,
        time_from_level = 0
    },
}

return GameState
end

module.new = new
-- return setmetatable(module, {__call = function(_,...) return new(...) end})
return module
Vector = require("vector")
Door = require("door")


function load_spritesheet(image, n_horiz, n_vert)
    local tilew = image:getWidth() / n_horiz
    local tileh = image:getHeight() / n_vert
    -- Order is left-to-right, top-to-left
    local frames = {}

    for j = 1, n_vert do
	for i = 1, n_horiz do
	    local x = (i - 1) * tilew
	    local y = (j - 1) * tileh
	    local quad = love.graphics.newQuad(x, y, tilew, tileh, image:getDimensions())
	    table.insert(frames, {image = image, quad = quad})
	end
    end
    return frames
end


local Object = {}
function Object:new(instance)
    instance = instance or {}
    return setmetatable(instance, {__index = self})
end


local FrameSet = Object:new{
    frame_time = 1.0 / 15,  -- in secs
    start_time = 0,
    frames = {},
    loop = true,
}

function FrameSet.load_spritesheet(image, n_horiz, n_vert)
    return FrameSet:new{ frames = load_spritesheet(image, n_horiz, n_vert) }
end

function FrameSet:start()
    self.start_time = love.timer.getTime()
end

function FrameSet:animation_time()
    return love.timer.getTime() - self.start_time
end

function FrameSet:get_frame_index()
    local index = math.ceil(self:animation_time() / self.frame_time)
    if self.loop then
	index = index % #self.frames + 1
    elseif index > #self.frames then
	index = #self.frames
    end
    return index
end

function FrameSet:is_finished()
    return not self.loop and self:get_frame_index() >= #self.frames
end

function FrameSet:get_current_frame()
    if #self.frames == 0 then error("Empty frameset") end
    local index = self:get_frame_index()
    print('frame index', index)
    return self.frames[index]
end


local BallState = Object:new{
    update = function () end,
    start = function () end,
    draw = function (ball)
	local frame
	if ball.current_frameset ~= nil then
	    frame = ball.current_frameset:get_current_frame()
	end
	if frame ~= nil then
	    ball:default_draw(frame.image, frame.quad)
	end
    end
}
local Ball = Object:new{
    pos = Vector.new(0, 0),
    vel = Vector.new(0, 0),
    current_state = nil,
    current_frameset = nil,
    state_change_time = 0,
    states = {
	idle = BallState:new{
	    start = function(ball)
		ball.current_frameset = GameState.assets.framesets.idle_frames:new()
		ball.current_frameset:start()
	    end,
	    update = function(ball)
		if ball.vel.x ~= 0 or ball.vel.y ~= 0 then
		    ball:set_state('transforming')
		end
	    end
	},
	transforming = BallState:new{
	    start = function(ball)
		ball.current_frameset = GameState.assets.framesets.transform_frames:new()
		ball.current_frameset:start()
	    end,
	    update = function(ball)
		local over = ball.current_frameset:is_finished()
		if ball.vel.x == 0 and ball.vel.y == 0 then
		    ball:set_state('idle')
		elseif over then
		    ball:set_state('rolling')
		end
	    end
	},
	rolling = BallState:new{
	    start = function(ball) ball.current_frameset = nil end,

	    update = function(ball)
		if ball.vel.x == 0 and ball.vel.y == 0 then
		    ball:set_state('idle')
		end
		ball.pos = ball.pos + ball.vel
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
		local dt = love.timer.getTime() - ball.state_change_time
		local moveLen = 8.0
		local moveTime = 0.6
		local moveLen = image:getWidth() / 4
		local pos = ball.pos + ((dt % moveTime)/moveTime - 0.5) * moveLen * ball.vel
		ball:default_draw(image, nil, pos)
		love.graphics.setStencilTest()
	    end
	}
    },
}

function Ball:set_state(state_name)
    local state = self.states[state_name]
    if state == nil then error("Unknown state: " .. state_name) end
    if self.current_state ~= state then
	self.current_state = state
	self.current_state_name = state_name
	self.state_change_time = love.timer.getTime()
	self.current_state.start(self)
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

function Ball:init() self:set_state('idle') end
function Ball:update() self.current_state.update(self) end
function Ball:draw() self.current_state.draw(self) end


GameState = {
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

local the_ball = Ball:new()

function love.load()
    GameState.assets.framesets.idle_frames = FrameSet.load_spritesheet(
	GameState.assets.images.sheet_ball_idle, 1, 6)
    GameState.assets.framesets.idle_frames.loop = true

    GameState.assets.framesets.transform_frames = FrameSet.load_spritesheet(
	GameState.assets.images.sheet_ball_transform, 3, 3)
    GameState.assets.framesets.transform_frames.loop = false

    the_ball:init()
    the_ball.pos.x = 400
    the_ball.pos.y = 300
end

local printf = function(s,...)
           return io.write(s:format(...))
         end -- f



function update_time(game_state, level_is_running, dt)
    game_state.time.time_from_boot = game_state.time.time_from_boot + dt
    if level_is_running then
        game_state.time.time_from_level = game_state.time.time_from_level + dt
    end
end


function load_level_content_1()
    content = {
        player = {
            origin = Vector.new(0, 0)
        },
        doors = {
            Door.new(0.1, 100, true)
        }
    }
    return content
end

function load_level_content(level_index)
    local level_loaders = { load_level_content_1 }
    return level_loaders[level_index]()
end

function update_level(level)
    if level.state == "INITIALIZE" then
        printf("Initialize level %d\n", level.index)
        level.state = "RUNNING"
        level.content = load_level_content(level.index)
    elseif level.state == "RUNNING" then
    else
    end
end


function get_command_direction()
    local dx = 0
    local dy = 0
    -- handles simultaneous a+d  and w+s keypresses
    if love.keyboard.isDown('a') then dx = dx - 1.0 end
    if love.keyboard.isDown('d') then dx = dx + 1.0 end
    if love.keyboard.isDown('w') then dy = dy - 1.0 end
    if love.keyboard.isDown('s') then dy = dy + 1.0 end
    if dx ~= 0 and dy ~= 0 then
	local magnitude = math.sqrt(dx*dx, dy*dy)
	dx = dx / magnitude
	dy = dy / magnitude
    end
    return Vector.new(dx, dy)
end

function love.update(dt)
    local level_running = GameState.level.state == "RUNNING"
    update_time(GameState, level_running, dt)
    update_level(GameState.level)

    local dir = get_command_direction()
    the_ball.vel = dir * 5.0
    the_ball:update()
end

function foreach(tbl, f)
    for v in tbl do
        f(v)
    end
end


function draw_doors(assets, doors)
    draw_door = function(door)
        image = nil
        if door.closed then
            image = assets.images.closed_door
        else
            image = assets.images.open_door
        end
        -- printf("drawi door at %f \n", door.origin.x)
        love.graphics.draw(image, door.origin.x, door.origin.y)
    end
    -- table.foreach(doors, draw_door)
    for k, v in pairs (doors) do
        draw_door(v)
    end

end

function draw_level(assets, level)
    draw_doors(assets, level.content.doors)
end

function draw_debug_info(game_state)
    str = string.format("Game Time %f", game_state.time.time_from_boot)
    love.graphics.print(str, 0, 0)
end

function love.draw()
    love.graphics.setBackgroundColor( 0.5, 0.5, 0.5, 1)
    draw_debug_info(GameState)
    draw_level(GameState.assets, GameState.level)
    the_ball:draw()
end

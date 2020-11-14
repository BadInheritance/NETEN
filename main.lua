local Vector = require "src/vector"
local Door = require "src/door"
local Object = require "src/classic"
local Ball = require "src/ball"
local FrameSet = require "src/frameset"
local GameState = require "src/game_state"
local printf = require "src/printf"
local Level = require "src/level"
local Functional = require "src/functional"
local Physics = require "src/physics"
local Window = require "src/window"

GameState = GameState.new() 


function love.load()
    Window.init({
        width=1000,
        height=800
    })

    FrameSet.set_debug_options({enable_debug_print=false})

    GameState.assets.framesets.idle_frames = FrameSet.load_spritesheet(
	GameState.assets.images.sheet_ball_idle, 1, 6)
    GameState.assets.framesets.idle_frames.loop = true

    GameState.assets.framesets.transform_frames = FrameSet.load_spritesheet(
	GameState.assets.images.sheet_ball_transform, 3, 3)
    GameState.assets.framesets.transform_frames.loop = false


    Ball.set_assets(GameState.assets)
    local ball = Ball()
    ball.pos.x = 400
    ball.pos.y = 300
    GameState.ball = ball

    Physics.init()
end


function update_time(game_state, level_is_running, dt)
    game_state.time.time_from_boot = game_state.time.time_from_boot + dt
    if level_is_running then
        game_state.time.time_from_level = game_state.time.time_from_level + dt
    end
end



function love.update(dt)
    local level_running = GameState.level.state == "RUNNING"
    update_time(GameState, level_running, dt)
    Level.update_level(GameState.level)
    GameState.ball:update(dt)
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

    Functional.foreach(doors, draw_door)

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

    Physics.draw()
    draw_debug_info(GameState)
    draw_level(GameState.assets, GameState.level)
    GameState.ball:draw()
end

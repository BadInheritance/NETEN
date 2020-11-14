Vector = require("vector")
Door = require("door")


GameState = {
    assets = {
        images = {
            open_door = love.graphics.newImage("assets/images/open_door.png"),
            closed_door = love.graphics.newImage("assets/images/closed_door.png")
        },
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

function love.update(dt)
    local level_running = GameState.level.state == "RUNNING"
    update_time(GameState, level_running, dt)
    update_level(GameState.level)
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
end
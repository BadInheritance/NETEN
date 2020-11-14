local Door = require "src/door"
local printf = require "src/printf"

Level = {}

function load_level_content_1()
    content = {
        player = {origin = Vector.new(0, 0)},
        doors = {Door.new(0.1, 100, true)}
    }
    return content
end

function load_level_content(level_index)
    local level_loaders = {load_level_content_1}
    return level_loaders[level_index]()
end

Level.update_level = function(level)
    if level.state == "INITIALIZE" then
        printf("Initialize level %d\n", level.index)
        level.state = "RUNNING"
        level.content = load_level_content(level.index)
    elseif level.state == "RUNNING" then
    else
    end
end

return Level

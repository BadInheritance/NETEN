local Object = require('src/classic')
local utils = require('src/utils')

local FrameSet = Object:extend()

FrameSet.set_debug_options = function(arg)
    FrameSet.super.enable_debug_print = arg.enable_debug_print
end

function FrameSet:new()
    self.frame_time = 1.0 / 15  -- in secs
    self.start_time = 0
    self.frames = {}
    self.loop = true
end

function FrameSet.load_spritesheet(image, n_horiz, n_vert)
    local fs = FrameSet()
    fs.frames = utils.load_spritesheet(image, n_horiz, n_vert)
    return fs
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

    if self.enable_debug_print then
        print('frame index', index)
    end

    return self.frames[index]
end

return FrameSet

--! utils

local module = {}

function module.load_spritesheet(image, n_horiz, n_vert)
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

return module

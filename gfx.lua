--  Copyright 2016 krunkathos
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.

local gfx = {}

---- constants ----
gfx.SCN_TG_WIDTH = 320
gfx.SCN_TG_HEIGHT = 240
gfx.SCN_PROP = 0.71

-- screen graphics --
gfx.fullscreen = false
gfx.resizing = false
gfx.max_width = -1
gfx.max_height = -1
gfx.sc_width = -1
gfx.sc_height = -1
gfx.sc_scale = -1
gfx.of_x = -1
gfx.of_y = -1

function gfx.load()
    love.window.setMode(0, 0, {fullscreen=false, vsync=false})
    gfx.max_width = love.window.getWidth()
    gfx.max_height = love.window.getHeight()
    love.graphics.setDefaultFilter("nearest", "nearest")

    gfx.font_normal = love.graphics.setNewFont("gfx/fonts/PressStart2P/PressStart2P-Regular.ttf", 8)
    gfx.font_small = love.graphics.setNewFont("gfx/fonts/PressStart2P/PressStart2P-Regular.ttf", 7)
    love.graphics.setFont(gfx.font_normal)
end

function gfx.init()
    love.graphics.translate(gfx.of_x, gfx.of_y)
    love.graphics.scale(gfx.sc_scale, gfx.sc_scale)
end

function gfx.setFullscreen(fs)
    love.window.setMode(gfx.SCN_TG_WIDTH, gfx.SCN_TG_HEIGHT,
        {fullscreen=fs, fullscreentype="desktop", vsync=true, minwidth=gfx.max_width*gfx.SCN_PROP, minheight=gfx.max_height*gfx.SCN_PROP})
    gfx.sc_width = love.window.getWidth()
    gfx.sc_height = love.window.getHeight()
    
    local sc_ratio = gfx.sc_width / gfx.sc_height
    if sc_ratio >= (gfx.SCN_TG_WIDTH / gfx.SCN_TG_HEIGHT) then
        gfx.sc_scale = gfx.sc_height / gfx.SCN_TG_HEIGHT
    else
        gfx.sc_scale = gfx.sc_width / gfx.SCN_TG_WIDTH
    end
    gfx.of_x = math.floor((gfx.sc_width / 2) - ((gfx.SCN_TG_WIDTH * gfx.sc_scale) / 2))
    gfx.of_y = math.floor((gfx.sc_height / 2) - ((gfx.SCN_TG_HEIGHT * gfx.sc_scale) / 2))
    gfx.resizing = true
end

function gfx.toggleFullscreen()
    gfx.fullscreen = not gfx.fullscreen
    gfx.setFullscreen(gfx.fullscreen)
end

function gfx.resetDTScreenResizing(dt)
    if gfx.resizing then
        gfx.resizing = false
        return 0
    else
        return dt
    end
end

return gfx

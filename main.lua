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

require "lib/strict"

-- load other libraries
local gfx = require("gfx")
local menu = require("menu")
local game = require("game")
local editor = require("editor")
local leveldata = require("leveldata")

---- global variables ----
mode = "START_MENU"

function love.load(arg)
    gfx.load()
    gfx.setFullscreen(gfx.fullscreen)
    
    menu.load()
    game.load()
    editor.load()
end

function love.update(dt)
    --dt = dt/4
    dt = gfx.resetDTScreenResizing(dt)
    
    if love.keyboard.isDown("space") and love.keyboard.isDown("lalt") then
        gfx.toggleFullscreen()
        return
    end
    
    if mode == "START_MENU" then
        menu.init()
        mode = "MENU"
    elseif mode == "START_GAME" then
        leveldata.save_checkpoint("checkpoint.dat", 0)
        game.init()
        mode = "GAME"
    elseif mode == "CONTINUE_GAME" then
        local level = leveldata.load_checkpoint("checkpoint.dat") + 1
        game.continue(level)
        mode = "GAME"
    elseif mode == "START_EDITOR" then
        editor.init()
        mode = "EDITOR"
    elseif mode == "MENU" then menu.update(dt)
    elseif mode == "GAME" then game.update(dt)
    elseif mode == "EDITOR" then editor.update(dt)
    elseif mode == "EXIT" then love.event.quit()
    end

    if (love.keyboard.isDown("escape") and mode ~= "MENU") or (mode == "GAME" and game.mode == "EXITGAME") then
        game.exit()
        editor.exit()
        mode = "START_MENU"
    end
end

function love.keyreleased(key)
    if mode == "MENU" then mode = menu.keyreleased(key, mode)
    elseif mode == "GAME" then game.keyreleased(key)
    elseif mode == "EDITOR" then editor.keyreleased(key)
    end
end

function love.draw()
    gfx.init()
    
    if mode == "MENU" then menu.draw()
    elseif mode == "GAME" then game.draw()
    elseif mode == "EDITOR" then editor.draw()
    end
end

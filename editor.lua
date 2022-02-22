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

local editor = {}

local gfx = require("gfx")
local game = require("game")
local player = require("player")
local levels = require("levels")
local leveldata = require("leveldata")
local ropes = require("ropes")
local enemies = require("enemies")

editor.TIL_NULL = "T0:0:0:0:0:0"
editor.TIL_SWINGROPE = "R0.8:195:95:11:11:1"
editor.TIL_STRAIGHTROPE = "S0:180:500:1:9:1"
editor.TIL_FINISH = "F0:0:0:0:6:0"
editor.TIL_START = "P0:0:0:0:0:0"
editor.TIL_ENEMY = "E1:0:0:0:0.2:0"

editor.KEY_VALID = " abcdefghijklmnopqrstuvwxyz0123456789/,-'."
editor.TIT_MAXLENGTH = 38

editor.level = 1
editor.buffer = ""
editor.selectx = 1
editor.selecty = 1
editor.msg = ""
editor.msg_delay = 0

editor.params_select = 1
editor.params_valid = {
    { { "R" }, { "Sta",0,1,0.1,0.8 }, { "Ang",180,270,1,195 }, { "Spd",60,500,10,95 }, { "Wth",5,20,1,11 }, { "Hgt",2.5,20,1,11 }, { "Dir",-1,1,2,1 } },
    { { "S" }, { "",-1,-1,-1,0 }, { "",-1,-1,-1,180 }, { "",-1,-1,-1,0.5 }, { "",-1,-1,-1,1 }, { "Hgt",2.5,20,0.5,9 }, { "",-1,-1,-1,0 } },
    { { "F" }, { "",-1,-1,-1,0 }, { "",-1,-1,-1,180 }, { "",-1,-1,-1,0.5 }, { "",-1,-1,-1,1 }, { "Hgt",2.5,20,0.5,9 }, { "",-1,-1,-1,0 } },
    { { "E" }, { "Ene",1,4,1,1 }, { "DX",-5,5,0.5,0 }, { "DY",-3,3,0.5,0 }, { "ApD",0,10,0.5,0 }, { "AnD",0.1,8.0,0.1,0.2 }, { "",-1,-1,-1,0 } }
}

editor.info = {
    "Scene Editor",
    "- Arrow keys - move edit cursor",
    "- 1-n - add tile",
    "- R/S - add swinging/straight rope",
    "- B   - add enemy",
    "- F   - set level finish rope",
    "- P   - set player level start",
    "- E   - edit object",
    "- T   - edit level title",
    "- L   - cycle landscape",
    "- C   - toggle checkpoint level",
    "- I   - this information",
    "- Del - delete object",
    "- Ent - playtest level",
    "- [ / ] - previous / next level",
    "- Tab + LShift - add level before",
    "- Tab + RShift - add level after",
    "- LCtrl + S / L - save/load as levels.dat",
    "",
    "Parameter Editor",
    "- L/R - arrow keys select parameter",
    "- U/D - arrow keys change parameter",
    "- E - exit parameter editor",
    "",
    "Note: files are saved to "..love.filesystem.getSaveDirectory()
}

editor.mode ="EDITSCENE"

function editor.load()
    
end

function editor.init()
    local px, py = levels.init(editor.level)
    player.init(px, py)
    enemies.display_all = true
end

function editor.exit()
    editor.mode = "EDITSCENE"
end

function editor.update(dt)
    if editor.mode == "PLAY" then game.update(dt) end
    if editor.msg ~= "" then
        editor.msg_delay = editor.msg_delay + dt
        if editor.msg_delay > 1 then
            editor.msg = ""
            editor.msg_delay = 0
        end
    end
end

function editor.keyreleased(key)
    if editor.mode == "EDITSCENE" then editor.update_editscene(key)
    elseif editor.mode == "EDITPARAMS" then editor.update_editparams(key)
    elseif editor.mode == "EDITTITLE" then editor.update_edittitle(key)
    elseif editor.mode == "SHOWINFO" then editor.update_showinfo(key)
    elseif editor.mode == "PLAY" and key == "return" then
        game.exit()
        editor.mode = "EDITSCENE"
        editor.init()
    end
    return
end

function editor.update_editscene(key)
    local st_x, st_y = editor.selectx, editor.selecty
    
    if key == "left" and editor.selectx > 1 then editor.selectx = editor.selectx - 1 end
    if key == "right" and editor.selectx < 20 then editor.selectx = editor.selectx + 1 end
    if key == "up" and editor.selecty > 1 then editor.selecty = editor.selecty - 1 end
    if key == "down" and editor.selecty < 13 then editor.selecty = editor.selecty + 1 end
    
    if st_x ~= editor.selectx or st_y ~= editor.selecty then editor.find_valid_param(0, 1) end
    
    if key == "[" and editor.level > 1 then
        editor.level = editor.level - 1
        editor.init()
    elseif key == "]" and editor.level < #leveldata.map then
        editor.level = editor.level + 1
        editor.init()
    elseif key == "e" then
        editor.mode = "EDITPARAMS"
        editor.find_valid_param(0, 1)
    end
    
    if key == "t" then editor.mode = "EDITTITLE" end
    if key == "i" then editor.mode = "SHOWINFO" end
    
    if key == "return" then
        editor.mode = "PLAY"
        game.mode = "PLAY"
        game.level = editor.level
        game.lives = game.PLY_LIVES
        game.score = 0
        game.sound_musicplay = false
        game.msg = ""
        
        game.reset()
    end
    
    if key == "r" then
        leveldata.setTileAt(editor.level, editor.selectx, editor.selecty, editor.TIL_SWINGROPE)
        editor.init()
    end
    
    if key == "s" and not love.keyboard.isDown("lctrl") then
        leveldata.setTileAt(editor.level, editor.selectx, editor.selecty, editor.TIL_STRAIGHTROPE)
        editor.init()
    end
    
    if key == "f" then
        editor.remove_all_type("F")
        leveldata.setTileAt(editor.level, editor.selectx, editor.selecty, editor.TIL_FINISH)
        editor.init()
    end
    
    if key == "p" then
        editor.remove_all_type("P")
        leveldata.setTileAt(editor.level, editor.selectx, editor.selecty, editor.TIL_START)
        editor.init()
    end

    if key == "b" then
        leveldata.setTileAt(editor.level, editor.selectx, editor.selecty, editor.TIL_ENEMY)
        editor.init()
    end

    if key == "backspace" then
        if love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") and #leveldata.map > 1 then
            editor.delete_level(editor.level)
            editor.level = editor.level - 1
            editor.init()
        else
            leveldata.setTileAt(editor.level, editor.selectx, editor.selecty, editor.TIL_NULL)
            editor.init()
        end
    end
    
    if key == "l" then
        leveldata.map[editor.level][1][2] = (leveldata.map[editor.level][1][2] % levels.BAC_NUM) + 1
    end
    
    if key == "c" then leveldata.map[editor.level][1][3] = not leveldata.map[editor.level][1][3] end
    
    if key == "tab" and love.keyboard.isDown("rshift") then
        editor.insert_level(editor.level+1)
        editor.init()
    end
    if key == "tab" and love.keyboard.isDown("lshift") then
        editor.insert_level(editor.level)
        editor.init()
    end

    local keyn = tonumber(key)
    if keyn ~= nil then
        if keyn >= 1 and keyn <= #levels.tiles then
            leveldata.setTileAt(editor.level, editor.selectx, editor.selecty, "T"..keyn..":0:0:0:0:0")
            editor.init()
        end
    end
    
    if key == "s" and love.keyboard.isDown("lctrl")  then
        editor.msg = "Saving..."
        leveldata.save("levels.dat")
    end
    if key == "l" and love.keyboard.isDown("lctrl")  then
        editor.msg = "Loading..."
        leveldata.load("levels.dat")
        editor.level = 1
        editor.init()
    end
end

function editor.insert_level(pos)
    local blank_level = editor.deepcopy(leveldata.template)
    table.insert(leveldata.map, pos, blank_level)
end

function editor.delete_level(pos)
    table.remove(leveldata.map, pos)
end

function editor.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[editor.deepcopy(orig_key)] = editor.deepcopy(orig_value)
        end
        setmetatable(copy, editor.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function editor.remove_all_type(find_element)
    for y = 1, #leveldata.map[editor.level]-1 do
        for x = 1, #leveldata.map[editor.level][y] do
            local element, _ = leveldata.getBlock(editor.level, x, y)
            if element == find_element then
                leveldata.setTileAt(editor.level, x, y, editor.TIL_NULL)
            end
        end
    end
end

function editor.find_valid_param(param_start, dir)
    local element, _ = leveldata.getBlock(editor.level, editor.selectx, editor.selecty)
    
    local param = param_start
    local paramset = editor.find_validparamset(element)
    if paramset ~= nil then
        param = param + dir
        while param >= 1 and param <= #paramset-1 do
            if paramset[param+1][1] ~= "" then
                editor.params_select = param
                return
            end
            param = param + dir
        end
    end
    editor.params_select = param_start
end

function editor.update_editparams(key)
    if key == "left" then editor.find_valid_param(editor.params_select, -1) end
    if key == "right" then editor.find_valid_param(editor.params_select, 1) end
    if key == "up" then
        editor.change_param(1)
        editor.init()
    end
    if key == "down" then
        editor.change_param(-1)
        editor.init()
    end
    
    if key == "e" then editor.mode = "EDITSCENE" end
end

function editor.update_edittitle(key)
    if string.find(editor.KEY_VALID, key) ~= nil and string.len(leveldata.map[editor.level][1][1]) < editor.TIT_MAXLENGTH then
        if love.keyboard.isDown("lshift") then
            if key == "1" then key = "!"
            elseif key == "2" then key = "@"
            elseif key == "3" then key = "#"
            elseif key == "8" then key = "*"
            elseif key == "9" then key = "("
            elseif key == "0" then key = ")"
            elseif key == "/" then key = "?"
            else
                key = string.upper(key)
            end
        end
        leveldata.map[editor.level][1][1] = leveldata.map[editor.level][1][1]..key
    elseif key == "backspace" and string.len(leveldata.map[editor.level][1][1]) > 0 then
        leveldata.map[editor.level][1][1] = string.sub(leveldata.map[editor.level][1][1], 1, -2)        
    elseif key == "return" then editor.mode = "EDITSCENE"
    end
end

function editor.update_showinfo(key)
    if key == "i" then editor.mode = "EDITSCENE" end
end

function editor.change_param(dir)
    local element, params = leveldata.getBlock(editor.level, editor.selectx, editor.selecty)
    local args = leveldata.mysplit(params, ":")
    
    local paramset = editor.find_validparamset(element)
    if paramset ~= nil then
        local newp = tonumber(args[editor.params_select]) + (dir*tonumber(paramset[editor.params_select+1][4]))
        if newp >= tonumber(paramset[editor.params_select+1][2]) and newp <= tonumber(paramset[editor.params_select+1][3]) then
            args[editor.params_select] = tostring(newp)
            local new_str = element..leveldata.myjoin(args, ":")
            leveldata.setTileAt(editor.level, editor.selectx, editor.selecty, new_str)
            return
        end
    end
end

function editor.draw()
    if editor.mode == "EDITSCENE" or editor.mode == "EDITPARAMS" or editor.mode == "EDITTITLE" then editor.draw_editor()
    elseif editor.mode == "PLAY" then game.draw()
    elseif editor.mode == "SHOWINFO" then editor.draw_showinfo()
    end
end

function editor.draw_editor()
    love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
    local apd = ""
    if editor.mode == "EDITTITLE" then apd = "_" end
    love.graphics.printf(leveldata.map[editor.level][1][1]..apd, 0, 6, 320, "center")

    levels.draw(editor.level)
    player.draw()
    
    editor.draw_grid()
    editor.draw_cursor()
    editor.draw_params()
    
    love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255 ))
    love.graphics.printf(editor.level.."/"..#leveldata.map, 200, 230, 120, "right")
    
    for t = 1, #levels.tiles do
        love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255, 140 ))
        love.graphics.draw(levels.tiles[t], (t-1)*leveldata.TIL_SIZE, 240-leveldata.TIL_SIZE)
        love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255 ))
        love.graphics.printf(t, (t-1)*leveldata.TIL_SIZE, 231, leveldata.TIL_SIZE, "center")
    end
    love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255, 150 ))
    love.graphics.draw(ropes.bell_image, 160, 240-leveldata.TIL_SIZE)
    love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255 ))
    love.graphics.printf("R/S", 160, 231, leveldata.TIL_SIZE, "center")
    love.graphics.draw(ropes.bell_image, 180, 240-leveldata.TIL_SIZE)
    love.graphics.printf("F", 180, 231, leveldata.TIL_SIZE, "center")
    
    love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255, 140 ))
    love.graphics.draw(enemies.images[1][1], 200, 240-leveldata.TIL_SIZE)
    love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255 ))
    love.graphics.printf("B", 200, 231, leveldata.TIL_SIZE, "center")

    if editor.msg ~= "" then
        love.graphics.setColor(love.math.colorFromBytes( 0, 0, 0 ))
        love.graphics.rectangle( "fill", 85, 100, 150, 40 )
        love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255 ))
        love.graphics.printf(editor.msg, 100, 118, 120, "center")
    end
end

function editor.draw_grid()
    love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255, 10 ))
    for y = 1, 14 do
        for x = 0, 20 do
            local posx = x * leveldata.TIL_SIZE
            local posy = y * leveldata.TIL_SIZE
            editor.drawLine(0, posy, 320, posy, 3)
            editor.drawLine(posx, leveldata.TIL_SIZE, posx, 240-leveldata.TIL_SIZE, 3)
        end
    end
end

-- drawLine function courtesy of Anickyan
function editor.drawLine(x1, y1, x2, y2, interval)
    love.graphics.setPointSize(1)

    local x, y = x2 - x1, y2 - y1
    local len = math.sqrt(x^2 + y^2)
    local stepx, stepy = x / len, y / len
    x = x1
    y = y1

    for i = 1, len do
        if i % interval == 0 then love.graphics.point(x, y) end
        x = x + stepx
        y = y + stepy
    end
end

function editor.draw_cursor()
    local x, y = (editor.selectx-1)*leveldata.TIL_SIZE, editor.selecty*leveldata.TIL_SIZE
    if editor.mode == "EDITSCENE" then
        love.graphics.setColor(love.math.colorFromBytes(255, 0, 0))
    else
        love.graphics.setColor(love.math.colorFromBytes(128, 0, 0))
    end
    love.graphics.setLineStyle("rough")
    love.graphics.rectangle("line", x, y, leveldata.TIL_SIZE, leveldata.TIL_SIZE)
end

function editor.find_validparamset(element)
    for e = 1, #editor.params_valid do
        local paramset = editor.params_valid[e]
        if paramset[1][1] == element then return paramset end
    end
    return nil
end

function editor.draw_params()
    local element, params = leveldata.getBlock(editor.level, editor.selectx, editor.selecty)
    local args = leveldata.mysplit(params, ":")
    
    love.graphics.setFont(gfx.font_small)
    local paramset = editor.find_validparamset(element)
    if paramset ~= nil then
        love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
        love.graphics.rectangle("fill", 0, 0, 320, 15)
        for a = 1, #args do
            if paramset[a+1][1] ~= "" then
                if editor.params_select == a and editor.mode == "EDITPARAMS" then
                    love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
                else
                    love.graphics.setColor(love.math.colorFromBytes(180, 180, 180))
                end
                love.graphics.printf(paramset[a+1][1]..":", ((a-1)*56), 6, 32, "right")
                love.graphics.printf(args[a], ((a-1)*56)+32, 6, 32, "left")
            end
        end
    end
    love.graphics.setFont(gfx.font_normal)
end

function editor.draw_showinfo()
    love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
    love.graphics.rectangle("fill", 20, 20, 280, 200)

    love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
    love.graphics.setFont(gfx.font_small)
    for i = 1, #editor.info do
        love.graphics.printf(editor.info[i], 20, 20 + ((i-1)*8), 260, "left")
    end
    love.graphics.setFont(gfx.font_normal)
end

return editor

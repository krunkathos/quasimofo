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

local levels = {}

local leveldata = require("leveldata")
local ropes = require("ropes")
local enemies = require("enemies")

levels.TIL_NUM = 7
levels.tiles = {}
levels.BAC_NUM = 3
levels.backgrounds = {}

function levels.collideScenery(level, dcoords)
    for c = 1, #dcoords do
        local dc = dcoords[c]
        if leveldata.getTileAt(level, dc[1], dc[2]) > 0 then return true end
    end
    return false
end

function levels.load()
    for i = 0, levels.TIL_NUM do
        levels.tiles[i] = love.graphics.newImage( "gfx/tiles/"..i..".png" )
    end
    for i = 1, levels.BAC_NUM do
        levels.backgrounds[i] = love.graphics.newImage( "gfx/backgrounds/"..i..".png" )
    end
    ropes.load()
    enemies.load()
end

function levels.init(level)
    ropes.init()
    enemies.init()
    
    local p_x = 20
    local p_y = 100
    local half_size = leveldata.TIL_SIZE/2
    for y = 1, #leveldata.map[level]-1 do
        for x = 1, #leveldata.map[level][y+1] do
            local element, param = leveldata.getBlock(level, x, y)
            local pos_x = ((x-1)*leveldata.TIL_SIZE)
            local pos_y = ((y-1)*leveldata.TIL_SIZE)+half_size
            if element == "R" or element == "S" then
                local args = leveldata.mysplit(param, ":")
                ropes.create(pos_x+math.floor(leveldata.TIL_SIZE/2), pos_y, tonumber(args[1]), tonumber(args[2]),
                    tonumber(args[3])/1000.0, tonumber(args[4]), tonumber(args[5]), tonumber(args[6]), false)
            elseif element == "F" then
                local args = leveldata.mysplit(param, ":")
                ropes.create(pos_x+math.floor(leveldata.TIL_SIZE/2), pos_y, 0, 180, 0.5, 1, tonumber(args[5]), 1, true)
            elseif element == "E" then
                local args = leveldata.mysplit(param, ":")
                enemies.create(tonumber(args[1]), pos_x, pos_y+(half_size*3),
                    tonumber(args[2]), tonumber(args[3]), tonumber(args[4]), tonumber(args[5]))
            elseif element == "P" then
                p_x = pos_x
                p_y = pos_y
            end
        end
    end
    return p_x, p_y
end

function levels.update(dt)
    ropes.update(dt)
    enemies.update(dt)
end

function levels.draw(level)
    love.graphics.setColor( 255, 255, 255 )
    love.graphics.draw(levels.backgrounds[leveldata.map[level][1][2]], 0, 18)
    if leveldata.map[level][1][3] then
        love.graphics.setColor( 0, 160, 0 )
        love.graphics.rectangle( "fill", 300, 3, 20, 12 )
        love.graphics.setColor( 0, 0, 0 )
        love.graphics.printf("CP", 302, 8, 18, "center")
        love.graphics.setColor( 255, 255, 255 )
        love.graphics.printf("CP", 300, 7, 20, "center")
    end

    ropes.draw()
    enemies.draw()
    for y = 1, #leveldata.map[level]-1 do
        for x = 1, #leveldata.map[level][y+1] do
            local element, param = leveldata.getBlock(level, x, y)
            local args = leveldata.mysplit(param, ":")
            if element == "T" and args[1] ~= "0" then
                love.graphics.draw(levels.tiles[tonumber(args[1])],
                    (x-1)*leveldata.TIL_SIZE, (y*leveldata.TIL_SIZE))
            end
        end
    end
end

return levels

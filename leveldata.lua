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

local leveldata = {}

require("lib/Tserial")

leveldata.TIL_SIZE = 16

leveldata.template ={
    { "<title>", 2, false },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" },
    { "T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0","T0:0:0:0:0:0" }
}

function leveldata.save(filename)
    love.filesystem.write(filename, Tserial.pack(leveldata.map, nil, true))
end

function leveldata.load(filename)
    if love.filesystem.getInfo(filename) then
        leveldata.map = Tserial.unpack(love.filesystem.read(filename))
    else
        print("**** Could not open file "..filename)
    end
end

function leveldata.save_checkpoint(filename, new_cp)
    love.filesystem.write(filename, Tserial.pack({ new_cp }, nil, true))
end

function leveldata.load_checkpoint(filename)
    local level = { 0 }
    if love.filesystem.getInfo(filename) then
        level = Tserial.unpack(love.filesystem.read(filename))
    end
    return level[1]
end

function leveldata.update_checkpoint(filename, new_cp)
    if love.filesystem.getInfo(filename) then
        local old_cp = leveldata.load_checkpoint(filename)
        if new_cp > old_cp then leveldata.save_checkpoint(filename, new_cp) end
    else
        leveldata.save_checkpoint(filename, new_cp)
    end
end

function leveldata.getXY(level, x, y)
    local tx = math.floor(x / leveldata.TIL_SIZE) + 1
    local ty = math.floor(y / leveldata.TIL_SIZE)
    if ty < 1 then ty = 1 end
    if ty > #leveldata.map[level]-1 then ty = #leveldata.map[level]-1 end
    if tx < 1 then tx = 1 end
    if tx > #leveldata.map[level][ty+1] then tx = #leveldata.map[level][ty+1] end
    return tx, ty
end

function leveldata.getTileAt(level, x, y)
    local tx, ty = leveldata.getXY(level, x, y)
    local element, param = leveldata.getBlock(level, tx, ty)
    local args = leveldata.mysplit(param, ":")
    if element == "T" then return tonumber(args[1]) end
    return 0
end

function leveldata.getBlock(level, x, y)
    local str = leveldata.map[level][y+1][x]
    return string.sub(str, 1, 1), string.sub(str, 2, -1)
end

function leveldata.setTileAt(level, x, y, str)
    leveldata.map[level][y+1][x] = str
end

-- mysplit function courtesy of SuperFastNinja, stackoverflow.com
function leveldata.mysplit(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t={}
    local i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function leveldata.myjoin(args, sep)
    local str = ""
    for a = 1, #args do
        str = str..args[a]
        if a < #args then str = str..sep end
    end
    return str
end

return leveldata

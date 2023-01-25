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

local ropes = {}

-- constants
ropes.ROP_POINTMAX = 15
ropes.ROP_UPDELAY = 0.06
ropes.ROP_GRABDIST = 5

ropes.threads = {}
ropes.paths = {}
ropes.upCount = -1

ropes.bell_image = nil
ropes.bellsilver_image = nil

function ropes.load()
    ropes.bell_image = love.graphics.newImage("gfx/bell-gold.png")
    ropes.bellsilver_image = love.graphics.newImage("gfx/bell-silver.png")
end

function ropes.generate(angle, pathspd, widthfac, heightfac)
    -- do a quick simulation with basic acceleration
    -- to precalculate a rope swing
    -- only do half the swing, since
    -- we can duplicate that half to the other side
    local accel = 0
    local left_path = {}
    local right_path = {}
    while angle >= 180 do
        local lpath = {}
        local rpath = {}
        for o = 1, ropes.ROP_POINTMAX do
            local lpoint = {}
            lpoint.x = math.sin(math.rad(angle+((angle-180)*o*0.0426))) * (o*widthfac*0.6667)
            lpoint.y = 15+(math.cos(math.rad(angle+((angle-180)*o*0.0426))) * (o*-heightfac*0.6667))
            table.insert(lpath, lpoint)
            local rpoint = {}
            rpoint.x = -lpoint.x
            rpoint.y = lpoint.y
            table.insert(rpath, rpoint)
        end
        table.insert(left_path, lpath)
        table.insert(right_path, 1, rpath)
        accel = accel + pathspd
        angle = angle - accel
    end
    
    -- add what we have for the right hand side
    -- onto left side
    for o = 1, #right_path do
        table.insert(left_path, right_path[o])
    end
    
    return left_path
end

function ropes.init()
    ropes.threads = {}
    ropes.upCount = 0
end

function ropes.create(x, y, offset, angle, pathspd, widthfac, heightfac, direction, finish)
    local rope = {}
    rope.x = x
    rope.y = y
    rope.paths = ropes.generate(angle, pathspd, widthfac, heightfac)
    rope.counter = math.floor(offset * (#rope.paths-2)) + 1
    rope.direction = direction
    rope.finish = finish
    table.insert(ropes.threads, rope)
end

function ropes.collideWithRopes(x, y)
    local col_thread = -1
    local col_point = -1
    
    for t = 1, #ropes.threads do
        local rope = ropes.threads[t]
        local path = rope.paths[rope.counter]
        for p = 1, #path do
            local point = path[p]
            if math.sqrt(math.pow((rope.x + point.x - x), 2) + math.pow((rope.y + point.y - y), 2)) < ropes.ROP_GRABDIST then
                return t, p
            end
        end
    end
    return col_thread, col_point
end

function ropes.update(dt)
    ropes.upCount = ropes.upCount + dt
    if ropes.upCount < ropes.ROP_UPDELAY then return end
    ropes.upCount = 0
    
    for rope = 1, #ropes.threads do
        local r = ropes.threads[rope]
        r.counter = r.counter + r.direction
        if r.counter >= #r.paths or r.counter <= 1 then r.direction = -r.direction end
    end
end

function ropes.draw()
    love.graphics.setLineStyle( "rough" )
    love.graphics.setLineWidth( 1 )
    for t = 1, #ropes.threads do
        love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255 ))
        local rope = ropes.threads[t]
        local path = rope.paths[rope.counter]
        for o = 2, #path do
            local pPoint, cPoint = path[o-1], path[o]
            love.graphics.line( rope.x + pPoint.x, rope.y + pPoint.y, rope.x + cPoint.x, rope.y + cPoint.y )
        end
        local image = ropes.bellsilver_image
        if rope.finish then image = ropes.bell_image end
        love.graphics.draw(image, math.floor(rope.x-(ropes.bell_image:getWidth()/2)), math.floor(rope.y+10))
    end
end

return ropes

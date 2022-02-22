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

local enemies = {}

enemies.objects = {}
enemies.images = {}

enemies.display_all = false

function enemies.collideEnemy(x1, y1, w1, h1, e)
    local w2 = enemies.images[e.enemytype][e.image_count]:getWidth()
    local h2 = enemies.images[e.enemytype][e.image_count]:getHeight()
        
    return x1 < e.x+w2 and
        e.x < x1+w1 and
        y1 < (e.y-h2)+h2 and
        (e.y-h2) < y1+h1
end

function enemies.checkEnemyCollision(x1, y1, w1, h1)
    for o = 1, #enemies.objects do
        local e = enemies.objects[o]
        if e.appeardelay >= e.appeardelay_count and enemies.collideEnemy(x1, y1, w1, h1, e) then return true end
    end
    return false
end

function enemies.load()
    local arrow = {}
    table.insert(arrow, love.graphics.newImage("gfx/enemies/arrow-1.png"))
    table.insert(arrow, love.graphics.newImage("gfx/enemies/arrow-2.png"))
    table.insert(arrow, love.graphics.newImage("gfx/enemies/arrow-3.png"))
    table.insert(arrow, love.graphics.newImage("gfx/enemies/arrow-2.png"))
    table.insert(enemies.images, arrow)
    
    local polearm = {}
    table.insert(polearm, love.graphics.newImage("gfx/enemies/polearm-1.png"))
    table.insert(polearm, love.graphics.newImage("gfx/enemies/polearm-1.png"))
    table.insert(polearm, love.graphics.newImage("gfx/enemies/polearm-2.png"))    
    table.insert(enemies.images, polearm)

    local soldier = {}
    table.insert(soldier, love.graphics.newImage("gfx/enemies/soldier.png"))
    table.insert(enemies.images, soldier)

    local polearm2 = {}
    table.insert(polearm2, love.graphics.newImage("gfx/enemies/polearm-1.png"))
    table.insert(enemies.images, polearm2)
end

function enemies.init()
    enemies.objects = {}
end

function enemies.create(enemytype, x, y, dx, dy, appeardelay, animdelay)
    local e = {}
    e.enemytype = enemytype
    e.startx = x
    e.starty = y
    e.x = x
    e.y = y
    e.dx = dx
    e.dy = dy
    e.appeardelay = 0
    e.appeardelay_count = appeardelay
    e.image_count = 1
    e.image_animcount = 0
    e.image_animdelay = animdelay
    if dx < 0 then e.image_flip = -1 else e.image_flip = 1 end
    table.insert(enemies.objects, e)
end

function enemies.update(dt)
    for i = 1, #enemies.objects do
        local e = enemies.objects[i]
        if e.appeardelay >= e.appeardelay_count then
            e.x = e.x + e.dx * (dt*60)
            e.y = e.y + e.dy * (dt*60)
            if (e.x > 304 or e.x < 0) or (e.y < 24 or e.y > 240) then
                e.x = e.startx
                e.y = e.starty
                e.appeardelay = 0
            end
            
            e.image_animcount = e.image_animcount + dt
            if e.image_animcount > e.image_animdelay then
                e.image_animcount = 0
                e.image_count = e.image_count + 1
                if e.image_count > #enemies.images[e.enemytype] then e.image_count = 1 end
            end
        else
            e.appeardelay = e.appeardelay + dt
        end
    end
end

function enemies.draw()
    local offx
    
    love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255 ))
    for i = 1, #enemies.objects do
        local e = enemies.objects[i]
        if e.appeardelay >= e.appeardelay_count or enemies.display_all then
            local image = enemies.images[e.enemytype][e.image_count]
            if e.image_flip == -1 then offx = math.floor(image:getWidth()) else offx = 0 end
            love.graphics.draw(image, math.floor(e.x)+offx, math.floor(e.y)-image:getHeight(), 0, e.image_flip, 1, 0)
        end
    end
end

return enemies

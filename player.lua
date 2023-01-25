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

local player = {}

local levels = require("levels")
local ropes = require("ropes")
local enemies = require("enemies")

-- constants --
player.COL_DX1 = 0
player.COL_DY1 = 4
player.COL_DX2 = -4
player.COL_DY2 = -1
player.WLK_SPEED = 32

player.PLY_ANIMMAX = 0.08
player.CLB_DELAYMAX = 0.2
player.JMP_ACCEL = 70

-- our player --
player.x = -1
player.y = -1
player.y_accel = 0
player.climb_delay = player.CLB_DELAYMAX
player.jumping = false
player.falling = false
player.rope_grip = ""
player.rope_thread = -1
player.rope_point = -1
player.images = {}
player.image_flip = -1
player.image_count = -1
player.image_animcount = 0
player.death = false

-- resources --
player.sound_music = nil
player.sound_jump = nil
player.sound_hurt = nil
player.sound_death = nil
player.sound_complete = nil

function player.load()
    table.insert(player.images, love.graphics.newImage("gfx/player/6.png"))
    table.insert(player.images, love.graphics.newImage("gfx/player/1.png"))
    table.insert(player.images, love.graphics.newImage("gfx/player/2.png"))
    table.insert(player.images, love.graphics.newImage("gfx/player/3.png"))
    table.insert(player.images, love.graphics.newImage("gfx/player/4.png"))
    table.insert(player.images, love.graphics.newImage("gfx/player/5.png"))

    player.sound_jump = love.audio.newSource("sounds/jump.wav", "static")
    player.sound_jump:setVolume(0.2)
    player.sound_hurt = love.audio.newSource("sounds/hurt.wav", "static")
    player.sound_hurt:setVolume(0.5)
    player.sound_death = love.audio.newSource("sounds/death.wav", "static")
    player.sound_death:setVolume(0.4)
    player.sound_death:setPitch(0.5)
    player.sound_complete = love.audio.newSource("sounds/complete.wav", "static")
    player.sound_complete:setVolume(0.4)
end

function player.init(px, py)
    player.x = px
    player.y = py
    player.y_accel = 0
    player.climb_delay = player.CLB_DELAYMAX
    player.falling = false
    player.jumping = false
    player.rope_grip = "no"
    player.rope_thread = -1
    player.rope_point = 0
    player.image_count = 2
    player.image_animcount = 0
    player.image_flip = 1
    player.death = false
end

function player.incrementAnim(dt)
    if player.jumping then return end
    player.image_animcount = player.image_animcount + dt
    if player.image_animcount > player.PLY_ANIMMAX then
        player.image_animcount = 0
        player.image_count = player.image_count + 1
        if player.image_count > #player.images then player.image_count = 3 end
    end
end

function player.left(dt)
    player.image_flip = -1
    player.incrementAnim(dt)
    return player.x - (dt * player.WLK_SPEED)
end

function player.right(dt)
    player.image_flip = 1
    player.incrementAnim(dt)
    return player.x + (dt * player.WLK_SPEED)
end

function player.up(dt)
    if player.climb_delay < 0 then
        if player.rope_point > 2 then player.rope_point = player.rope_point - 1 end
        player.climb_delay = player.CLB_DELAYMAX
    else
        player.climb_delay = player.climb_delay - dt
    end
end

function player.down(dt)
    if player.climb_delay < 0 then
        if player.rope_point < ropes.ROP_POINTMAX then
            player.rope_point = player.rope_point + 1
        else
            player.rope_grip = "left"
            player.falling = true
        end
        player.climb_delay = player.CLB_DELAYMAX
    else
        player.climb_delay = player.climb_delay - dt
    end
end

function player.jump(dt)
    player.y_accel = player.JMP_ACCEL
    player.jumping = true
    player.sound_jump:play()
    player.image_count = 1
    
    if player.rope_grip == "yes" then player.rope_grip = "left" end
end

function player.collide()
    if player.y_accel <= 0 then
        player.falling = false
        player.jumping = false
    end
    player.y_accel = 0
    player.rope_grip = "no"
end

function player.grab_rope(colT, colP)
    player.rope_grip = "yes"
    player.rope_thread = colT
    player.rope_point = colP
    
    player.falling = false
    player.jumping = false
    player.y_accel = 0
end

function player.update_player_on_rope()
    local rope = ropes.threads[player.rope_thread]
    local path = rope.paths[rope.counter]
    local point = path[player.rope_point]
    player.x = rope.x + point.x - 6
    player.y = rope.y + point.y - 12
end

function player.remember_last_rope()
    player.rope_thread = -1
    player.rope_point = -1
    player.rope_grip = "no"
end

function player.update(dt, level)
    local status = ""
    
    local new_x
    if love.keyboard.isDown("z") and player.x > 8 then new_x = player.left(dt) end
    if love.keyboard.isDown("x") and player.x < 312 then new_x = player.right(dt) end
    if new_x then
        if not levels.collideScenery(level,
            {{new_x + player.COL_DX1, player.y + player.COL_DY1},
            {new_x + player.images[1]:getWidth() + player.COL_DX2, player.y + player.COL_DY1},
            {new_x + player.COL_DX1, player.y + math.floor(player.images[1]:getHeight()/2)},
            {new_x + player.images[1]:getWidth() + player.COL_DX2, player.y + math.floor(player.images[1]:getHeight()/2)},
            {new_x + player.COL_DX1, player.y + player.images[1]:getHeight() + player.COL_DY2},
            {new_x + player.images[1]:getWidth() + player.COL_DX2, player.y + player.images[1]:getHeight() + player.COL_DY2}}) then
            player.x = new_x end
    elseif not player.jumping then
        player.image_count = 2
    end
    
    if (love.keyboard.isDown("p") or love.keyboard.isDown("l"))
        and player.rope_grip == "left" then player.remember_last_rope() end
    if love.keyboard.isDown("p") and player.rope_grip == "yes" then player.up(dt) end
    if love.keyboard.isDown("l") and player.rope_grip == "yes" then player.down(dt) end
    if love.keyboard.isDown("space") and not player.falling then player.jump(dt) end
    
    if player.rope_grip ~= "yes" then player.y_accel = player.y_accel - (dt * 120) end    
    
    -- drop player, if new position doesn't collide
    local new_y = player.y - (player.y_accel*dt*1.2)
    if new_y < 20 then
        new_y = 20
        player.y_accel = 0
    end
    if levels.collideScenery(level,
            {{player.x + player.COL_DX1, new_y + player.COL_DY1},
            {player.x + player.images[1]:getWidth() + player.COL_DX2, new_y + player.COL_DY1},
            {player.x + player.COL_DX1, new_y + player.images[1]:getHeight() + player.COL_DY2},
            {player.x + player.images[1]:getWidth() + player.COL_DX2, new_y + player.images[1]:getHeight() + player.COL_DY2}}) then
        player.collide()
    elseif player.rope_grip == "no" or player.rope_grip == "left" then
        player.falling = true
        player.y = new_y
    end
    
    -- enemy collision?
    local offx
    if player.image_flip == -1 then offx = -2 else offx = 0 end
    if enemies.checkEnemyCollision(player.x+offx+player.COL_DX1, player.y + player.COL_DY1-2, player.images[1]:getWidth()+player.COL_DX2, player.images[1]:getHeight() + player.COL_DY2-2) or player.y > 240 then
        player.sound_hurt:play()
        player.sound_death:play()
        player.death = true
        status = "lost_life"
    end
    
    -- manage rope grabbing and hanging
    local colT, colP = ropes.collideWithRopes(player.x+6, player.y+10)
    if colT ~= -1 and (player.rope_grip == "no" or (player.rope_grip == "left" and player.rope_thread ~= colT)) then
        player.grab_rope(colT, colP)
        if ropes.threads[colT].finish then
            status = "level_complete"
            player.sound_complete:play()
        end
    end
    if player.rope_grip == "yes" then player.update_player_on_rope() end
    
    --if love.keyboard.isDown("t") then status = "level_complete" end
    
    return status
end

function player.draw()
    local offx = 0
    love.graphics.setColor(love.math.colorFromBytes( 255, 255, 255 ))
    if not player.death then
        if player.image_flip == -1 then offx = 12 end
        love.graphics.draw(player.images[player.image_count], math.floor(player.x)+offx, math.floor(player.y), 0, player.image_flip, 1, 0)
    else
        love.graphics.draw(player.images[2], math.floor(player.x)-4, math.floor(player.y)+26, math.rad(-90), 1, 1, 0)
    end
end

return player

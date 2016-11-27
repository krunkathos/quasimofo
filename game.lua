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

local game = {}

local player = require("player")
local levels = require("levels")
local leveldata = require("leveldata")
local enemies = require("enemies")
local highscores = require("highscores")

game.BAN_X = 8
game.BAN_Y = 194
game.PLY_LIVES = 4
game.STA_DELAYMAX = 2.0

game.mode = ""
game.mode_count = 0
game.msg = ""

game.sound_music = nil
game.sound_musicplay = true
game.sound_endmusic = nil
game.sound_checkpoint = nil

game.level = 1
game.lives = -1
game.score = -1

game.life_image = nil
game.princess_image = nil
game.heart_image = nil
game.badguy_image = nil

function game.load()
    game.life_image = love.graphics.newImage("gfx/life.png")
    game.princess_image = love.graphics.newImage("gfx/tiles/7.png")
    game.heart_image = love.graphics.newImage("gfx/heart.png")
    game.badguy_image = love.graphics.newImage("gfx/enemies/soldier.png")
    
    game.sound_music = love.audio.newSource("music/gamemusic.mp3")
    game.sound_music:setLooping(true)
    
    game.sound_endmusic = love.audio.newSource("music/endmusic.mp3")
    game.sound_endmusic:setLooping(true)
    
    game.sound_checkpoint = love.audio.newSource("sounds/wooble.wav", "static")

    leveldata.load("levels.dat")
    levels.load()
    player.load()
end

function game.init()
    game.mode = "INTRO"
    game.level = 1
    game.lives = game.PLY_LIVES
    game.score = 0
    
    game.msg = "The Princess is kidnapped!"
    game.mode_count = 0
    game.sound_musicplay = true

    game.reset()
end

function game.continue(level)
    game.mode = "GETREADY"
    
    game.level = level
    game.lives = game.PLY_LIVES
    game.score = 0

    game.msg = "Get Ready!"
    game.mode_count = 0
    game.sound_musicplay = true

    game.reset()
end

function game.reset()
    if game.sound_musicplay then game.sound_music:play() end
    local px, py = levels.init(game.level)
    player.init(px, py)
    enemies.display_all = false
end

function game.exit()
    game.sound_music:stop()
    game.sound_endmusic:stop()
    game.mode_count = 0
end

function game.inc_statedelay(dt, fac)
    game.mode_count = game.mode_count + dt
    if game.mode_count > game.STA_DELAYMAX * fac then
        game.mode_count = 0
        return true
    end
    return false
end

function game.update(dt)
    if game.mode == "INTRO" then
        if game.inc_statedelay(dt, 2.5) then
            game.msg = "Get Ready!"
            game.mode = "GETREADY"
        end
        return        
    elseif game.mode == "GETREADY" then
        if game.inc_statedelay(dt, 1.0) then
            game.msg = ""
            game.mode = "PLAY"
        end
        return
    elseif game.mode == "DEATH" then
        if game.inc_statedelay(dt, 1.0) then
            game.lives = game.lives - 1
            if game.lives > 0 then
                game.reset()
                game.msg = ""
                game.mode = "PLAY"
            else
                game.msg = "GAME OVER"
                game.mode = "GAMEOVER"
            end
        end
        return
    elseif game.mode == "PLAY" then
        levels.update(dt)
        local status = player.update(dt, game.level)
        if status == "lost_life" then
            game.sound_music:pause()
            game.msg = "You died."
            game.mode = "DEATH"
        elseif status == "level_complete" then
            game.msg = "Well Done!"
            if leveldata.map[game.level][1][3] then
                leveldata.update_checkpoint("checkpoint.dat", game.level)
                game.sound_checkpoint:play()
                game.msg = game.msg.."\nCheckpoint!"
            end
            game.mode = "LEVELDONE"
        end
    elseif game.mode == "LEVELDONE" then
        if game.inc_statedelay(dt, 1.0) then
            if game.level == #leveldata.map then
                game.score = game.score + 1000
                game.sound_music:stop()
                if game.sound_musicplay then game.sound_endmusic:play() end
                game.mode = "GAMECOMPLETE"
            else
                game.score = game.score + 100
                game.level = game.level + 1
                game.reset()
                game.msg = ""
                game.mode = "PLAY"
            end
        end
    elseif game.mode == "GAMECOMPLETE" then
        if game.inc_statedelay(dt, 14.85) or love.keyboard.isDown(" ") then
            game.sound_endmusic:stop()
            game.mode_count = 0
            game.level = 1
            game.reset()
            game.msg = ""
            game.mode = "PLAY"
        end
    elseif game.mode == "GAMEOVER" then
        if game.inc_statedelay(dt, 1.0) then
            if highscores.achieved_highscore(game.score) then
                game.mode = "ENTERHISCORE"
            else
                game.mode = "EXITGAME"
            end
        end
    end
end

function game.keyreleased(key)
    if game.mode == "ENTERHISCORE" then
        if key == "return" then
            highscores.register(game.score, highscores.enter_name)
            highscores.save()
            game.mode = "EXITGAME"
        else
            highscores.keyreleased(key)
        end
    elseif key == "m" then
        game.sound_musicplay = not game.sound_musicplay
        if game.sound_musicplay then game.sound_music:play() else game.sound_music:pause() end
    end
end

function game.draw()    
    levels.draw(game.level)
    player.draw()
    game.draw_levelview()
    
    love.graphics.setColor( 255, 255, 255 )
    love.graphics.print("SCORE  "..game.score, 120, 3)
    love.graphics.setColor( 180, 255, 255 )
    love.graphics.print("LIVES", 120, 12)
    
    love.graphics.setColor( 255, 255, 255 )
    for l = 1, game.lives do
        love.graphics.draw(game.life_image, 176 + ((l-1)*8), 9)
    end

    love.graphics.setColor( 0, 0, 0 )
    love.graphics.rectangle( "fill", 0, 224, 320, 16 )
    love.graphics.setColor( 255, 255, 255 )
    love.graphics.printf(leveldata.map[game.level][1][1], 0, 230, 320, "center")
    
    if game.msg ~= "" then
        love.graphics.setColor( 0, 0, 0 )
        love.graphics.rectangle( "fill", 85, 100, 150, 40 )
        love.graphics.setColor( 255, 255, 255 )
        love.graphics.printf(game.msg, 100, 118, 120, "center")
    end
    
    if game.mode == "INTRO" then game.draw_intro()
    elseif game.mode == "GAMECOMPLETE" then game.draw_ending()
    elseif game.mode == "ENTERHISCORE" then highscores.draw_entername()
    end
end

function game.draw_levelview()
    local bLevels = #leveldata.map-5
    local bWidth = (bLevels * 4) + 4 + 4 + 6
    
    love.graphics.setColor( 255, 255, 255 )
    love.graphics.rectangle( "fill", game.BAN_X, game.BAN_Y, bWidth, 26 )
    love.graphics.setColor( 0, 0, 0 )
    love.graphics.rectangle( "fill", game.BAN_X+2, game.BAN_Y+2, bWidth-4, 22 )
    
    love.graphics.setColor( 50, 50, 50 )
    love.graphics.setLineStyle( "rough" )
    love.graphics.setLineWidth( 1 )
    for l = 0, bLevels-1 do
        local lx = game.BAN_X + (l*4) + 4
        local ly = game.BAN_Y+13
        love.graphics.rectangle( "fill", lx, ly, 2, 9 )
        love.graphics.rectangle( "fill", lx+2, ly+2, 2, 7 )
    end
    love.graphics.rectangle( "fill",
        game.BAN_X + (bLevels*4) + 4, game.BAN_Y + 6, 6, 16 )

    love.graphics.setColor( 0, 0, 0 )
    love.graphics.rectangle( "fill",
        game.BAN_X + (bLevels*4) + 6, game.BAN_Y + 8, 2, 4 )

    love.graphics.setColor( 255, 255, 255 )
    local x, y
    if game.level <= bLevels then
        x = game.BAN_X + ((game.level-1)*4) + 4
        y = game.BAN_Y + 10
    else
        x = game.BAN_X + (bLevels*4) + 4 + 2
        y = game.BAN_Y + 11 - (game.level - bLevels)
    end
    love.graphics.rectangle( "fill", x, y, 2, 2 )
end

function game.draw_intro()
    local prin_x = 290
    if game.mode_count > 2.0 then
        prin_x = 290+((game.mode_count-2.0)*16)
    end
    love.graphics.draw(game.princess_image, math.floor(prin_x), 98)
    love.graphics.draw(game.badguy_image, math.floor(prin_x)+7, 98)
    love.graphics.setColor( 0, 0, 0 )
    love.graphics.rectangle( "fill", 320, 0, 200, 240 )    
end

function game.draw_ending()
    love.graphics.setColor( 0, 0, 0 )
    love.graphics.rectangle( "fill", 0, 0, 330, 240 )
    
    love.graphics.setColor( 255, 255, 255 )
    love.graphics.printf("Congratulations!",30, 50, 260, "center")
    for y = 70, 170, 50 do
        for x = 60, 260, 50 do
            love.graphics.draw(game.heart_image, x-8, y)
        end
    end
    love.graphics.draw(player.images[2], 139, 114)
    love.graphics.draw(game.princess_image, 165, 112)
    if game.mode_count > 4.0 then
        love.graphics.printf("And they lived happily ever after",20, 200, 280, "center")
    end
    if game.mode_count > 15.5 then
        love.graphics.printf("...until she's kidnapped AGAIN!",20, 212, 280, "center")
    end
end

return game

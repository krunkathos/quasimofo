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

local highscores = {}

require("lib/Tserial")

highscores.HIS_FILENAME = "highscores.dat"
highscores.KEY_VALID = " abcdefghijklmnopqrstuvwxyz0123456789/."
highscores.TIT_MAXLENGTH = 38

highscores.scores = {}
highscores.enter_name = ""

function highscores.load()
    if love.filesystem.getInfo(highscores.HIS_FILENAME) then
        highscores.scores = Tserial.unpack(love.filesystem.read(highscores.HIS_FILENAME))
    else
        print("**** Could not open file "..highscores.HIS_FILENAME)
    end
    highscores.enter_name = ""
end

function highscores.save()
    love.filesystem.write(highscores.HIS_FILENAME, Tserial.pack(highscores.scores, nil, true))
end

function highscores.achieved_highscore(score)
    if score > highscores.scores[10][2] then return true else return false end
end

function highscores.register(score, name)
    local entry = { name, score }
    for s = 1, #highscores.scores do
        if score > highscores.scores[s][2] then
            table.insert(highscores.scores, s, entry)
            table.remove(highscores.scores, 11)
            return
        end
    end
end

function highscores.keyreleased(key)
    if string.find(highscores.KEY_VALID, key) ~= nil and string.len(highscores.enter_name) < highscores.TIT_MAXLENGTH then
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
        highscores.enter_name = highscores.enter_name..key
    elseif key == "backspace" and string.len(highscores.enter_name) > 0 then
        highscores.enter_name = string.sub(highscores.enter_name, 1, -2)        
    end
end

function highscores.draw_scores()
    love.graphics.setColor(love.math.colorFromBytes( 0, 0, 0 ))
    love.graphics.rectangle( "fill", 0, 0, 320, 240 )

    love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
    love.graphics.printf("High Scores", 10, 10, 300, "center")
    for s = #highscores.scores, 1, -1 do
        love.graphics.setColor(love.math.colorFromBytes(180, 255, 180))
        love.graphics.printf(highscores.scores[s][1], 60, 34 + ((s-1)*20), 160, "left")
        love.graphics.setColor(love.math.colorFromBytes(180, 180, 255))
        love.graphics.printf(highscores.scores[s][2], 230, 34 + ((s-1)*20), 150, "left")
    end
end

function highscores.draw_entername()
    love.graphics.setColor(love.math.colorFromBytes( 0, 0, 0 ))
    love.graphics.rectangle( "fill", 10, 100, 300, 64 )

    love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
    love.graphics.printf("You achieved a high score!", 10, 110, 300, "center")    
    love.graphics.printf("Enter your name:", 10, 122, 300, "center")    
    love.graphics.printf(highscores.enter_name.."_", 10, 146, 300, "center")    
end

return highscores

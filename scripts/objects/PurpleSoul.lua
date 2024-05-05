local PurpleSoul, super = Class(Soul)

function PurpleSoul:init(x, y)
    super:init(self, x, y)

    self.color = { 0.83529411764, 0.20784313725, 0.85098039215 }

    -- Variables that can be changed
    self.string_count = 1         -- How many strings are there? [real] (any number)
    self.direction = "horizontal" -- How are the strings laid out? [string] ("horizontal"; "vertical")
    self.loop = false             -- Will going below or above the strings put you to the other end? [boolean] (true; false)

    self.current_string = 2       -- The current string of the soul [real] (any number)
    self.goal_y = self.y          -- The x or y value the soul is moving towards [real] (any number)


    self.dash_0 = { 15 / 255, 154 / 255, 1 }
    self.dash_1 = { 0.83529411764, 0.20784313725, 0.85098039215 }
    self.dash_2 = { 237 / 255, 34 / 255, 1 }
    self.dash_3 = { 245 / 255, 1, 17 / 255 }
    self.dash_4 = { 78 / 255, 1, 17 / 255 }

    -- Do not modify these variables

    self.dash_color = {
        self.dash_0,
        self.dash_1,
        self.dash_2,
        self.dash_3,
        self.dash_4
    }

    --charge up time for soul
    self.charge_up_time = 1.7

    self.max_dash = 1

    --cooldown
    self.based_time = 50

    self.null_time = 0

    self.dash_speed = 1

    self.trails = {}

    self.act_timer = 0

    self.hold_timer = 0
    self.charge_sfx = nil

    self.teaching = false

    self.allow_cheat = false

    self.can_shoot = true -- whether the soul is allowed to shoot in general

    self.can_use_bigshot = true

    self.moving_between_strings = false

    self.direction_moving_string = "nil"
end

function PurpleSoul:onWaveStart()
    self.dash = self.max_dash

    self.null_timer = self.based_time

    self.timer = self.null_time
end

function PurpleSoul:onStart()
    local arena = Game.battle.arena
end

function PurpleSoul:update()
    super:update(self)

    if self.transitioning then
        if self.charge_sfx then
            self.charge_sfx:stop()
            self.charge_sfx = nil
        end
        return
    end

    if not self:canShoot() then return end



    if Input.pressed("confirm") then
        print("input test check")
    end

    if Input.pressed("confirm") and self.hold_timer == 0 and false then -- fire normal shot
        print("normal shoot")
    end
    if self:canUseBigShot() then
        -- check release before checking hold, since if held is false it sets the timer to 0
        if Input.released("confirm") then                          -- fire big shot
            if self.hold_timer >= 10 and self.hold_timer < 40 then -- didn't hold long enough, fire normal shot
                -- self:fireShot(false)
                print("failed fire big shot")
            elseif self.hold_timer >= 40 then -- fire big shot
                if self.timer == self.null_time then
                    if self.dash ~= 0 and self:isMoving() then
                        if not ((self.direction_moving_string == "left" or self.direction_moving_string == "right") and self.direction == "vertical") and
                            not ((self.direction_moving_string == "down" or self.direction_moving_string == "up") and self.direction == "horizontal")
                        then
                            Assets.playSound("halberd_flash")

                            self.dash_active = true
                            self.dash = self.dash - 1
                            self.timer = 0
                            self.null_timer = 0
                            self.act_timer = 0
                        end
                    else
                        Assets.playSound("error")
                    end
                else
                    Assets.playSound("error")
                end



                print("sfire big shot")

                if self.teaching then
                    self.teaching = false
                end
                if self:canCheat() and Input.down("confirm") then -- they are cheating
                    self:onCheat()
                end
            end
            if not self:canCheat() then -- reset hold timer if cheating is disabled
                self.hold_timer = 0
            end
        end

        if Input.down("confirm") then -- charge a big shot
            self.hold_timer = self.hold_timer + DTMULT * self.charge_up_time

            if self.hold_timer >= 20 and not self.charge_sfx then -- start charging sfx
                self.charge_sfx = Assets.getSound("chargeshot_charge")
                self.charge_sfx:setLooping(true)
                self.charge_sfx:setPitch(0.1)
                self.charge_sfx:setVolume(0)
                local timer = 0
                Game.battle.timer:during(2 / 3, function()
                    timer = timer + DT
                    if self.charge_sfx then
                        self.charge_sfx:setVolume(Utils.clampMap(timer, 0, 2 / 3, 0, 0.3))
                    end
                end, function()
                    if self.charge_sfx then
                        self.charge_sfx:setVolume(0.3)
                    end
                end)
                self.charge_sfx:play()
            end
            if self.hold_timer >= 20 and self.hold_timer < 40 then
                self.charge_sfx:setPitch(Utils.clampMap(self.hold_timer, 20, 40, 0.1, 1))
            end
        else
            self.hold_timer = 0
            if self.charge_sfx then
                self.charge_sfx:stop()
                self.charge_sfx = nil
            end
        end
    end


    if not self:isMoving() or Kristal.getLibConfig("purplesoul", "rest_dash") == false then
        if self.null_timer > self.based_time - 7 and self.null_timer ~= self.based_time then
            --print("Here_3")
            self:setColor(self:changeColor({ 0.83529411764, 0.20784313725, 0.85098039215 }))
        end
        if self.null_timer == self.based_time then
            self.dash = self.max_dash

            self.null_timer = self.based_time
        end
        if self.null_timer < self.based_time then
            self.null_timer = self.null_timer + 1
        end
    end

    if self.dash_active and self.act_timer <= 9 then
        if (self.act_timer % 3 == 0) then
            self.trail = Sprite("player/heart_blur", (0 - (self.act_timer / 3) * 20) * self.moving_x - 10,
                (0 - (self.act_timer / 3) * 20) * self.moving_y - 11)
            self.trail.layer = 400
            self:addChild(self.trail)
            table.insert(self.trails, self.trail)
            self:move(self.moving_x, self.moving_y, self.dash_speed * 10)
        end
    end

    if self.dash_active then
        self.act_timer = self.act_timer + 1
    end

    if self.act_timer > 9 then
        self.dash_active = false
        self.act_timer = 0
    end

    --print(self.null_timer)

    if self.null_timer < self.based_time - 10 or self.null_timer == self.based_time then
        if self.dash > #self.dash_color - 1 then
            --print("Here_1")
            self:setColor(self:changeColor(self.dash_color[#self.dash_color]))
        else
            --print("Here_2")
            self:setColor(self:changeColor(self.dash_color[self.dash + 1]))
        end
    end

    for v, k in pairs(self.trails, self.trail) do
        print(#self.trails)
        if self.dash > #self.dash_color - 1 then
            self.trails[v]:setColor(self:changeColor(self.dash_color[#self.dash_color]))
        else
            self.trails[v]:setColor(self:changeColor(self.dash_color[self.dash + 1]))
        end
        self.trails[v]:fadeToSpeed(0, 0.1, function() table.remove(self.trails, #self.trails) end)
    end

    if self.timer < self.null_time then
        self.timer = self.timer + 1
    end
end

function PurpleSoul:doMovement()
    local speed = self.speed





    -- Do speed calculations here if required.

    if self.allow_focus then
        if Input.down("cancel") then speed = speed / 2 end -- Focus mode.
    end

    local move_x, move_y = 0, 0

    -- Keyboard input:
    if self.act_timer <= 1 then
        if Input.down("left") then
            self.direction_moving_string = "left"

            move_x = move_x - 1
        end
        if Input.down("right") then
            self.direction_moving_string = "right"

            move_x = move_x + 1
        end
        if Input.down("up") then
            self.direction_moving_string = "up"
            move_y = move_y - 1
        end
        if Input.down("down") then
            self.direction_moving_string = "down"
            move_y = move_y + 1
        end
    end

    if self.act_timer <= 1 then
        self.moving_x = move_x
        self.moving_y = move_y
    end

    if move_x ~= 0 or move_y ~= 0 then
        if not self:move(move_x, move_y, speed * DTMULT) then
            if not self.dash_active then
                self.moving_x = 0
                self.moving_y = 0
            end
        end
    end
    -- Do speed calculations here if required.

    local move_x, move_y = 0, 0

    if self.direction == "horizontal" then
        if Input.down("cancel") then speed = speed / 2 end -- Focus mode.

        if Input.down("left") then move_x = move_x - 1 end
        if Input.down("right") then move_x = move_x + 1 end

        if Input.pressed("up") then
            self.current_string = self.current_string - 1
        end
        if Input.pressed("down") then
            self.current_string = self.current_string + 1
        end

        self:stringStuff()

        if self.y < self.goal_y then
            if self.goal_y - self.y >= 9 then
                move_y = 9
            else
                move_y = self.goal_y - self.y
            end
        end
        if self.y > self.goal_y then
            if self.y - self.goal_y >= 9 then
                move_y = -9
            else
                move_y = -(self.y - self.goal_y)
            end
        end

        self:move(move_x * speed, move_y, DTMULT)
        self.moving_between_strings = false
    elseif self.direction == "vertical" then
        if Input.down("cancel") then speed = speed / 2 end -- Focus mode.

        if Input.down("up") then move_y = move_x - 1 end
        if Input.down("down") then move_y = move_x + 1 end

        if Input.pressed("left") then
            self.current_string = self.current_string - 1
        end
        if Input.pressed("right") then
            print("begun moving")

            self.current_string = self.current_string + 1
        end

        self:stringStuff()

        if self.x < self.goal_y then
            if self.goal_y - self.y >= 9 then
                move_x = 9
            else
                move_x = self.goal_y - self.y
            end
        end
        if self.x > self.goal_y then
            if self.x - self.goal_y >= 9 then
                move_x = -9
            else
                move_x = -(self.x - self.goal_y)
            end
        end

        self:move(move_x, move_y * speed, DTMULT)
        self.moving_between_strings = false
    end

    self.moving_x = move_x
    self.moving_y = move_y
end

function PurpleSoul:stringStuff()
    if self.loop == true then
        if (self.current_string < 1) then self.current_string = self.string_count end
        if (self.current_string > self.string_count) then self.current_string = 1 end
    else
        if (self.current_string < 1) then self.current_string = 1 end
        if (self.current_string > self.string_count - 1) then self.current_string = self.string_count end
    end
end

function PurpleSoul:draw()
    local r, g, b, a = self:getDrawColor()
    local heart_texture = Assets.getTexture(self.sprite.texture_path)
    local heart_w, heart_h = heart_texture:getDimensions()

    local charge_timer = self.hold_timer - 35
    if charge_timer > 0 then
        local scale = math.abs(math.sin(charge_timer / 10)) + 1
        love.graphics.setColor(r, g, b, a * 0.3)
        love.graphics.draw(heart_texture, -heart_w / 2 * scale, -heart_h / 2 * scale, 0, scale)

        scale = math.abs(math.sin(charge_timer / 14)) + 1.4
        love.graphics.setColor(r, g, b, a * 0.3)
        love.graphics.draw(heart_texture, -heart_w / 2 * scale, -heart_h / 2 * scale, 0, scale)
    end

    local circle_timer = math.min(self.hold_timer - 15, 35)
    if circle_timer > 0 then
        local circle = Assets.getTexture("player/charge_purple")
        love.graphics.setColor(r, g, b, a * (circle_timer / 5))
        for i = 1, 4 do
            local angle = (i * math.pi / 2) - (circle_timer * math.rad(5))
            local x, y = math.cos(angle) * (35 - circle_timer), math.sin(angle) * (35 - circle_timer)
            local scale = Utils.clampMap(circle_timer, 0, 35, 4, 2)
            x, y = x - circle:getWidth() / 2 * scale, y - circle:getHeight() / 2 * scale
            love.graphics.draw(circle, x, y, 0, scale)
        end
    end

    if charge_timer > 0 then
        self.color = { 1, 1, 1 }
    end
    super:draw(self)
    self.color = { r, g, b }
end

function PurpleSoul:changeColor(new_rgb)
    --Gradient made thanks to AlexGamingSW
    local old_r, old_g, old_b = self:getDrawColor()
    local r = Utils.lerp(old_r, new_rgb[1], 0.3)
    --print (r)
    local g = Utils.lerp(old_g, new_rgb[2], 0.3)
    --print (g)
    local b = Utils.lerp(old_b, new_rgb[3], 0.3)
    --print (b)
    return r, g, b
end

function PurpleSoul:onCollide(bullet)
    -- Handles damage

    if not self.dash_active then
        bullet:onCollide(self)
    end
end

function PurpleSoul:canCheat() return self.allow_cheat end

function PurpleSoul:onRemove(parent)
    super:onRemove(self, parent)
    if self.charge_sfx then
        self.charge_sfx:stop()
        self.charge_sfx = nil
    end
end

function PurpleSoul:canShoot() return self.can_shoot end

function PurpleSoul:canUseBigShot() return self.can_use_bigshot end

return PurpleSoul

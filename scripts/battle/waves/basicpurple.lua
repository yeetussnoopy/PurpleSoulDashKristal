local Basic, super = Class(Wave)
function Basic:init()
    super:init(self)

    -- Initialize timer
    self.time = -1

    self.string = { -9999, -9999, -9999 }
    self.string_count = 3


    self.layer = BATTLE_LAYERS["above_arena"]
end

function Basic:onStart()
    Game.battle:swapSoul(PurpleSoul())

    self.string[1] = 20
    self.string[2] = Game.battle.arena.height / 2
    self.string[3] = Game.battle.arena.height - 20

    self.string_count = 3

    Game.battle.soul.string_count = self.string_count
    Game.battle.soul.direction = "horizontal"

    if Game.battle.soul.direction == "horizontal" then
        Game.battle.soul.y = Game.battle.arena.top + self.string[2]
        Game.battle.soul.goal_y = Game.battle.arena.top + self.string[2]
    elseif Game.battle.soul.direction == "vertical" then
        Game.battle.soul.x = Game.battle.arena.left + self.string[2]
        Game.battle.soul.goal_y = Game.battle.arena.left + self.string[2]
    end
    
end

function Basic:update()
    if Game.battle.soul.direction == "horizontal" then
        for y = 1, self.string_count do
            if Game.battle.soul.current_string == y then Game.battle.soul.goal_y = Game.battle.arena.top + self.string
                [y] end
        end
    elseif Game.battle.soul.direction == "vertical" then
        for x = 1, self.string_count do
            if Game.battle.soul.current_string == x then Game.battle.soul.goal_y = Game.battle.arena.left +
                self.string[x] end
        end
    end

    super.update(self)
end

function Basic:draw()
    if Game.battle.soul.direction == "horizontal" then
        local arena_left = Game.battle.arena.left
        local arena_width = Game.battle.arena.width
        love.graphics.setColor({ 0.83529411764, 0.20784313725, 0.85098039215 })
        for y = 1, self.string_count do
            love.graphics.rectangle("fill", arena_left + 5, Game.battle.arena.top + self.string[y], arena_width - 10, 1)
        end
    elseif Game.battle.soul.direction == "vertical" then
        local arena_top = Game.battle.arena.top
        local arena_height = Game.battle.arena.height
        love.graphics.setColor({ 0.83529411764, 0.20784313725, 0.85098039215 })
        for y = 1, self.string_count do
            love.graphics.rectangle("fill", Game.battle.arena.left + self.string[y], arena_top + 5, 1, arena_height - 10)
        end
    end
end

return Basic

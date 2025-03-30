-- define gravity, jump strength, movement speed
local gravity = 0.2
local jump_strength = -3
local move_speed = 1.5

-- player class definition
player = {}
player.__index = player

function player:new(x, y, sprite)
    local obj = {
        x = x, -- player x position
        y = y, -- player y position
        vy = 0, -- vertical velocity
        sprite = sprite, -- sprite id
        on_platform = false,
        platform_index = nil -- track which platform the player is on
    }
    setmetatable(obj, player)
    return obj
end

function player:update(platforms, items)
    -- apply gravity
    self.vy = self.vy + gravity
    self.y = self.y + self.vy

    -- move left and right, update sprite
    if btn(0) then -- left button
        self.x = self.x - move_speed
        self.sprite = 2 -- set sprite to left-facing
    elseif btn(1) then -- right button
        self.x = self.x + move_speed
        self.sprite = 1 -- set sprite to right-facing
    end

    -- check if player is on a platform
    self.on_platform = false
    self.platform_index = nil

    for i, platform in ipairs(platforms) do
        if self.y + 8 >= platform.y and self.y + 8 <= platform.y + 2 and self.vy > 0 and self.x + 8 > platform.x and self.x < platform.x + 16 then
            self.y = platform.y - 8 -- position player on top of the platform
            self.vy = 0
            self.on_platform = true
            self.platform_index = i -- store index of platform landed on
            break -- exit loop early since the player can only land on one platform at a time
        end
    end

    -- jump only when pressing the button while on a platform
    if self.on_platform and btn(4) then
        self.vy = jump_strength
    end

    -- prevent falling below screen
    if self.y > 128 then
        self.y = 128
        self.vy = 0
    end

    -- wrap around the screen edges
    if self.x < 0 then
        self.x = 128
    elseif self.x > 128 then
        self.x = 0
    end

    -- check for item pickup
    for i, item in ipairs(items) do
        if self.x + 8 > item.x and self.x < item.x + 8 and self.y + 8 > item.y and self.y < item.y + 8 then
            -- player collided with item, hide item
            item.sprite = 6  -- set sprite to transparent (assuming sprite 6 is a transparent sprite)
        end
    end
end

function player:draw()
    spr(self.sprite, self.x, self.y)
end

-- platforms

platform = {}
platform.__index = platform

function platform:new(x, y)
    local obj = {
        x = x, -- platform x position
        y = y -- platform y position
    }
    setmetatable(obj, platform)
    return obj
end

function platform:draw()
    spr(0, self.x, self.y) -- platform sprite
end

-- item class definition
item = {}
item.__index = item

function item:new(x, y)
    local obj = {
        x = x, -- item x position
        y = y, -- item y position
        sprite = 3 -- default sprite for the item
    }
    setmetatable(obj, item)
    return obj
end

function item:draw()
    spr(self.sprite, self.x, self.y) -- draw the item with its current sprite
end

-- initialize game objects
function _init()
    music(0) -- start playing music from track 0

    -- set up the background map
    -- define map with mset(), this will map the first 16x16 area
    -- this is an example, change according to your game design
    for x = 0, 15 do
        for y = 0, 15 do
            mset(x, y,16) -- set tile id to 1, which corresponds to the first tile in the tilemap
        end
    end
end

-- in actual game, will randomize these
local player = player:new(20, 75, 1) -- starts w/ sprite 1
local platforms = {
    platform:new(20, 110),
    platform:new(25, 110),
    platform:new(50, 95),
    platform:new(80, 80),
    platform:new(30, 65),
    platform:new(35, 65),
    platform:new(80, 50),
    platform:new(85, 50),
    platform:new(40, 35),
    platform:new(25, 20),
    platform:new(20, 20),
    platform:new(75, 10)
}

-- create items to pick up (positioned centered on top of platforms)
local items = {
    item:new(50, 95-8),
    item:new(80, 80-8), 
    item:new(80, 50-8),
    item:new(75, 10-8)
}

-- game update & draw

function _update()
    player:update(platforms, items)
end

function _draw()
    cls()
    
    -- draw the background map (first 128x128 part of the map)
    map(0, 0, 0, 0, 16, 16) -- parameters are (src_x, src_y, dst_x, dst_y, width, height)

    player:draw()
    for _, platform in ipairs(platforms) do
        platform:draw()
    end
    for _, item in ipairs(items) do
        item:draw() -- draw the items
    end
end

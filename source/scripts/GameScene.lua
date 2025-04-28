-- local pd <const> = playdate
local gfx <const> = playdate.graphics
local ldtk <const> = LDtk

TAGS = {
	Player = 1,
	Hazard = 2,
	Pickup = 3,
}

Z_INDEXES = {
	Player = 100,
	Hazard = 20,
	Pickup = 50,
}

local usePrecomputedLevels = not playdate.isSimulator
ldtk.load("levels/world.ldtk", usePrecomputedLevels)

if playdate.isSimulator then
	ldtk.export_to_lua_files()
end

class('GameScene').extends()

function GameScene:init()
    self:goToLevel("Level_4")

	self.spawnX = 11 * 16 + 8
	self.spawnY = 7 * 16

	self.player = Player(self.spawnX, self.spawnY, self)
end


function GameScene:enterRoom(direction)
	local level = ldtk.get_neighbours(self.levelName, direction)[1]

	self:goToLevel(level)
	self.player:add()
	local spawnX, spawnY

	if direction == "north" then
		spawnX, spawnY = self.player.x, 240
	elseif direction == "south" then
		spawnX, spawnY = self.player.x, 0
	elseif direction == "east" then
		spawnX, spawnY = 0, self.player.y
	elseif direction == "west" then
		spawnX, spawnY = 400, self.player.y
	end

	self.player:moveTo(spawnX, spawnY)
	self.spawnX = spawnX
	self.spawnY = spawnY
end

function GameScene:goToLevel(levelName)
    --if not level_name then return end

    gfx.sprite.removeAll()

	-- store name for use later
	self.levelName = levelName

    for layerName, layer in pairs(ldtk.get_layers(levelName)) do
        if layer.tiles then
            local tilemap = ldtk.create_tilemap(levelName, layerName)

            local layerSprite = gfx.sprite.new()
            layerSprite:setTilemap(tilemap)
            layerSprite:setCenter(0, 0)
            layerSprite:moveTo(0, 0)
            layerSprite:setZIndex(layer.zIndex)
            layerSprite:add()

            local emptyTiles = ldtk.get_empty_tileIDs(levelName, "Solid", layerName)
            if emptyTiles then
                gfx.sprite.addWallSprites(tilemap, emptyTiles)
            end
        end
    end


	-- Spawn hazards
	for _, entity in ipairs(ldtk.get_entities(levelName, layerName)) do
		local entityX, entityY = entity.position.x, entity.position.y
		local entityName = entity.name
		if entityName == "Spike" then
			Spike(entityX, entityY)
		elseif entityName == "Ability" then
			Ability(entityX, entityY, entity)
		end
	end
end

-- local pd <const> = playdate
local gfx <const> = playdate.graphics
local ldtk <const> = LDtk

TAGS = {
	Player = 1,
	Hazard = 2,
	Pickup = 3,
	Door = 4,
	BonusItems = 5,
}

Z_INDEXES = {
	Player = 100,
	Hazard = 20,
	Pickup = 50,
	Door = 60,
	BonusItems = 90,
}

local usePrecomputedLevels = not playdate.isSimulator
ldtk.load("levels32/world.ldtk", usePrecomputedLevels)

if playdate.isSimulator then
	ldtk.export_to_lua_files()
end

class('GameScene').extends()

function GameScene:init()
    self:goToLevel("Level_0")

	self.spawnX = 13 * 32 + 8
	self.spawnY = 12 * 32

	self.player = Player(self.spawnX, self.spawnY, self)

	-- self.levelWidth = 800
	-- self.levelHeight = 480

	self:cameraFocusAt(self.spawnX, self.spawnY)
end


function GameScene:enterRoom(direction)
	local level = ldtk.get_neighbours(self.levelName, direction)[1]

	self:goToLevel(level)
	self.player:add()
	local spawnX, spawnY

	if direction == "north" then
		spawnX, spawnY = self.player.x, self.levelHeight
	elseif direction == "south" then
		spawnX, spawnY = self.player.x, 0
	elseif direction == "east" then
		spawnX, spawnY = 0, self.player.y
	elseif direction == "west" then
		spawnX, spawnY = self.levelWidth, self.player.y
	end

	self.player:moveTo(spawnX, spawnY)
	self.spawnX = spawnX
	self.spawnY = spawnY
end

function GameScene:cameraFocusAt(x, y)
	local screenCenterX = 200
	local screenCenterY = 120

	self.cameraPosX = math.max(math.min(screenCenterX - x, 0), 2*screenCenterX-self.levelWidth)
	self.cameraPosY = math.max(math.min(screenCenterY - y, 0), 2*screenCenterY-self.levelHeight)

	-- print(self.cameraPosX, self.cameraPosY)
	gfx.setDrawOffset(self.cameraPosX, self.cameraPosY)

end


function GameScene:goToLevel(levelName)
    --if not level_name then return end

    gfx.sprite.removeAll()

	-- store name for use later
	self.levelName = levelName

	local layers = ldtk.get_layers(levelName)
	assert(layers)

	local entities = ldtk.get_entities(levelName, nil)
	assert(entities)

	local fake_walls = {}

	for _, entity in ipairs(entities) do
		local entityX, entityY = entity.position.x, entity.position.y
		local entityName = entity.name

		if entityName == "Spike" then
			Spike(entityX, entityY)

		elseif entityName == "Ability" then
			Ability(entityX, entityY, entity)

		elseif entityName == "SlidingDoor" then
			SlidingDoor(entityX, entityY)

		elseif entityName == "Coin" then
			Coin(entityX, entityY, entity)

		elseif entityName == "FakeWall" then
			table.insert(fake_walls, {entityX / 32 + 1, entityY / 32 + 1})


		end
	end

    for layerName, layer in pairs(layers) do
        if layer.tiles then
            local tilemap = ldtk.create_tilemap(levelName, layerName)

			if tilemap then
				self.levelWidth, self.levelHeight = tilemap:getSize()
				self.levelHeight *= 32
				self.levelWidth *= 32
				-- print("Level is "..self.levelWidth.."x"..self.levelHeight)

				local layerSprite = gfx.sprite.new()
				layerSprite:setTilemap(tilemap)
				layerSprite:setCenter(0, 0)
				layerSprite:moveTo(0, 0)
				layerSprite:setZIndex(layer.zIndex)
				layerSprite:add()

				local emptyTileIds = ldtk.get_empty_tileIDs(levelName, "Solid", layerName)

				if emptyTileIds then
					-- Copy tilemap and set fakewalls to non-solid
					local tilemap_with_fakewalls = ldtk.create_tilemap(levelName, layerName)
					assert(tilemap_with_fakewalls)

					for _, fakewall in ipairs(fake_walls) do
						tilemap_with_fakewalls:setTileAtPosition(fakewall[1], fakewall[2], 0)
					end

					gfx.sprite.addWallSprites(tilemap_with_fakewalls, emptyTileIds)
				end
			end
        end
    end

end

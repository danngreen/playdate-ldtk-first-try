-- local pd <const> = playdate
local gfx <const> = playdate.graphics
local ldtk <const> = LDtk

TAGS = {
	Player = 1
}

Z_INDEXES = {
	Player = 100
}

ldtk.load("levels/world.ldtk", false)

class('GameScene').extends()

function GameScene:init()
    self:goToLevel("Level_0")

	self.spawnX = 9 * 16
	self.spawnY = 2 * 16
	self.player = Player(self.spawnX, self.spawnY)
end

function GameScene:goToLevel(levelName)
    --if not level_name then return end

    gfx.sprite.removeAll()

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

end

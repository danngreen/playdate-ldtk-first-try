local gfx <const> = playdate.graphics

local coinImageTable <const> = gfx.imagetable.new("images/coin-table-32-32")
assert(coinImageTable)

class('Coin').extends(AnimatedSprite)

function Coin:init(x, y, entity)
	self.fields = entity.fields

	if self.fields.pickedUp then
		return
	end

	Coin.super.init(self, coinImageTable)

	self:setZIndex(Z_INDEXES.BonusItems)
	self:setImage(coinImage)
	self:setCenter(0, 0) --pivot point
	self:moveTo(x, y)
	self:add()

	self:addState("spin", 1, 3, {tickStep = 4})
	self:playAnimation()

	self:setTag(TAGS.Pickup)
	self:setCollideRect(12, 2, 8, 27)
end

function Coin:pickup(player)
	player.numCoins += 1

	self.fields.pickedUp = true
	self:remove()
end


local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Ability').extends(gfx.sprite)

function Ability:init(x, y, entity)
	self.fields = entity.fields

	if self.fields.pickedUp then
		return
	end

	self.abilityName = entity.fields.Ability
	assert(self.abilityName)

	local abilityImage = gfx.image.new("images/"..self.abilityName)
	assert(abilityImage)

	self:setImage(abilityImage)
	self:setZIndex(Z_INDEXES.Pickup)
	self:setCenter(0, 0) --pivot point
	self:moveTo(x, y)
	self:add()

	self:setTag(TAGS.Pickup)
	self:setCollideRect(0, 0, self:getSize())
end

function Ability:pickup(player)
	if self.abilityName == "DoubleJump" then
		player.doubleJumpAbility = true
	elseif self.abilityName == "Dash" then
		player.dashAbility = true
	end

	self.fields.pickedUp = true
	self:remove()
end


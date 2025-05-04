local gfx <const> = playdate.graphics

local slidingDoorImage <const> = gfx.image.new("images/Dash")

class('SlidingDoor').extends(gfx.sprite)


function SlidingDoor:init(x, y)
	self:setZIndex(Z_INDEXES.Door)
	self:setImage(slidingDoorImage)
	self:setCenter(0, 0) --pivot point
	self:moveTo(x, y)
	self:add()

	self:setTag(TAGS.Door)
	self:setCollideRect(0, 0, 16, 16)

	self.closed = true
	self.opening = false
	self.opened_amount = 0
end

function SlidingDoor:update()

	-- Open door if player bumps it
	-- If it's already open, them bump it up one more
	if self.opening then
		self:moveBy(0, -1)
		self.opened_amount += 1
		if self.opened_amount >= 16 then
			self.opening = false
			self.closed = false
		end
	end

end

function SlidingDoor:open()
	self.opening = true
end

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(AnimatedSprite)

function Player:init(x, y, gameManager)
	self.gameManager = gameManager

	-- State Machine
	local playerImageTable = gfx.imagetable.new("images/player-table-16-16.png")

	-- this adds the sprite to the draw list (so Player:update() will get called from gfx.sprite.update()
	Player.super.init(self, playerImageTable)

	self:addState("idle", 1, 1)
	self:addState("run", 1, 3, {tickStep = 4})
	self:addState("jump", 4, 4)
	self:addState("dash", 4, 4)
	self:playAnimation()

	-- Sprite Properties
	self:moveTo(x, y)
	self:setZIndex(Z_INDEXES.Player)
	self:setTag(TAGS.Player)
	self:setCollideRect(3, 3, 10, 13)

	-- Physics Properties
	self.xVelocity = 0
	self.yVelocity = 0
	self.gravity = 1.0
	self.maxSpeed = 2.0
	self.jumpVelocity = -6
	self.drag = 0.1
	self.minimumAirSpeed = 0.5

	self.jumpBufferAmount = 5
	self.jumpBuffer = 0

	-- Abilities
	self.doubleJumpAbility = false
	self.dashAbility = true

	-- Double Jump
	self.doubleJumpAvailable = true

	-- Dash
	self.dashAvailable = true
	self.dashSpeed = 8
	self.dashMinimumSpeed = 3
	self.dashDrag = 0.8

	-- Player State
	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false
end

function Player:collisionResponse(other)
	local tag = other:getTag()
	if tag == TAGS.Hazard or tag == TAGS.Pickup then
		return gfx.sprite.kCollisionTypeOverlap
	end
	return gfx.sprite.kCollisionTypeSlide
end

function Player:update()
	self:updateAnimation()

	self:updateJumpBuffer()
	self:handleState()
	self:handleMovementAndCollisions()
end

function Player:updateJumpBuffer()
	self.jumpBuffer -= 1
	if self.jumpBuffer <= 0 then
		self.jumpBuffer = 0
	end
	if pd.buttonJustPressed(pd.kButtonA) then
		self.jumpBuffer = self.jumpBufferAmount
	end
end

function Player:playerJumped()
	return self.jumpBuffer > 0
end

function Player:handleState()
	if self.currentState == "idle" then
		self:applyGravity()
		self:handleGroundInput()

	elseif self.currentState == "run" then
		self:applyGravity()
		self:handleGroundInput()

	elseif self.currentState == "jump" then
		if self.touchingGround then
			self:changeToIdleState()
		end
		self:applyGravity()
		self:applyDrag(self.drag)
		self:handleAirInput()

	elseif self.currentState == "dash" then
		--no gravity, just drag
		self:applyDrag(self.dashDrag)
		if math.abs(self.xVelocity) <= self.dashMinimumSpeed then
			self:changeToFallState()
		end

	end
end

function Player:handleMovementAndCollisions()
	local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

	self.touchingGround = false
	self.touchingCeiling = false
	self.touchingWall = false

	for i=1,length do
		local collision = collisions[i]
		local collisionType = collision.type
		local collisionObject = collision.other
		local collisionTag = collisionObject:getTag()

		if collisionType == gfx.sprite.kCollisionTypeSlide then
			-- normal.y == -1 means the ground
			if collision.normal.y == -1 then
				self.touchingGround = true
				self.dashAvailable = true
				self.doubleJumpAvailable = true
			elseif collision.normal.y == 1 then
				self.touchingCeiling = true
			end

			if collision.normal.x ~= 0 then
				self.touchingWall = true
			end
		end

		if collisionTag == TAGS.Hazard then
			self.touchingWall = true
			self.touchingCeiling = true
			self.dashAvailable = false
			self.doubleJumpAvailable = false
			-- died = true
		elseif collisionTag == TAGS.Pickup then
			collisionObject: pickup(self)
		end
	end

	-- Flip direction even in the air
	if self.xVelocity < 0 then
		self.globalFlip = 1
	elseif self.xVelocity > 0 then
		self.globalFlip = 0
	end

	if self.x < 0 then
		self.gameManager:enterRoom("west")
	elseif self.x > 400 then
		self.gameManager:enterRoom("east")
	elseif self.y < 0 then
		self.gameManager:enterRoom("north")
	elseif self.y > 240 then
		self.gameManager:enterRoom("south")
	end

end


-- Input Helper Functions

function Player:handleGroundInput()
	-- if pd.buttonJustPressed(pd.kButtonA) then
	if self:playerJumped() then
		self:changeToJumpState()
	elseif pd.buttonIsPressed(pd.kButtonB) and self.dashAvailable and self.dashAbility then
		self:changeToDashState()
	elseif pd.buttonIsPressed(pd.kButtonLeft) then
		self:changeToRunState("left")
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		self:changeToRunState("right")
	else
		self:changeToIdleState()
	end
end

function Player:handleAirInput()
	if self:playerJumped() and self.doubleJumpAvailable and self.doubleJumpAbility then
		self.doubleJumpAvailable = false
		self:changeToJumpState()
	elseif pd.buttonJustPressed(pd.kButtonB) and self.dashAvailable and self.dashAbility then
		self:changeToDashState()
	elseif pd.buttonIsPressed(pd.kButtonLeft) then
		self.xVelocity = -self.maxSpeed
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		self.xVelocity = self.maxSpeed
	end
end

-- State transitions
--
function Player:changeToIdleState()
	self.xVelocity = 0
	self:changeState("idle")
end

function Player:changeToRunState(dir)
	if dir == "left" then
		self.xVelocity = -self.maxSpeed
		self.globalFlip = 1
	elseif dir == "right" then
		self.xVelocity = self.maxSpeed
		self.globalFlip = 0
	end

	self:changeState("run")
end

function Player:changeToJumpState()
	self.yVelocity = self.jumpVelocity
	self.jumpBuffer = 0
	self:changeState("jump")
end

function Player:changeToFallState()
	self:changeState("jump")
end

function Player:changeToDashState()
	self.dashAvailable = false
	self.yVelocity = 0

	if pd.buttonIsPressed(pd.kButtonLeft) then
		self.xVelocity = -self.dashSpeed
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		self.xVelocity = self.dashSpeed
	else
		if self.globalFlip == 1 then
			self.xVelocity = -self.dashSpeed
		else
			self.xVelocity = self.dashSpeed
		end
	end

	self:changeState("dash")
end

-- Physics helpers
--
function Player:applyGravity()
	self.yVelocity += self.gravity
	if self.touchingGround or self.touchingCeiling then
		self.yVelocity = 0
	end
end

function Player:applyDrag(amount)
	if self.xVelocity > 0 then
		self.xVelocity -= amount
	elseif self.xVelocity < 0 then
		self.xVelocity += amount
	end

	if math.abs(self.xVelocity) < self.minimumAirSpeed or self.touchingWall then
		self.xVelocity = 0
	end
end


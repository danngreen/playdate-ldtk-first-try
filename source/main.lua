-- CoreLibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Libraries
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/LDtk"

-- Game
import "scripts/GameScene"
import "scripts/player"
import "scripts/ability"
import "scripts/spike"
import "scripts/SlidingDoor"
import "scripts/coin"

local pd <const> = playdate
local gfx <const> = playdate.graphics

GameScene()

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end

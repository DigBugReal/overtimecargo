local sprite_boungus = Sprite.new("boundingFungus", path.combine(PATH, "Sprites/item/boundingFungus.png"), 1, 16, 16)
local sprite_boing_long = Sprite.new("boundingFungusBoingLong", path.combine(PATH, "Sprites/fx/boingLong.png"), 14, 13, 37)

local sound_boing = Sound.new("boundingFungusBoingSFX", path.combine(PATH, "Sounds/boing.ogg"))

local boungus = Item.new("boundingFungus")
boungus:set_sprite(sprite_boungus)
boungus:set_tier(ItemTier.COMMON)
boungus.loot_tags = Item.LootTag.CATEGORY_UTILITY

local log = ItemLog.new_from_item(boungus)
log.group = ItemLog.Group.COMMON

local boing = Object.new("boundingFungusBoing")
boing:set_sprite(sprite_boing_long)

Callback.add(boing.on_create, function(self)
	self.image_speed = 0.25
end)

local boinged = false

Callback.add(boing.on_step, function(self)
	if self.parent and self:is_colliding(self.parent) and Instance.get_data(self.parent).shroomjumped == nil then
		self.parent.pVspeed = -10
		self:sound_play(gm.constants.wGeyser, 1, 1.1)
		self:sound_play(sound_boing, 0.6, 0.9 + math.random() * 0.2)
	end
	
	if self.parent.pVspeed <= -10 then
		Instance.get_data(self.parent).shroomjumped = true
	end
	
	if self.image_index >= 13 then
		self:destroy()
	end
end)

Callback.add(boungus.on_acquired, function(actor)
	boinged = false
	if Instance.get_data(actor).boungustimer == nil then
		Instance.get_data(actor).boungustimer = 15 * 60
	end
end)

Callback.add(Callback.POST_STEP, function()
	for _, actor in ipairs(boungus:get_holding_actors()) do
		if Instance.get_data(actor).boungustimer <= 60 * (15 * 0.9 ^ (actor:item_count(boungus) - 1)) then
			Instance.get_data(actor).boungustimer = Instance.get_data(actor).boungustimer + 1
		elseif Instance.get_data(actor).boungusrechargeeffects == false then
			actor:sound_play(gm.constants.wEfMushroom, 1, 1.2 + math.random() * 0.4)
			local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
			flash.parent = actor
			flash.rate = 0.05
			flash.image_blend = 8894686
			flash.image_alpha = 1
			Instance.get_data(actor).boungusrechargeeffects = true
		end
	end
end)

Hook.add_pre(gm.constants.actor_phy_on_landed, function(self, other, result, args)
    local real_self = Instance.wrap(self)
    if not Util.bool(real_self.invincible) and real_self:item_count(boungus) > 0 and Instance.get_data(real_self).boungustimer >= 60 * (15 * 0.8 ^ (real_self:item_count(boungus) - 1)) and real_self.pVspeed > 25 then
		self.invincible = 1
		boinged = true
		Instance.get_data(real_self).boungustimer = 0
		Instance.get_data(real_self).shroomjumped = nil
		Instance.get_data(real_self).boungusrechargeeffects = false
		local shroom = boing:create(real_self.x, real_self.y + 12)
		shroom.parent = real_self
    end
end)

Hook.add_post(gm.constants.actor_phy_on_landed, function(self, other, result, args)
	local real_self = Instance.wrap(self)
    if boinged then
		real_self.invincible = 0
		boinged = false
    end
end)
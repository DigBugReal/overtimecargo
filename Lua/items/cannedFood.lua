local sprite_food = Sprite.new("cannedFood", path.combine(PATH, "Sprites/item/cannedFood.png"), 1, 18, 17)
local sprite_rotten = Sprite.new("rottenFood", path.combine(PATH, "Sprites/fx/rottenFood.png"), 1, 14, 8)
local sprite_proj = Sprite.new("foodProjectile", path.combine(PATH, "Sprites/fx/foodProjectile.png"), 1, 12, 9)

local fud = Item.new("cannedFood")
fud:set_sprite(sprite_food)
fud:set_tier(ItemTier.COMMON)
fud.loot_tags = Item.LootTag.CATEGORY_DAMAGE

local log = ItemLog.new_from_item(fud)
log.group = ItemLog.Group.COMMON

local fudBuff = Buff.new("cannedFoodPoison")
fudBuff.is_debuff = true
fudBuff.show_icon = false

local rottenFood = Object.new("cannedFoodDrops")
rottenFood:set_sprite(sprite_proj)

Callback.add(rottenFood.on_create, function(self)
	local data = Instance.get_data(self)
	
	if not data.food then
		data.food = true
	end
	
	if data.grounded == nil then
		data.grounded = 0
	end
	
	self.direction = math.random(45, 135)
	self.speed = 3 + math.random(2)
	self.gravity = 0.2
	self.image_xscale = gm.choose(-1, 1)
	data.spin_direction = self.image_xscale
	
	self:instance_sync()
end)

Callback.add(rottenFood.on_step, function(self)
local data = Instance.get_data(self)
	
	if data.food then
		self.image_angle = self.image_angle + (-15 + self.image_xscale)
		if self:is_colliding(gm.constants.pBlock, self.x, self.y) then
			self.image_speed = 0.25
			self.image_angle = 0
			self.sprite_index = sprite_rotten
			self.image_index = 0
			self.direction = 0
			self.gravity = 0
			self.speed = 0
			data.lifespan = 60 * 8
			data.food = false
		end
	else
		if data.grounded == 1 then
			local buffed = 0
			for _, victim in ipairs(self:get_collisions(gm.constants.pActor)) do
				if victim.team ~= data.parent.team and victim:get_buff_time(victim, fudBuff) < 1 then
					if not Instance.get_data(victim).foodDmg then
						Instance.get_data(victim).foodDmg = data.parent.damage
					end
					victim:buff_apply(fudBuff, 60 * 5, 1)
					Instance.get_data(victim).applier = data.parent
					self:destroy()
				end
			end
			
			data.lifespan = data.lifespan - 1
			
			if data.lifespan <= 20 then
				self.image_alpha = self.image_alpha - 0.05
			end
			
			if data.lifespan <= 0 or self.image_alpha <= 0 then
				self:destroy()
			end
			
		else
			self:move_contact_solid(270, 64)
			Sound.wrap(gm.constants.wMac_Bounce):play(self.x, self.y, 0.9, 1.1 + math.random() * 0.4)
			data.grounded = 1
		end
	end
end)

Callback.add(Callback.ON_INTERACTABLE_ACTIVATE, function(interactable, player)
	if player:item_count(fud) <= 0 then return end
	if (#Instance.find_all(rottenFood)) < 21 then
		count1 = player:item_count(fud) + 1
		guilty = player:item_count(fud) 
		for i = 0, count1, guilty do
			local foodProj = rottenFood:create(interactable.x, interactable.y - 15)
			Instance.get_data(foodProj).parent = player
		end
	end
end)

Callback.add(fudBuff.on_apply, function(actor, stack)
	Instance.get_data(actor).foodTick = 0
	Sound.wrap(gm.constants.wUse2):play(actor.x, actor.y, 1, 0.7)
end)

Callback.add(fudBuff.on_step, function(actor, stack)
	if Net.client then return end
	
	local data = Instance.get_data(actor)
	
	data.foodTick = data.foodTick - 1
	
	if data.foodTick <= 0 then
		local dmg = data.foodDmg * (0.25 + (0.15 * data.applier:item_count(fud)))
		actor:damage_inflict(actor, dmg, 0, data.applier, actor.x, actor.y, dmg, data.applier.team, Color.from_rgb(0, 163, 40))
		data.foodTick = 30
	end

end)
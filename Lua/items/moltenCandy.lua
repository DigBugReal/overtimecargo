local sprite_candy = Sprite.new("moltenCandy", path.combine(PATH, "Sprites/item/moltenCandy.png"), 1, 17, 13)
local sprite_blob = Sprite.new("moltenCandyBlob", path.combine(PATH, "Sprites/fx/moltenCandyBlob.png"), 1, 8, 8)
local sprite_trail = Sprite.new("moltenCandyTrail", path.combine(PATH, "Sprites/fx/moltenCandyTrail.png"), 6, 16, 12)
local sprite_explode = Sprite.new("moltenCandyExplode", path.combine(PATH, "Sprites/fx/moltenCandyExplode.png"), 5, 13, 18)
local sprite_buff = Sprite.new("moltenCandyBuff", path.combine(PATH, "Sprites/buffs/moltenCandyBuff.png"), 1, 16, 16)

local sound_explode = Sound.new("moltenCandyExplodeSnd", path.combine(PATH, "Sounds/moltenCandyExplode.ogg"))
local candy = Item.new("moltenCandy")
candy:set_sprite(sprite_candy)
candy:set_tier(ItemTier.UNCOMMON)
candy.loot_tags = Item.LootTag.CATEGORY_DAMAGE

local log = ItemLog.new_from_item(candy)
log.group = ItemLog.Group.UNCOMMON

local candydust = Particle.new("candyParticle")

candydust:set_alpha2(1, 0)
candydust:set_shape(Particle.Shape.PIXEL)
candydust:set_life(10, 20)
candydust:set_color_rgb(255, 255, 0, 0, 0, 0)
candydust:set_speed(1, 1.5, -0.01, 0)
candydust:set_size(1.6, 2, -0.02, 0)
candydust:set_direction(90, 90, 0, 0)

local candybuff = Buff.new("moltenCandyBuff")
candybuff.is_debuff = true
candybuff.show_icon = true
candybuff.icon_sprite = sprite_buff

local moltenblob = Object.new("moltenCandyBlob")
moltenblob:set_sprite(sprite_blob)

Callback.add(candybuff.on_apply, function(actor)
	Instance.get_data(actor).candyTick = 0
end)

RecalculateStats.add(function(actor, api)
	local stack = actor:buff_count(candybuff)
	if stack <= 0 then return end
	api.pHmax_mult(0.4)
end)


Callback.add(moltenblob.on_create, function(self)
	local data = Instance.get_data(self)
	if not data.blob then
		data.blob = true
	end
	if data.grounded == nil then
		data.grounded = 0
	end
	self.gravity = 0.2 
	self.speed = 3 + math.random(2)
	self.direction = math.random(45, 135)
	self.image_xscale = gm.choose(-1, 1)
	data.spin_direction = self.image_xscale
	
	self:instance_sync()
end)

Callback.add(moltenblob.on_step, function(self)
	local data = Instance.get_data(self)
	
	if data.blob then
		self.image_angle = self.image_angle + (-15 + self.image_xscale)
		if self:is_colliding(gm.constants.pBlock, self.x, self.y) then
			self.image_speed = 0.25
			self.image_angle = 0
			self.sprite_index = sprite_trail
			self.direction = 0
			self.gravity = 0
			self.speed = 0
			data.lifespan = 60 * 5
			data.blob = false
		end
	else
		if data.grounded == 1 then
			local buffed = 0
			for _, victim in ipairs(self:get_collisions(gm.constants.pActor)) do
				if victim.team ~= data.parent.team and victim:get_buff_time(victim, candybuff) < 1 then
					if not Instance.get_data(victim).pool_damage then
						Instance.get_data(victim).pool_damage = data.parent.damage
					end
					victim:buff_apply(candybuff, 30)
					Instance.get_data(victim).applier = data.parent
					buffed = buffed + 1
				end
				if buffed >= 3 then -- max 3 buffs per tick, a cope to deal with lag
					buffed = 0
					break
				end
			end
			
			data.lifespan = data.lifespan - 1
			
			candydust:create(self.x + math.random(-16, 16), self.y)
			
			if data.lifespan <= 20 then
				self.image_alpha = self.image_alpha - 0.05
			end
			
			if data.lifespan <= 0 or self.image_alpha <= 0 then
				self:destroy()
			end
		else
			self:move_contact_solid(270, -1)
			sound_explode:play(self.x, self.y, 1, 1)
			local explode = GM.instance_create(self.x, self.y, gm.constants.oEfExplosion)
			explode.sprite_index = sprite_explode
			data.grounded = 1
		end
	end
end)

Callback.add(candybuff.on_step, function(actor)
	if Net.client then return end
	
	local data = Instance.get_data(actor)
	data.candyTick = data.candyTick - 1
	
	if data.candyTick <= 0 then
		local dmg = data.pool_damage * data.applier:item_count(candy)
		actor:damage_inflict(actor, dmg, 0, data.applier, actor.x, actor.y, dmg, data.applier.team, Color.from_rgb(188, 67, 112))
		data.candyTick = 25
	end
end)

Callback.add(candybuff.on_remove, function(actor)
	Instance.get_data(actor).pool_damage = nil
end)

Callback.add(Callback.ON_HIT_PROC, function(actor, target, hit_info)
if actor:item_count(candy) <= 0 then return end
	if (math.random() <= 0.05) and (#Instance.find_all(moltenblob)) < 21 then -- wont spawn if 21 puddles max already exist, another performance cope
		for i = 0, 2, 1 do
			local blob = moltenblob:create(target.x, target.y)
			Instance.get_data(blob).parent = actor
		end
	end
end)
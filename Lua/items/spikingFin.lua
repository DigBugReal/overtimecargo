local sprite_fin = Sprite.new("spikingFin", path.combine(PATH, "Sprites/item/spikingFin.png"), 1, 16, 16)
local eLem = Object.find("LizardF")
local eLemG = Object.find("LizardFG")

local fin = Item.new("spikingFin")
fin:set_sprite(sprite_fin)
fin:set_tier(ItemTier.UNCOMMON)
fin.loot_tags = Item.LootTag.CATEGORY_DAMAGE

local log = ItemLog.new_from_item(fin)
log.group = ItemLog.Group.UNCOMMON

local shockwave = Object.new("spikingFinShockwave")
shockwave.obj_sprite = gm.constants.sSparks4

Callback.add(shockwave.on_create, function(self)
	self.image_speed = 0
	self.image_index = 0
	self.speed = 12
	self.parent = Instance.get_data(self).parent
	Instance.get_data(self).hit_list = {}
	Instance.get_data(self).lifetime = 50
	self:move_contact_solid(270, -1)
end)

Callback.add(shockwave.on_step, function(self)
	if not Instance.exists(self.parent) then
		self:destroy()
		return
	end

	local data = Instance.get_data(self)

	data.lifetime = data.lifetime - 1
	if data.lifetime < 0 then
		self:destroy()
		return
	end
	
	self.image_index = math.min(4, math.floor((50 - data.lifetime) / 10))
	
	self.speed = self.speed * 0.95
	self.image_xscale = self.image_xscale * 0.97

	local actors = self:get_collisions(gm.constants.pActorCollisionBase)

	for _, actor in ipairs(actors) do
		if self:attack_collision_canhit(actor) and not data.hit_list[actor.id] then
			if Net.host then
					local direct = self.parent:fire_direct(actor, 1, self.direction, self.x, self.y, gm.constants.sSparks11).attack_info
					direct:set_damage((self.parent.damage * 3) * self.parent:item_count(fin))
					direct:set_knockback(-actor.image_xscale, 120, 6, 1)		
				-- if actor.elite_type ~= -1 then
					-- local direct = self.parent:fire_direct(actor, 1, self.direction, self.x, self.y, gm.constants.sSparks11).attack_info
					-- direct:set_damage((Instance.get_data(self).enemymaxhp * ((0.13 * self.parent:item_count(fin)) / (1 + 0.13 * self.parent:item_count(fin)))) * 0.5)
					-- direct:set_knockback(self.image_xscale, 60, 3, 1)
				-- else
					-- local direct = self.parent:fire_direct(actor, 1, self.direction, self.x, self.y, gm.constants.sSparks11).attack_info
					-- direct:set_damage(Instance.get_data(self).enemymaxhp * ((0.13 * self.parent:item_count(fin)) / (1 + 0.13 * self.parent:item_count(fin))))
					-- direct:set_knockback(self.image_xscale, 60, 3, 1)		
					
				-- end
			end 	
			data.hit_list[actor.id] = true
		end
	end
end)

local debuffspiking = Buff.new("debuffspiking")
debuffspiking.show_icon = false
debuffspiking.is_debuff = true
debuffspiking.max_stack = 1

local rubble = Particle.find("Rubble1")

Callback.add(debuffspiking.on_apply, function(actor)
	Instance.get_data(actor).spiking_timer = 0
	actor.pVspeed = -14
	actor.intangible = 1
	Sound.wrap(gm.constants.wBoss1Shoot1):play(actor.x, actor.y, 0.8, 1.1 + math.random() * 0.2)
	Sound.wrap(gm.constants.wFwoosh):play(actor.x, actor.y, 1.6, 1.2 + math.random() * 0.2)
end)

Callback.add(debuffspiking.on_step, function(actor)
	if Net.client then return end
	
	local data = Instance.get_data(actor)
	data.spiking_timer = data.spiking_timer + 1
	
	if actor:is_colliding(gm.constants.pBlock, actor.x, actor.y - 6) and GM.actor_is_classic(actor) then
		data.spiking_timer = 25
	end

	if not GM.actor_is_boss(actor) and not GM.actor_is_classic(actor) and data.spiking_timer < 24 then
		actor.y = actor.y - 11
	end
	

	if data.spiking_timer > 25 then
		if not GM.actor_is_boss(actor) and GM.actor_is_classic(actor) then
			actor.pVspeed = actor.pVspeed + 5
			actor.fallImmunity = true
			if actor:is_colliding(gm.constants.pBlock, actor.x, actor.y + 5) then
				if Instance.exists(data.applier) then
					local wave1 = shockwave:create(actor.x, actor.y + 10)
					wave1.parent = data.applier
					Instance.get_data(wave1).enemymaxhp = actor.maxhp
					wave1.team = data.applier.team
					wave1.direction = 0
					wave1.image_xscale = 1
					local wave2 = shockwave:create(actor.x, actor.y + 10)
					wave2.parent = data.applier
					Instance.get_data(wave2).enemymaxhp = actor.maxhp
					wave2.team = data.applier.team
					wave2.direction = 180
					wave2.image_xscale = -1
				end
				rubble:create(actor.x, actor.y, 5)
				gm.sound_play_networked(gm.constants.wGolemAttack1, 0.8, 0.8 + math.random() * 0.2, actor.x, actor.y)
				gm.sound_play_networked(gm.constants.wLizardF_FlyingAttackStart, 0.8, 0.8 + math.random() * 0.2, actor.x, actor.y)
				actor:screen_shake(15)
				actor:buff_remove(debuffspiking)
			end
		end
		if not GM.actor_is_boss(actor) and not GM.actor_is_classic(actor) then
			actor.y = actor.y + 25
			if actor:is_colliding(gm.constants.pBlock, actor.x, actor.y + 5) then
				if Instance.exists(data.applier) then
					local wave1 = shockwave:create(actor.x, actor.y + 10)
					wave1.parent = data.applier
					wave1.team = data.applier.team
					wave1.direction = 0
					wave1.image_xscale = 1
					local wave2 = shockwave:create(actor.x, actor.y + 10)
					wave2.parent = data.applier
					wave2.team = data.applier.team
					wave2.direction = 180
					wave2.image_xscale = -1
				end
				rubble:create(actor.x, actor.y, 5)
				gm.sound_play_networked(gm.constants.wGolemAttack1, 0.8, 0.8 + math.random() * 0.2, actor.x, actor.y)
				gm.sound_play_networked(gm.constants.wLizardF_FlyingAttackStart, 0.8, 0.8 + math.random() * 0.2, actor.x, actor.y)
				actor:screen_shake(15)
				actor:buff_remove(debuffspiking)
			end
		end
	end
end)

Callback.add(debuffspiking.on_remove, function(actor)
	-- actor:kill() doesn't work bc rapi was totally ready to be released this soon
	actor.hp = -1000
end)

--hooks are literally not needed for this? this can just be handled with the buff? lol?

--local guarded = false

-- Hook.add_pre(gm.constants.actor_phy_on_landed, function(self, other, result, args)
    -- local real_self = Instance.wrap(self)
	-- if self:buff_count(debuffspiking) <= 0 then return end
    -- if not Util.bool(self.intangible) then
        -- self.intangible = 1
        -- guarded = true
    -- end
-- end)

-- Hook.add_post(gm.constants.actor_phy_on_landed, function(self, other, result, args)
    -- if guarded then
        -- guarded = false
    -- end
-- end)

Callback.add(Callback.ON_DAMAGED_PROC, function(actor, hit_info)
	local inflictor = hit_info.inflictor
	if Instance.exists(inflictor) then
		if inflictor:item_count(fin) <= 0 then return end
		
		if GM.actor_is_classic(actor) and not GM.actor_is_boss(actor) then
			if actor.object_index ~= gm.constants.oLizardFG and actor.object_index ~= gm.constants.oLizardF then
				if actor.elite_type ~= -1 and actor.hp <= actor.maxhp * ((0.13 * inflictor:item_count(fin)) / (1 + 0.13 * inflictor:item_count(fin))) then
					if actor.hp <= 0 then
						actor.hp = 1
						actor.dead = false
					end
					Instance.get_data(actor).applier = inflictor
					actor:buff_apply(debuffspiking, 600)
				end
			end
		end
	end
end)
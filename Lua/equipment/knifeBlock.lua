local sprite_block = Sprite.new("knifeBlock", path.combine(PATH, "Sprites/item/knifeBlock.png"), 2, 16, 17)
local sprite_block_empty = Sprite.new("knifeBlockEmpty", path.combine(PATH, "Sprites/item/knifeBlockEmpty.png"), 2, 16, 17)
local sprite_cut = Sprite.new("skillCut", path.combine(PATH, "Sprites/fx/skillCut.png"), 9, 55, 70)
local sprite_cut_throw = Sprite.new("skillCutThrow", path.combine(PATH, "Sprites/fx/skillCutThrow.png"), 1, 25, 5)
local sprite_cut_icon = Sprite.new("skillCutIcon", path.combine(PATH, "Sprites/fx/skillCutIcon.png"), 1)

local block = Equipment.new("knifeBlock")
block:set_sprite(sprite_block)
block.loot_tags = Item.LootTag.CATEGORY_DAMAGE, Item.LootTag.EQUIPMENT_BLACKLIST_CHAOS, Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR, Item.LootTag.EQUIPMENT_BLACKLIST_ENIGMA
block.cooldown = 30  

local swipe = Object.new("knifeBlockCutSwipe")
swipe:set_sprite(sprite_cut)

local wound = Buff.find("commandoWound", "ror")

Callback.add(swipe.on_draw, function(self)
	local parent = Instance.get_data(self).parent
	self.x = parent.x
	self.y = parent.y
	self.image_speed = math.min(parent.attack_speed * 0.25, 1.35)
	if self.image_index >= 8 then
		self:destroy()
		return
	end
end)

local knife = Object.new("knifeBlockCutThrow")
knife:set_sprite(sprite_cut_throw)

Callback.add(knife.on_create, function(self)
	self.speed = 20
	Instance.get_data(self).trailtimer = 0
	Instance.get_data(self).hit = 0
	Instance.get_data(self).lifetime = 0
	Sound.wrap(gm.constants.wMercenary_Parry_StandardSlash):play(self.x, self.y, 1, 0.9 + math.random() * 0.1)
end)

Callback.add(knife.on_step, function(self)
	if not Instance.exists(self.parent) then
		self:destroy()
		return
	end
	local data = Instance.get_data(self)
	
	data.trailtimer = data.trailtimer + 1
	data.lifetime = data.lifetime + 1
	
	if data.trailtimer >= 3 and data.hit == 0 then
		local trail = GM.instance_create(self.x, self.y, gm.constants.oEfTrail)
		trail.sprite_index = self.sprite_index
		trail.image_index = self.image_index
		trail.image_blend = gm.merge_colour(self.image_blend, Color.BLACK, 0.5)
		trail.image_xscale = self.image_xscale
		trail.image_yscale = self.image_yscale
		trail.depth = self.depth + 1
		data.trailtimer = 0
	end
	
	if self.parent:is_authority() and data.hit == 0 then
		for _, victim in ipairs(self:get_collisions(gm.constants.pActor)) do
			if victim.team ~= self.team then
				if not GM.skill_util_update_heaven_cracker(self.parent, damage, self.parent.image_xscale) then
					local buff_shadow_clone = Buff.find("shadowClone", "ror")
					for i=0, self.parent:buff_count(buff_shadow_clone) do
						data.hit = 1
						self.gravity = 0.3
						self.direction = 90 + math.random(0, 30) * self.image_xscale
						self.speed = math.random(5, 7)
						local direct = self.parent:fire_direct(victim, 2, self.direction, victim.x, victim.y, gm.constants.sEfSlash, false).attack_info
						if victim:buff_count(wound) > 0 then
							victim:apply_dot(1, 4, 30, self.parent, Color.RED)
							direct.knifeBlockWound = 1
						end
						direct.climb = i * 8
						break
					end
				end
			end
		end
	end
	
	if data.hit == 1 then
		self.image_angle = self.image_angle + 8 * self.image_xscale
	end
	
	if data.lifetime > 60 * 20 then
		self:destroy()
		return
	end
end)

local cut = Skill.new("knifeBlockCut")
cut.sprite = sprite_cut_icon
cut.subimage = 1
cut.cooldown = 15
cut.is_primary = true
cut.damage = 0.5
cut.hold_facing_direction = true
cut.required_interrupt_priority = ActorState.InterruptPriority.ANY

local state_cut = ActorState.new("knifeBlockCut")

Callback.add(cut.on_activate, function(actor)
	actor:set_state(state_cut)
end)

Callback.add(state_cut.on_enter, function(actor, data)
	local actorData = Instance.get_data(actor)
	
	data.fired = 0
	actor.activity_type = 4
	actorData.swipes = swipe:create(actor.x, actor.y)
	local swiper = actorData.swipes
	Instance.get_data(swiper).parent = actor
	actorData.swipes.image_xscale = actor.image_xscale
	Sound.wrap(gm.constants.wCrit2):play(actor.x, actor.y, 1, 0.9 + math.random() * 0.1)
end)

Callback.add(state_cut.on_step, function(actor, data)
	actor.pHspeed = actor.pHspeed * 0.65
	local actorData = Instance.get_data(actor)
	
	if actor:is_authority() and data.fired == 0 and actorData.swipes.image_index >= 4 then
		local damage = actor:skill_get_damage(cut)
		
		Sound.wrap(gm.constants.wMinerShoot1_1):play(actor.x, actor.y, 1, 0.8 + math.random() * 0.4)
		if not GM.skill_util_update_heaven_cracker(actor, damage, actor.image_xscale) then
			local buff_shadow_clone = Buff.find("shadowClone")
			for i=0, actor:buff_count(buff_shadow_clone) do
				local slash = actor:fire_explosion(actor.x + actor.image_xscale * 30, actor.y - 15, 130, 110, damage, nil, gm.constants.sEfSlash).attack_info
				slash.climb = i * 8
				slash.knifeBlockWound = 1
			end
		end
		
		data.fired = 1
	end
	local funnySwipe = Instance.wrap(actorData.swipes)
	if not Instance.exists(funnySwipe) then
		actor:skill_util_reset_activity_state()
	end
end)

Callback.add(state_cut.on_exit, function(actor, data)
	Instance.get_data(actor).swipes:destroy()
end)

Callback.add(state_cut.on_get_interrupt_priority, function(actor, data)
	if Instance.get_data(actor).swipes.image_index >= 5 then
		return ActorState.InterruptPriority.SKILL_INTERRUPT_PERIOD
	end
end)

Callback.add(Callback.ON_ATTACK_HIT, function(hit_info)
	local woundmaxstack = hit_info.attack_info.knifeBlockWound
	if woundmaxstack and woundmaxstack > 0 then
		victim = hit_info.target
		if victim:buff_count(wound) <  woundmaxstack then
			GM.apply_buff(victim, wound, 6 * 60, 1)
		else
			GM.set_buff_time(victim, wound, 6 * 60)
		end
	end
end)

Callback.add(Callback.ON_GAME_END, function()
	block:set_sprite(sprite_block)
	block.cooldown = 30
end)

Callback.add(block.on_use, function(actor)
		if Instance.get_data(actor).holdingknife == nil then
			block:set_sprite(sprite_block_empty)
			block.cooldown = 60 * 24
			Instance.get_data(actor).holdingknife = true
			actor:add_skill_override(0, cut, 10)
		else
			block:set_sprite(sprite_block)
			block.cooldown = 30
			Instance.get_data(actor).holdingknife = nil
			actor:remove_skill_override(0, cut, 10)
			
			local knifethrow = knife:create(actor.x + 30 * actor.image_xscale, actor.y)
			knifethrow.parent = actor
			knifethrow.team = actor.team
			knifethrow.direction = actor:skill_util_facing_direction()
			knifethrow.image_xscale = actor.image_xscale
		end
end)

Callback.add(Callback.ON_EQUIPMENT_SWAP, function(actor, new, old)
	if new == block then
		block:set_sprite(sprite_block)
	end
	if old == block then
		if Instance.get_data(actor).holdingknife ~= nil then
			local knifethrow = knife:create(actor.x - 12 * actor.image_xscale, actor.y)
			knifethrow.parent = actor
			knifethrow.team = actor.team
			knifethrow.direction = actor:skill_util_facing_direction()
			knifethrow.image_xscale = actor.image_xscale
		end
		block:set_sprite(sprite_block)
		block.cooldown = 30
		Instance.get_data(actor).holdingknife = nil
		actor:remove_skill_override(0, cut, 10)
	end
end)
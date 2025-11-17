local sprite_treatment = Sprite.new("specialTreatment", path.combine(PATH, "Sprites/item/specialTreatment.png"), 1, 16, 16)
local sprite_treatment_used = Sprite.new("specialTreatmentConsumed", path.combine(PATH, "Sprites/item/specialTreatmentConsumed.png"), 1, 16, 16)
local sprite_buff_icon = Sprite.new("specialTreatmentBuff", path.combine(PATH, "Sprites/buffs/specialTreatmentBuff.png"), 1, 18, 14)

local treatment = Item.new("specialTreatment")
treatment:set_sprite(sprite_treatment)
treatment:set_tier(ItemTier.COMMON)
treatment.loot_tags = Item.LootTag.CATEGORY_HEALING, Item.LootTag.CATEGORY_UTILITY

local log = ItemLog.new_from_item(treatment)
log.group = ItemLog.Group.COMMON

local treatment_used = Item.new("specialTreatmentConsumed")
treatment_used:set_sprite(sprite_treatment_used)
treatment_used:toggle_loot(false)
treatment_used.loot_tags = Item.LootTag.ITEM_BLACKLIST_VENDOR, Item.LootTag.ITEM_BLACKLIST_INFUSER

local parspeed = Particle.find("Fire2")
parspeed:set_alpha2(0.75, 0)

local buffspeed = Buff.new("specialTreatmentSpeed")
buffspeed.max_stack = 1
buffspeed.show_icon = true
buffspeed.icon_sprite = sprite_buff_icon

RecalculateStats.add(function(actor, api)
	if actor:buff_count(buffspeed) <= 0 then return end
	api.pHmax_add(0.7 * (actor:item_count(treatment_used) + actor:item_count(treatment)))
end)

Callback.add(buffspeed.on_step, function(actor)
	Instance.get_data(actor).parspeed = Instance.get_data(actor).parspeed + 1
	
	if Util.bool(actor.barrier) and Instance.get_data(actor).parspeed >= 6 then
		parspeed:create(actor.x, actor.y - math.random(-6, 6), 1, Particle.System.BELOW)
		Instance.get_data(actor).parspeed = 0
	end
end)

Callback.add(treatment.on_acquired, function(actor)
	Instance.get_data(actor).parspeed = 0
end)

Callback.add(Callback.ON_DAMAGED_PROC, function(actor, hit_info)

	if Net.client then return end
	
	if actor:item_count(treatment) <= 0 then return end
	
	if actor.hp < actor.maxhp * 0.251 then
		actor:heal_barrier(actor.maxbarrier * 0.75 - (actor.maxhp * 0.251 - actor.hp))
		actor.hp = actor.maxhp * 0.251
		local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
		flash.parent = actor
		flash.rate = 0.1
		flash.image_alpha = 0.5
		flash.image_blend = Color.YELLOW
		Sound.wrap(gm.constants.wBarrierActivate):play(actor.x, actor.y, 1, 0.8 + math.random() * 0.2)
		Sound.wrap(gm.constants.wChildDeath):play(actor.x, actor.y, 1, 1.6 + math.random() * 0.4)
		--get rid of the temp stacks if its consumed while temp
		local normal = actor:item_count(treatment, Item.StackKind.NORMAL)
        local temp = actor:item_count(treatment, Item.StackKind.TEMPORARY_BLUE)
		local temp2 = actor:item_count(treatment, Item.StackKind.TEMPORARY_RED)
		
		--temp item stuff
		if normal > 0 and not (temp > 0 or temp2 > 0) then
            actor:item_take(treatment, 1, Item.StackKind.NORMAL)
            actor:item_give(treatment_used, 1, Item.StackKind.NORMAL)
        end
		
        if temp > 0 then
            actor:item_take(treatment, 1, Item.StackKind.TEMPORARY_BLUE)
            actor:item_give(treatment_used, 1, Item.StackKind.TEMPORARY_BLUE)
        end
		
		--the first time this was cared about ever bc magician's hat
		if temp2 > 0 then
            actor:item_take(treatment, 1, Item.StackKind.TEMPORARY_RED)
            actor:item_give(treatment_used, 1, Item.StackKind.TEMPORARY_RED)
        end
	end
end)

Callback.add(Callback.ON_STEP, function()
	
	for _, actor in ipairs(treatment:get_holding_actors()) do
		if gm.bool(actor.barrier) then
			actor:buff_apply(buffspeed, 30)
		else
			actor:buff_remove(buffspeed, 30)
		end
	end
	
	for _, actor in ipairs(treatment_used:get_holding_actors()) do
		if gm.bool(actor.barrier) then
			actor:buff_apply(buffspeed, 30)
		else
			actor:buff_remove(buffspeed, 30)
		end
	end
	

end)

Callback.add(treatment_used.on_acquired, function(actor)
	Instance.get_data(actor).parspeed = 0
end)

Callback.add(Callback.ON_STAGE_START, function()
	for _, actor in ipairs(treatment_used:get_holding_actors()) do
		local normal = actor:item_count(treatment_used, Item.StackKind.NORMAL)
		local temp = actor:item_count(treatment_used, Item.StackKind.TEMPORARY_BLUE)
		local temp2 = actor:item_count(treatment, Item.StackKind.TEMPORARY_RED)
		
		if normal > 0 then
			actor:item_give(treatment, normal, Item.StackKind.NORMAL)
			actor:item_take(treatment_used, normal, Item.StackKind.NORMAL)
		end
		
		if temp > 0 then
			actor:item_give(treatment, temp, Item.StackKind.TEMPORARY_BLUE)
			actor:item_take(treatment_used, temp, Item.StackKind.TEMPORARY_BLUE)
		end
		
		if temp > 0 then
			actor:item_give(treatment, temp, Item.StackKind.TEMPORARY_RED)
			actor:item_take(treatment_used, temp, Item.StackKind.TEMPORARY_RED)
		end
	end
end)
local sprite_nanomachines = Sprite.new("nanomachines", path.combine(PATH, "Sprites/item/nanomachines.png"), 1, 16, 15)

local son = Item.new("nanomachines")
son:set_sprite(sprite_nanomachines)
son:set_tier(ItemTier.RARE)
son.loot_tags = Item.LootTag.CATEGORY_UTILITY, Item.LootTag.CATEGORY_HEALING

local log = ItemLog.new_from_item(son)
log.group = ItemLog.Group.RARE

local buffArmor = Buff.new("nanoArmorBuff")
buffArmor.max_stack = 1
buffArmor.show_icon = false

RecalculateStats.add(function(actor, api)
	if actor:buff_count(buffArmor) <= 0 then return end
	api.armor_add((actor.maxshield_base * actor:item_count(son)) * 0.5)
end)

Callback.add(son.on_acquired, function(actor)

	if actor.nanCooldown == nil then
		actor.nanCooldown = 0
	end

	if not actor.shieldStore then
		actor.shieldStore = 0
	end
	
	if not actor.procced then
		actor.procced = false
	end

end)

Callback.add(Callback.ON_DAMAGED_PROC, function(actor, hit_info)
--credit to TryAgain211 for helping with most of this implementation
	if Net.client then return end
	
	if actor:item_count(son) <= 0 then return end
	local stack = actor:item_count(son)

	if actor.nanCooldown <= 0 and actor.shield < 1 and actor.hp <= actor.maxhp * 0.5 then
		actor.maxshield_base = actor.maxshield_base + (60 * stack)
		actor.shieldStore = actor.shieldStore + (60 * stack)
		actor.shield = actor.maxshield_base
		Sound.wrap(gm.constants.wDroneUpgrader_Activate):play(actor.x, actor.y, 2, 1.2)
		
		local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
		flash.parent = actor
		flash.rate = 0.05
		flash.image_alpha = 1
		flash.image_blend = Color.BLACK
		
		actor.nanCooldown = 60 * 15
		actor.procced = true
	end
	
	if actor.shield < actor.maxshield_base then
		local lost = math.min(actor.maxshield_base - actor.shield, actor.shieldStore)
		actor.maxshield_base = actor.maxshield_base - lost
		actor.shieldStore = actor.shieldStore - lost
	end

end)

Callback.add(Callback.ON_STEP, function()
	for _, actor in ipairs(son:get_holding_actors()) do
		if Util.bool(actor.shield) then
			actor:buff_apply(buffArmor, 30)
		end
		
		if actor.nanCooldown and actor.nanCooldown > 0 then
			actor.nanCooldown = actor.nanCooldown - 1
		end
		
		if actor.nanCooldown and actor.nanCooldown <= 0 and actor.procced == true then
			Sound.wrap(gm.constants.wDroneUpgrader_Activate):play(actor.x, actor.y, 2, 0.8)
			local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
			flash.parent = actor
			flash.rate = 0.05
			flash.image_alpha = 0.8
			flash.image_blend = Color.AQUA
			actor.procced = false
		end
	end

end)
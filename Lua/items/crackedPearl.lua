local sprite_purl = Sprite.new("CrackedPearl", path.combine(PATH, "Sprites/item/crackedPearl.png"), 1, 17, 17)

local purl = Item.new("crackedPearl")
purl:set_sprite(sprite_purl)
purl:set_tier(ItemTier.UNCOMMON)
purl.loot_tags = Item.LootTag.CATEGORY_UTILITY + Item.LootTag.CATEGORY_DAMAGE + Item.LootTag.CATEGORY_HEALING

local log = ItemLog.new_from_item(purl)
log.group = ItemLog.Group.UNCOMMON

--this smells like really bad

Callback.add(purl.on_acquired, function(actor)
	for i = 1, 2 do
		actor.pearlRoll = math.random(1,8)
		print(actor.pearlRoll)
		if actor.pearlRoll == 8 then
			RecalculateStats.add(function(actor, api)
				local stacks = actor:item_count(purl)
				if stacks <= 0 then return end
					api.hp_regen_add(0.08 + (0.02 * stacks))
					-- print("regen")
			end)
		elseif actor.pearlRoll == 7 then
			RecalculateStats.add(function(actor, api)
				local stacks = actor:item_count(purl)
				if stacks <= 0 then return end
					api.armor_mult(1 + (0.1 * stacks))
					-- print("armor")
			end)
		elseif actor.pearlRoll == 6 then
			RecalculateStats.add(function(actor, api)
				local stacks = actor:item_count(purl)
				if stacks <= 0 then return end
					api.attack_speed_add(0.1 * stacks)
					-- print("AtSpeed")
			end)
		elseif actor.pearlRoll == 5 then
			RecalculateStats.add(function(actor, api)
				local stacks = actor:item_count(purl)
				if stacks <= 0 then return end
					api.critical_chance_add(10 * stacks)
					-- print("Crit")
			end)
		elseif actor.pearlRoll == 4 then
			RecalculateStats.add(function(actor, api)
				local stacks = actor:item_count(purl)
				if stacks <= 0 then return end
					api.pHmax_add(0.2 * stacks)
					-- print("Speed is key")
			end)
		elseif actor.pearlRoll == 3 then
			RecalculateStats.add(function(actor, api)
				local stacks = actor:item_count(purl)
				if stacks <= 0 then return end
					api.pVmax_add(0.4 * stacks)
					-- print("boing")
			end)
		elseif actor.pearlRoll == 2 then
			RecalculateStats.add(Callback.Priority.AFTER, function(actor, api)
				local stacks = actor:item_count(purl)
				if stacks <= 0 then return end
					api.damage_mult(1 + (0.1 * stacks))
					-- print("damge")
			end)
		elseif actor.pearlRoll == 1 then
			RecalculateStats.add(Callback.Priority.AFTER, function(actor, api)
				local stacks = actor:item_count(purl)
				if stacks <= 0 then return end
					api.maxhp_mult(1 + (0.1 * stacks))
					-- print("Soul !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			end)
		end
	end
end)
local sprite_pizza = Sprite.new("Pizza", path.combine(PATH, "Sprites/item/pizza.png"), 1, 16, 16)

local pizza = Item.new("pizza")
pizza:set_sprite(sprite_pizza)
pizza:set_tier(ItemTier.RARE)
pizza.loot_tags = Item.LootTag.CATEGORY_DAMAGE + Item.LootTag.CATEGORY_UTILITY + Item.LootTag.CATEGORY_HEALING

local log = ItemLog.new_from_item(pizza)
log.group = ItemLog.Group.RARE

-- local maxhp_old
-- local hp_old
-- Hook.add_pre(gm.constants.recalculate_stats, function(self, other, result, args)
	-- if self:item_count(pizza) <= 0 then return end
	-- maxhp_old = self.maxhp
	-- hp_old = self.hp
-- end)
--No longer needed as of RAPI 0.1.41

RecalculateStats.add(function(actor, api)
	local stacks = actor:item_count(pizza)
	if stacks <= 0 then return end
	
	-- actor.hp_regen = actor.hp_regen + (0.05 * stacks)
	-- actor.armor = actor.armor + (14 * stacks)
	-- actor.attack_speed = actor.attack_speed + (0.25 * stacks)
	-- actor.critical_chance = actor.critical_chance + (15 * stacks)
	-- actor.pHmax = actor.pHmax + (0.56 * stacks)
	-- actor.pVmax = actor.pVmax + (1 * stacks)
	--new syntax as of 0.1.41
	api.hp_regen_add(0.05 * stacks)
	api.armor_add(14 * stacks)
	api.attack_speed_add(0.25 * stacks)
	api.critical_chance_add(15 * stacks)
	api.pHmax_add(0.56 * stacks)
	api.pVmax_add(1 * stacks)
	print("pizza")
end)

RecalculateStats.add(Callback.Priority.AFTER, function(actor, api)
	local stacks = actor:item_count(pizza)
	if stacks <= 0 then return end
	
	-- actor.damage = math.ceil(actor.damage * (1 + (0.15 * stacks)))
	-- actor.maxhp = math.ceil(actor.maxhp * (1 + (0.15 * stacks)))
	-- local hp_restore = hp_old - actor.hp
	-- actor.hp = math.min(actor.maxhp, actor.hp + math.max(0, actor.maxhp - maxhp_old + hp_restore))
	api.damage_mult(1 + (0.15 * stacks))
	api.maxhp_mult(1 + (0.15 * stacks))
	print("pizza2")
end)
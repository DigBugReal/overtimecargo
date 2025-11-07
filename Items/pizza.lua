local sprite_pizza = Sprite.new("Pizza", path.combine(PATH, "Sprites/item/pizza.png"), 1, 16, 16)

local pizza = Item.new("pizza")
pizza:set_sprite(sprite_pizza)
pizza:set_tier(ItemTier.RARE)
pizza.loot_tags = Item.LootTag.CATEGORY_DAMAGE, Item.LootTag.CATEGORY_UTILITY, Item.LootTag.CATEGORY_HEALING

local log = ItemLog.new_from_item(pizza)
log.group = ItemLog.Group.RARE

local maxhp_old
local hp_old
Hook.add_pre(gm.constants.recalculate_stats, function(self, other, result, args)
	maxhp_old = self.maxhp
	hp_old = self.hp
end)

RecalculateStats.add(function(actor)
	local stacks = actor:item_count(pizza)
	if stacks <= 0 then return end
	
	actor.hp_regen = actor.hp_regen + 0.05 * stacks
	actor.armor = actor.armor + 14 * stacks
	actor.attack_speed = actor.attack_speed + 0.25 * stacks
	actor.critical_chance = actor.critical_chance + 15 * stacks
	actor.pHmax = actor.pHmax + 0.56 * stacks
	actor.pVmax = actor.pVmax + 1 * stacks
	
	actor.damage = math.ceil(actor.damage * (1 + (0.15 * stacks)))
	actor.maxhp = math.ceil(actor.maxhp * (1 + (0.15 * stacks)))
	local hp_restore = hp_old - actor.hp
	actor.hp = math.min(actor.maxhp, actor.hp + math.max(0, actor.maxhp - maxhp_old + hp_restore))
	
end)

-- Callback.add(pizza.on_removed, function()
	-- RecalculateStats.remove(function(actor) --idk if this needs to be done for if the item gets removed
-- end
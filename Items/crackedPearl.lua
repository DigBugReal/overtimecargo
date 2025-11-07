-- local sprite_purl = Sprite.new("CrackedPearl", path.combine(PATH, "Sprites/item/crackedPearl.png"), 1, 17, 17)

-- -- new cracked pearl rework: Grants a strong increase to only 1 random stat on pickup. Random for each pickup.
-- -- not finished bc im lazy

-- local purl = Item.new("crackedPearl")
-- purl:set_sprite(sprite_purl)
-- purl:set_tier(ItemTier.UNCOMMON)
-- purl.loot_tags = Item.LootTag.CATEGORY_UTILITY, Item.LootTag.CATEGORY_DAMAGE, Item.LootTag.CATEGORY_HEALING

-- local log = ItemLog.new_from_item(purl)
-- log.group = ItemLog.Group.UNCOMMON

-- local maxhp_old
-- local hp_old
-- Hook.add_pre(gm.constants.recalculate_stats, function(self, other, result, args)
	-- maxhp_old = self.maxhp
	-- hp_old = self.hp
-- end)

-- RecalculateStats.add(function(actor)
	-- local stacks = actor:item_count(purl)
	-- if stacks <= 0 then return end
	
	-- local roll = math.random(1, 8)
	-- if math.ceil(roll) == 8 then
		-- actor.hp_regen = actor.hp_regen + 0.1 * stacks
		-- print("regen")
	-- elseif math.ceil(roll) == 7 then
		-- actor.armor = actor.armor + 28 * stacks
		-- print("armor")
	-- elseif math.ceil(roll) == 6 then
		-- actor.attack_speed = actor.attack_speed + 0.5 * stacks
		-- print("AtSpeed")
	-- elseif math.ceil(roll) == 5 then
		-- actor.critical_chance = actor.critical_chance + 20 * stacks
		-- print("Crit")
	-- elseif math.ceil(roll) == 4 then
		-- actor.pHmax = actor.pHmax + 0.56 * stacks
		-- print("Speed is key")
	-- elseif math.ceil(roll) == 3 then
		-- actor.pVmax = actor.pVmax + 1 * stacks
		-- print("boing")
	-- elseif math.ceil(roll) == 2 then
		-- actor.damage = math.ceil(actor.damage * (1.15 + (0.15 * stacks)))
		-- print("damge")
	-- elseif math.ceil(roll) == 1 then
		-- actor.maxhp = math.ceil(actor.maxhp * (1.15 + (0.15 * stacks)))
		-- local hp_restore = hp_old - actor.hp
		-- actor.hp = math.min(actor.maxhp, actor.hp + math.max(0, actor.maxhp - maxhp_old + hp_restore))
		-- print("Soul !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	-- end
	
-- end)

-- -- Callback.add(Callback.ON_STAGE_START, function()
    -- -- for _, player in ipairs(Instance.find_all(gm.constants.oP)) do
        -- -- purl:create(player.x, player.y)
    -- -- end
-- -- end)
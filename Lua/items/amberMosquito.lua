local sprite_amber = Sprite.new("AmberMosquito", path.combine(PATH, "Sprites/item/amberMosquito.png"), 1, 17, 17)

local amber = Item.new("amberMosquito", NAMESPACE)
amber:set_sprite(sprite_amber)
amber:set_tier(ItemTier.RARE)
amber.loot_tags = Item.LootTag.CATEGORY_UTILITY

local log = ItemLog.new_from_item(amber)
log.group = ItemLog.Group.RARE

Callback.add(Callback.ON_ENEMY_INIT, function(enemy)
	for _, actor in ipairs(Instance.find_all(gm.constants.oP)) do
		local count = actor:item_count(amber)
		if count >= 1 then
			for i = 1, count, 1 do
				if i == 1 then
					enemy.maxhp_base = enemy.maxhp_base * 0.75
					enemy.hp = enemy.maxhp_base
				else
					enemy.maxhp_base = enemy.maxhp_base * 0.90
					enemy.hp = enemy.maxhp_base
				end
			end
		end
	end
end)
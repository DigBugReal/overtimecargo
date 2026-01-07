local sprite_manip = Sprite.new("unstableManipulator", path.combine(PATH, "Sprites/item/unstableManipulator.png"), 1, 16, 16)

local manip = Item.new("unstableManipulator")
manip:set_sprite(sprite_manip)
manip:set_tier(ItemTier.UNCOMMON)
manip.loot_tags = Item.LootTag.CATEGORY_UTILITY

local log = ItemLog.new_from_item(manip)
log.group = ItemLog.Group.UNCOMMON

Callback.add(Callback.ON_DIRECTOR_POPULATE_SPAWN_ARRAYS, function()
	local count = 0
	for _, player in ipairs(Instance.find_all(gm.constants.oP)) do
		count = count + player:item_count(manip)
	end
	GM._mod_game_getDirector().pos_points = GM._mod_game_getDirector().pos_points * math.max(1 + ((math.sqrt(count) - 0.5) / 3), 1)
end)
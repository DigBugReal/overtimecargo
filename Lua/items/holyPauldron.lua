local sprite_holy = Sprite.new("holyPauldronSprite", path.combine(PATH, "Sprites/item/holyPauldron.png"), 1, 17, 17)
local sprite_buff = Sprite.new("holyBuffIcon", path.combine(PATH, "Sprites/buffs/moonrockBuff1.png"), 1, 8, 8)

local holy = Item.new("holyPauldron", NAMESPACE)
holy:set_sprite(sprite_holy)
holy:set_tier(ItemTier.RARE)
holy.loot_tags = Item.LootTag.CATEGORY_HEALING + Item.LootTag.CATEGORY_UTILITY

local log = ItemLog.new_from_item(holy)
log.group = ItemLog.Group.RARE

local holyBuff = Buff.new("holyPauldronNoDecay", NAMESPACE)
holyBuff.show_icon = true
holyBuff.icon_sprite = sprite_buff

Callback.add(Callback.ON_KILL_PROC, function(target, attacker)
	if attacker:item_count(holy) <= 0 then return end
	local stacks = attacker:item_count(holy)
	--checks if the enemy is an elite of any type
	if target.elite_type ~= -1 then
		attacker:heal_barrier(attacker.maxbarrier * (0.05 + (0.1 * stacks)))
		attacker:buff_apply(holyBuff, 60 * (2 + (3 * stacks)))
	end
	
end)

Callback.add(holyBuff.on_step, function()

--stops barrier decay by adding the decay formula directly to barrier stat
for _, actor in ipairs(holy:get_holding_actors()) do
	if Util.bool(actor.barrier) then
		actor.barrier = actor.barrier + ((actor.maxbarrier / 30 / 60) * gm.lerp(0.5, 3, actor.barrier / actor.maxbarrier))
	end
end

end)
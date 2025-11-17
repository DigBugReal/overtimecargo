local sprite_let = Sprite.new("resigLetter", path.combine(PATH, "Sprites/item/resignationLetter.png"), 1, 16, 16)

--new Fine Print/Sketchy Contract rework: Resignation Letter
--Killing an elite grants a buff that increases base damage by 30% +(15% per stack) for 10 (+3 per stack) seconds.

local let = Item.new("resignationLetter")
let:set_sprite(sprite_let)
let:set_tier(ItemTier.UNCOMMON)
let.loot_tags = Item.LootTag.CATEGORY_DAMAGE

local log = ItemLog.new_from_item(let)
log.group = ItemLog.Group.UNCOMMON

local buff = Buff.new("letDamage")
buff.max_stack = 1
buff.show_icon = false
-- buffspeed.icon_sprite = tem_nada

RecalculateStats.add(Callback.Priority.AFTER, function(actor, api)
	if actor:buff_count(buff) <= 0 then return end
	api.damage_mult(1.15 + (0.15 * actor:item_count(let)))
end)

Callback.add(Callback.ON_KILL_PROC, function(target, attacker)
	if attacker:item_count(let) <= 0 then return end
	local stacks = attacker:item_count(let)
	--checks if the enemy is an elite of any type
	if target.elite_type ~= -1 then
		attacker:buff_apply(buff, 60 * (7 + (3 * stacks)))
	end
	
end)
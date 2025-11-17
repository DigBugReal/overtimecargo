local sprite_nrg = Sprite.new("energyDrinkSprite", path.combine(PATH, "Sprites/item/energyDrink.png"), 1, 16, 14)
local sprite_buff = Sprite.new("drinkBuffIcon", path.combine(PATH, "Sprites/buffs/moonrockBuff1.png"), 1, 8, 8)

local sound_drink = Sound.new("drinkSound", path.combine(PATH, "Sounds/energyDrink.ogg"))

local nrg = Item.new("energyDrink")
nrg:set_sprite(sprite_nrg)
nrg:set_tier(ItemTier.COMMON)
nrg.loot_tags = Item.LootTag.CATEGORY_DAMAGE, Item.LootTag.CATEGORY_UTILITY

local log = ItemLog.new_from_item(nrg)
log.group = ItemLog.Group.COMMON

local buff = Buff.new("drinkBuff")
buff.show_icon = true
buff.icon_sprite = sprite_buff

RecalculateStats.add(function(actor, api)
	if actor:buff_count(buff) <= 0 then return end
	
	local stacks = actor:item_count(nrg)
	api.pHmax_add(0.22 + (0.48 * stacks))
	actor.attack_speed = actor.attack_speed + (0.08 + (0.17 * stacks))

end)

Callback.add(Callback.ON_STAGE_START, function()
	for _, actor in ipairs(nrg:get_holding_actors()) do
		--wait a bit
		local function wait()
			if Instance.exists(actor) then
				actor:buff_apply(buff, (60 * (25 + (5 * actor:item_count(nrg)))))
				sound_drink:play(actor.x, actor.y, 1, 0.9 + math.random() * 0.2)
			end
		end
		Alarm.add(90, wait)
	end

end)
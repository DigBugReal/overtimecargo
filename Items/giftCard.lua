local sprite_card = Sprite.new("cardSprite", path.combine(PATH, "Sprites/item/giftCard.png"), 1, 16, 14)

local card = Item.new("giftCard")
card:set_sprite(sprite_card)
card:set_tier(ItemTier.COMMON)
card.loot_tags = Item.LootTag.CATEGORY_UTILITY

local log = ItemLog.new_from_item(card)
log.group = ItemLog.Group.COMMON

--needs vfx, sound, and maybe change how gold is given

Callback.add(Callback.ON_INTERACTABLE_ACTIVATE, function(interactable, player)
	for _, actor in ipairs(card:get_holding_actors()) do
		local stacks = actor:item_count(card)
		if interactable.cost ~= nil and interactable.cost_type == 0 then
			local oHUD = GM._mod_game_getHUD()
			if oHUD ~= -4 then
				oHUD.gold = oHUD.gold + (interactable.cost * (1 - 1 / (1 + 0.05 + (0.1 * stacks))))
			end
		end
	end
end)

Callback.add(Callback.ON_STAGE_START, function()
	for _, actor in ipairs(card:get_holding_actors()) do
		--wait a bit
		local function wait()
			if Instance.exists(actor) then
				local oHUD = GM._mod_game_getHUD()
				if oHUD ~= -4 then
					oHUD.gold = oHUD.gold + math.ceil((30 * GM._mod_game_getDirector().stage_chest_cost_scale) * actor:item_count(card))
				end
			end
		end
		Alarm.add(90, wait)
	end

end)

-- Callback.add(Callback.ON_STAGE_START, function()
    -- for _, player in ipairs(Instance.find_all(gm.constants.oP)) do
        -- card:create(player.x + 200, player.y)
    -- end
-- end)
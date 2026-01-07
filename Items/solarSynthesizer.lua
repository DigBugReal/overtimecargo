local sprite_solar = Sprite.new("solarSynthesizerSpr", path.combine(PATH, "Sprites/item/SolarSynthesizer.png"), 1, 17, 17)
-- local sprite_buff = Sprite.new("solarBuffIcon", path.combine(PATH, "Sprites/buffs/moonrockBuff1.png"), 1, 8, 8)

local solar = Item.new("solarSynthesizer", NAMESPACE)
solar:set_sprite(sprite_solar)
solar:set_tier(ItemTier.COMMON)
solar.loot_tags = Item.LootTag.CATEGORY_HEALING, Item.LootTag.CATEGORY_UTILITY

local log = ItemLog.new_from_item(solar)
log.group = ItemLog.Group.COMMON

Callback.add(Callback.ON_EQUIPMENT_USE, function(player)
	if player:item_count(solar) <= 0 then return end
	player:heal_barrier(player.maxbarrier * (0.20 * player:item_count(solar)))
end)

Callback.add(Callback.ON_STEP, function()

for _, actor in ipairs(solar:get_holding_actors()) do
	if Util.bool(actor.barrier) then
		local decayForm = ((actor.maxbarrier / 30 / 60) * gm.lerp(0.5, 3, actor.barrier / actor.maxbarrier)) 
		actor.barrier = actor.barrier + ( decayForm * (0.05 * actor:item_count(solar)) )
	end
end

end)

--alt effect

-- local sprite_solar = Sprite.new("solarSynthesizerSpr", path.combine(PATH, "Sprites/item/SolarSynthesizer.png"), 1, 17, 17)
-- -- local sprite_buff = Sprite.new("solarBuffIcon", path.combine(PATH, "Sprites/buffs/moonrockBuff1.png"), 1, 8, 8)

-- local solar = Item.new("solarSynthesizer", NAMESPACE)
-- solar:set_sprite(sprite_solar)
-- solar:set_tier(ItemTier.UNCOMMON)
-- solar.loot_tags = Item.LootTag.CATEGORY_HEALING, Item.LootTag.CATEGORY_DAMAGE

-- local log = ItemLog.new_from_item(solar)
-- log.group = ItemLog.Group.UNCOMMON

-- Callback.add(Callback.ON_STEP, function()

-- for _, actor in ipairs(solar:get_holding_actors()) do

	-- if actor.still_timer >= 2 *60.0 and actor.barrier < actor.maxbarrier * (0.1 + (0.15 * actor:item_count(solar))) then
		-- if actor:item_count(Item.find("aegis", "ror")) < 1 then
			-- actor.barrier = actor.barrier + 0.5
		-- else
			-- actor.barrier = actor.barrier + (0.5 * actor:item_count(Item.find("aegis", "ror")))
		-- end
    -- end
	
	-- if Util.bool(actor.barrier) then
		-- actor.barrierExplosion = 1
	-- elseif not Util.bool(actor.barrier) and actor.barrierExplosion ~= nil then
		-- actor.barrierExplosion = nil
		-- local dmg = 0.8 * actor:item_count(solar)
		-- local explosion = actor:fire_explosion(actor.x, actor.y, 120, 120, dmg * actor.damage, gm.constants.sEfArtiStarExplode, gm.constants.sEfGoldSparkleBig).attack_info
		-- explosion:set_knockback(1, 60 * 1.5, 5)
		-- Sound.wrap(gm.constants.wTurtleExplosion):play(actor.x, actor.y, 1, 0.6)
		-- Sound.wrap(gm.constants.wWormExplosion):play(actor.x, actor.y, 1, 0.8)
	-- end
-- end

-- end)
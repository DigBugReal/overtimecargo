--only commented out bc lootbug doesn't work, waiting for more references on enemies
-- local sprite_dust = Sprite.new("goldDust", path.combine(PATH, "Sprites/item/goldDust.png"), 1, 16, 17)

-- local dust = Item.new("goldDust")
-- dust:set_sprite(sprite_dust)
-- dust:set_tier(ItemTier.UNCOMMON)
-- dust.loot_tags = Item.LootTag.CATEGORY_UTILITY

-- local log = ItemLog.new_from_item(dust)
-- log.group = ItemLog.Group.UNCOMMON

-- Callback.add(Callback.ON_HIT_PROC, function(actor, target, hit_info)
	-- if actor:item_count(dust) <= 0 then return end
	-- for _, actor in ipairs(dust:get_holding_actors()) do
		-- local stack = actor:item_count(dust)
		-- local gold = gm.instance_create(target.x, target.y, gm.constants.oEfGold)
		-- gold.value = 0.5 * (hit_info.damage / actor.damage) * stack * GM._mod_game_getDirector().stage_chest_cost_scale
		-- gold.vspeed = -1 * math.random(3)
		-- gold.hspeed = math.random(3)
	-- end
-- end)

-- Callback.add(dust.on_acquired, function(actor)
	-- local data = Instance.get_data(actor)
	-- local tp = Instance.find(gm.constants.oTeleporter)
	-- local dtp = Instance.find(gm.constants.oTeleporterEpic)
	-- local com = Instance.find(gm.constants.oCommand)
	
	-- if data.lootbugspawned == nil then
		-- if tp.just_activated == 1 or dtp.just_activated == 1 or com.just_activated == 1 then
			-- data.lootbugspawned = 1
		-- else
			-- data.lootbugspawned = 0
		-- end
	-- end
-- end)

-- Callback.add(Callback.ON_STEP, function()
	-- for _, actor in ipairs(dust:get_holding_actors()) do
		-- local data = Instance.get_data(actor)
		-- local tp = Instance.find(gm.constants.oTeleporter)
		-- local dtp = Instance.find(gm.constants.oTeleporterEpic)
		-- local com = Instance.find(gm.constants.oCommand)
		
		-- if data.lootbugspawned == 0 then
			-- if tp.just_activated == 1 then
				-- local lootbug = Object.find("Lootbug", NAMESPACE):create(tp.x + math.random(-20, 20), tp.y - 13)
				-- lootbug.itemcount = math.min(9, math.floor(actor.gold * 0.01 / GM._mod_game_getDirector().stage_chest_cost_scale))
				-- data.lootbugspawned = 1
				
			-- elseif dtp.just_activated == 1 then
				-- local lootbug = Object.find("Lootbug", NAMESPACE):create(dtp.x + math.random(-20, 20), dtp.y - 13)
				-- lootbug.itemcount = math.min(9, math.floor(actor.gold * 0.01 / GM._mod_game_getDirector().stage_chest_cost_scale))
				-- data.lootbugspawned = 1
				
			-- elseif com.just_activated == 1 then
				-- local lootbug = Object.find("Lootbug", NAMESPACE):create(com.x + math.random(-20, 20), com.y - 13)
				-- lootbug.itemcount = math.min(9, math.floor(actor.gold * 0.01 / GM._mod_game_getDirector().stage_chest_cost_scale))
				-- data.lootbugspawned = 1		
			-- end
		-- end
	-- end
-- end)

-- Callback.add(Callback.ON_STAGE_START, function()
	-- for _, actor in ipairs(dust:get_holding_actors()) do
		-- local data = Instance.get_data(actor)
		-- if data.lootbugspawned == 1 then
			-- data.lootbugspawned = 0
		-- end
	-- end
-- end)

-- Callback.add(Callback.ON_STAGE_START, function()
    -- for _, player in ipairs(Instance.find_all(gm.constants.oP)) do
        -- dust:create(player.x, player.y)
    -- end
-- end)
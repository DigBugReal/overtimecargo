-- local sprite_jar = Resources.sprite_load(NAMESPACE, "PreservesJar", path.combine(PATH, "Sprites/item/preservesJar.png"), 1, 17, 17)

-- local jar = Item.new(NAMESPACE, "preservesJar")
-- jar:set_sprite(sprite_jar)
-- jar:set_tier(Item.TIER.rare)
-- jar:set_loot_tags(Item.LOOT_TAG.category_utility)
-- jar:clear_callbacks()

-- local bossPartyActive
-- -- jar:onAcquire(function(actor)
	-- -- if not actor.jarKill then
		-- -- actor.jarKill = 0
	-- -- end
-- -- end)

-- gm.pre_script_hook(gm.constants["update_boss_party_active@gml_Object_oDirectorControl_Create_0"], function(self, other, result, args)
	-- bossPartyActive = true
-- end)

-- jar:onKillProc(function(actor, victim, stack)
	-- local tp = Instance.find(gm.constants.oTeleporter)
	-- local dtp = Instance.find(gm.constants.oTeleporterEpic)
	-- local com = Instance.find(gm.constants.oCommand)
	
	-- local bossIds = Array.wrap(gm._mod_game_getDirector().teleporter_boss_party.actor_ids)
	
	-- local jarItem = Item.get_random()
	
	-- if GM.actor_is_boss(victim) then
		-- -- for _, id in ipairs(bossIds) do
			-- -- print(id)
			-- -- print("ok and then")
			-- -- print(victim)
			-- -- if victim == id then
				-- for i = 0, 0, stack do
					-- jarItem:create(actor.x, actor.y, actor)
				-- end
			-- -- end
		-- -- end
	-- end
-- end)

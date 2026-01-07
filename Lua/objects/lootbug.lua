-- local sprite_mask = Sprite.new("lootbugMask", path.combine(PATH, "Sprites/fx/lootbugMask.png"), 1, 15, 11)
-- local sprite_idle = Sprite.new("lootbugIdle", path.combine(PATH, "Sprites/fx/lootbugIdle.png"), 1, 15, 11)
-- local sprite_walk = Sprite.new("lootbugWalk", path.combine(PATH, "Sprites/fx/lootbugWalk.png"), 8, 15, 11)
-- local sprite_run = Sprite.new("lootbugRun", path.combine(PATH, "Sprites/fx/lootbugRun.png"), 8, 15, 11)
-- local sprite_spawn = Sprite.new("lootbugSpawn", path.combine(PATH, "Sprites/fx/lootbugSpawn.png"), 14, 24, 20)
-- local sprite_burrow = Sprite.new("lootbugBurrow", path.combine(PATH, "Sprites/fx/lootbugBurrow.png"), 15, 24, 20)
-- local sprite_death = Sprite.new("lootbugDeath", path.combine(PATH, "Sprites/fx/lootbugDeath.png"), 12, 20, 21)

-- local sound_idle1 = Sound.new("lootbugIdle1", path.combine(PATH, "Sounds/lootbugIdle1.ogg"))
-- local sound_idle2 = Sound.new("lootbugIdle2", path.combine(PATH, "Sounds/lootbugIdle2.ogg"))
-- local sound_run = Sound.new("lootbugRun", path.combine(PATH, "Sounds/lootbugRun.ogg"))
-- local sound_death = Sound.new("lootbugDeath", path.combine(PATH, "Sounds/lootbugDeath.ogg"))

-- local lootbug = Object.new("Lootbug", Object.Parent.ENEMY_CLASSIC)
-- lootbug.obj_sprite = sprite_idle
-- lootbug.obj_depth = 11

-- Callback.add(lootbug.on_create, function(inst)
	-- inst.sprite_spawn = sprite_spawn
	-- inst.sprite_idle = sprite_idle
	-- inst.sprite_walk = sprite_walk
	-- inst.sprite_jump = sprite_walk
	-- inst.sprite_jump_peak = sprite_walk
	-- inst.sprite_fall = sprite_walk
	-- inst.sprite_death = sprite_death

	-- inst.can_jump = true

	-- inst.mask_index = sprite_mask

	-- inst.sound_spawn = gm.constants.wLizardSpawn
	-- inst.sound_hit = gm.constants.wImpHit
	-- inst.sound_death = sound_death

	-- inst:enemy_stats_init(0, 300, 99999, 0)
	-- inst.pHmax_base = 2.6

	-- -- inst:init_inst_late()
	-- inst.lifetime = 20 * 60
	-- inst.burrowing = 0
	-- inst.madesound = inst.lifetime
-- end)

-- Callback.add(lootbug.on_step, function(inst)
	-- inst.fleeing = true
	-- inst:alarm_set(0, -1) -- disable the classic enemy ai -- not perfect but it does the job
	
	-- if inst.fleeing and inst.inst_state_current_id == -1 then
		-- -- attempt to flee at all times
		-- if Instance.exists(inst.target) then
			-- local sync = false

			-- if inst.target.x > inst.x then
				-- if not Util.bool(inst.moveLeft) then sync = true end
				-- inst.moveLeft = true
				-- inst.moveRight = false
			-- else
				-- if not Util.bool(inst.moveRight) then sync = true end
				-- inst.moveLeft = false
				-- inst.moveRight = true
			-- end

			-- if sync then
				-- inst:net_send_instance_message(0) -- inst_position_info
			-- end
		-- else
			-- inst.target = gm.instance_nearest(inst.x, inst.y, gm.constants.oP)
		-- end
	-- end
	
	-- if inst.lifetime > 0 then
		-- inst.lifetime = inst.lifetime - 1
	-- else
		-- inst.sprite_index = sprite_burrow
		-- inst.burrowing = 1
	-- end
	
	-- if inst.madesound - inst.lifetime > 120 and math.random() <= 0.05 then
		-- if math.random() <= 0.5 then
			-- sound_idle1:play(inst.x, inst.y, 2, 1)
		-- else
			-- sound_idle2:play(inst.x, inst.y, 2, 1)
		-- end
		-- inst.madesound = inst.lifetime
	-- end
	
	-- if inst.burrowing == 1 then
		-- local body = gm.instance_create(inst.x, inst.y, gm.constants.oBody)
		-- body.sprite_index = sprite_burrow
		-- body.image_xscale = inst.image_xscale
		-- body.image_index = 0
		-- body.image_speed = 0.15
		-- body.image_blend = inst.image_blend
		-- body.sprite_palette = inst.sprite_palette
		-- body.elite_type = inst.elite_type
		-- sound_run:play(inst.x, inst.y, 1, 1)
		-- inst:destroy()
	-- end
-- end)

-- Callback.add(lootbug.on_destroy, function(inst)
	-- if inst.hp <= 0 and inst.burrowing == 0 then
	-- local itemcount = inst.itemcount
		-- for i = 0, itemcount, 1 do
			-- local tier = ItemTier.COMMON
			-- if math.random() <= 0.2 then 
				-- tier = ItemTier.UNCOMMON
			-- end
			-- if math.random() <= 0.05 then 
				-- tier = ItemTier.RARE
			-- end
			
			-- local item = Item.get_random(tier):create(inst.x, inst.y, inst)
			-- item.item_stack_kind = 1
		-- end
	-- end
-- end)
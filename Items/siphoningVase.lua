local sprite_vase = Sprite.new("siphoningVase", path.combine(PATH, "Sprites/item/siphoningVase.png"), 1, 17, 17)

local vase = Item.new("siphoningVase")
vase:set_sprite(sprite_vase)
vase:set_tier(ItemTier.RARE)
vase.loot_tags = Item.LootTag.CATEGORY_DAMAGE, Item.LootTag.CATEGORY_HEALING

local log = ItemLog.new_from_item(vase)
log.group = ItemLog.Group.RARE

Callback.add(vase.on_acquired, function(actor)
	if Instance.get_data(actor).pulse == nil then
		Instance.get_data(actor).pulse = 0
	end
end)

Callback.add(Callback.ON_STEP, function()
	for _, actor in ipairs(vase:get_holding_actors()) do
		local i = 0
		local targetenemies = List.new()
		
		actor:collision_ellipse_list(actor.x - 180, actor.y - 180, actor.x + 180, actor.y + 180, gm.constants.pActor, false, true, targetenemies, false)
		for _, victim in ipairs(targetenemies) do 
			if victim.team ~= actor.team then
				i = i + 1
				if not Instance.get_data(victim).siphontick then
					Instance.get_data(victim).siphontick = 0
				end
				if i <= actor:item_count(vase) then
					if Instance.get_data(victim).siphontick > 0 then
						Instance.get_data(victim).siphontick = Instance.get_data(victim).siphontick - 1
					end
					if Instance.get_data(victim).siphontick <= 0 then
						local direct = actor:fire_direct(victim, 1, 0, victim.x, victim.y, nil, false)
						direct.attack_info.damage_color = Color.YELLOW
						actor:heal(actor.maxhp * 0.025)
						victim:buff_apply(Buff.find("oil", "ror"), 60)
						Sound.wrap(gm.constants.wUse):play(victim.x, victim.y, 1, 0.8 + math.random() * 0.2)
						Instance.get_data(victim).siphontick = 35
						Instance.get_data(actor).pulse = 100
					end
				else
					break
				end
			end
		end
	
		targetenemies:destroy()
	end
end)

Callback.add(Callback.ON_DRAW, function()
	for _, actor in ipairs(vase:get_holding_actors()) do
		local i = 0
		local targetenemies = List.new()
		
		if Instance.get_data(actor).pulse > 0 then
			Instance.get_data(actor).pulse = Instance.get_data(actor).pulse - 4
		end
		
		actor:collision_ellipse_list(actor.x - 180, actor.y - 180, actor.x + 180, actor.y + 180, gm.constants.pActor, false, true, targetenemies, false)
		
		for _, victim in ipairs(targetenemies) do
			if victim.team ~= actor.team then
				i = i + 1
				if i <= actor:item_count(vase) then
					local x2 = (actor.x + victim.x) / 2
					local y2 = (actor.y + victim.y) / 2 - 80
					actor:draw_set_colour(Color.from_hsv(100, 100, Instance.get_data(actor).pulse / 1.5))
					actor:draw_line3(actor.x, actor.y, x2, y2, victim.x, victim.y, 6, 3, 2, 8)
					
					actor:draw_set_colour(Color.from_hsv(100, 100, Instance.get_data(actor).pulse))
					actor:draw_line3(actor.x, actor.y, x2, y2, victim.x, victim.y, 3, 2, 1, 8)
					
				else
					break
				end
			end
		end
	end
end)
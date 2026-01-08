local sprite_vase = Sprite.new("siphoningVase", path.combine(PATH, "Sprites/item/siphoningVase.png"), 1, 16, 17)

local vase = Item.new("siphoningVase")
vase:set_sprite(sprite_vase)
vase:set_tier(ItemTier.RARE)
vase.loot_tags = Item.LootTag.CATEGORY_DAMAGE + Item.LootTag.CATEGORY_HEALING

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
						direct.attack_info.damage_color = Color.from_hex(0xc9b636)
						actor:heal(actor.maxhp * 0.025)
						victim:buff_apply(Buff.find("oil", "ror"), 60)
						Sound.wrap(gm.constants.wUse):play(victim.x, victim.y, 1, 0.8 + math.random() * 0.2)
						Instance.get_data(victim).siphontick = 35
						Instance.get_data(actor).pulse = 100
						
						local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
						flash.parent = actor
						flash.rate = 0.04
						flash.image_alpha = 0.7
						flash.image_blend = Color.from_hsv(100, 100, 100)
					end
				else
					break
				end
			end
		end
	
		targetenemies:destroy()
	end
end)

vase.effect_display = EffectDisplay.func(function(actor_unwrapped)
	local actor = Instance.wrap(actor_unwrapped)
	
	if actor:item_count(vase) <= 0 then return end
	
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
				local y2 = (actor.y + victim.y) / 2 - 40
				local pulse = Instance.get_data(actor).pulse * 0.045
				
				actor:draw_set_colour(Color.from_hsv(100, 100, Instance.get_data(actor).pulse / 1.5))
				actor:draw_line3(actor.x, actor.y, x2, y2, victim.x, victim.y, 6 + pulse, 2 + pulse, 1, 9)
				
				actor:draw_set_colour(Color.from_hsv(100, 100, Instance.get_data(actor).pulse))
				actor:draw_line3(actor.x, actor.y, x2, y2, victim.x, victim.y, 3 + pulse, 1.5 + pulse, 0.75, 9)
				
			else
				break
			end
		end
	end

end, EffectDisplay.DrawPriority.BODY_PRE)
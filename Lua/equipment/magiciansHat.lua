local sprite_hat = Sprite.new("magiciansHat", path.combine(PATH, "Sprites/item/magiciansHat.png"), 2, 16, 16)
local sprite_hat_ready = Sprite.new("magiciansHatReady", path.combine(PATH, "Sprites/item/magiciansHatReady.png"), 2, 16, 16)

local hat = Equipment.new("magiciansHat")
hat:set_sprite(sprite_hat)
hat.loot_tags = Item.LootTag.CATEGORY_UTILITY + Item.LootTag.EQUIPMENT_BLACKLIST_CHAOS + Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR + Item.LootTag.EQUIPMENT_BLACKLIST_ENIGMA
hat.cooldown = 60 * 90

local parselect = Particle.new("particleMagiciansHatSelect")
parselect:set_color_rgb(64, 191, 46, 46, 133, 133)
parselect:set_life(30, 90)
parselect:set_shape(Particle.Shape.LINE)
parselect:set_orientation(90, 90, 0, 0, false)
parselect:set_speed(0.75, 1.5, -0.01, 0)
parselect:set_scale(0.1, 0.1)
parselect:set_alpha3(1, 1, 0)
parselect:set_size(1, 2, -0.02, 0.005)
parselect:set_direction(90, 90, 0, 0)

local parstar = Particle.new("particleMagiciansHatStar")
parstar:set_color_rgb(255, 255, 255, 255, 255, 255)
parstar:set_life(50, 70)
parstar:set_shape(Particle.Shape.STAR)
parstar:set_orientation(0, 360, -4, 0.5, false)
parstar:set_speed(3, 4, -0.1, 0)
parstar:set_scale(0.2, 0.2)
parstar:set_size(0.7, 1.4, 0.02, 0)
parstar:set_direction(30, 150, 0, 0)
parstar:set_gravity(0.05, 270)
parstar:set_alpha3(1, 1, 0)

hat.effect_display = EffectDisplay.func(function(actor_unwrapped)
	local actor = Instance.wrap(actor_unwrapped)
	local detecteditems = List.new()
	local validitems = List.new()
	actor:collision_rectangle_list(actor.x, actor.y - 25, actor.x + 200 * actor.image_xscale, actor.y + 25, gm.constants.pPickupItem, false, true, detecteditems, false)
	if not (gm.player_get_equipment_cooldown(actor.value) > 0) then
		for _, item in ipairs(detecteditems) do
			if (item.tier == 0 or item.tier == 1 or item.tier == 2 or item.tier == 4) and item.speed == 0 and item.item_stack_kind == 0 and item.item_id ~= -1 then
				if math.random(10) < 6 then
					parselect:create(item.x + math.random(-15, 15), item.y - math.random(-15, 15))
				end
				validitems:add(item)
			end
		end
	end
	if validitems:size() > 0 then
		hat:set_sprite(sprite_hat_ready)
		hat.cooldown = 30
	else
		hat:set_sprite(sprite_hat)
		hat.cooldown = 60 * 90
	end
	detecteditems:destroy()
	validitems:destroy()
end, EffectDisplay.DrawPriority.BODY_POST)

Callback.add(hat.on_use, function(actor)
	if actor:equipment_get() ~= hat then return end
	local detecteditems = List.new()
	local validitems = List.new()
	actor:collision_rectangle_list(actor.x, actor.y - 25, actor.x + 200 * actor.image_xscale, actor.y + 25, gm.constants.pPickupItem, false, true, detecteditems, false)
	for _, item in ipairs(detecteditems) do
		if (item.tier == 0 or item.tier == 1 or item.tier == 2 or item.tier == 4) and item.item_stack_kind == 0 and item.item_id ~= -1 then
			validitems:add(item)
		end
	end
	if validitems:size() > 0 then
		for _, item in ipairs(validitems) do
			if item.tier == 0 and item.item_stack_kind == 0 then
				parstar:set_color_rgb(255, 255, 255, 255, 255, 255)
			elseif item.tier == 1 and item.item_stack_kind == 0 then
				parstar:set_color_rgb(115, 115, 175, 175, 88, 88)
			elseif item.tier == 2 and item.item_stack_kind == 0 then
				parstar:set_color_rgb(192, 192, 44, 44, 65, 65)
			elseif item.tier == 4 and item.item_stack_kind == 0 then
				parstar:set_color_rgb(218, 218, 205, 205, 65, 65)
			end
			parstar:set_direction(30, 150, 0, 0)
			parstar:create(item.x, item.y)
			Instance.get_data(actor).magiciansHatItems:add(item.item_id)
			Instance.get_data(actor).magiciansHatTiers:add(item.tier)
			item:destroy()
		end
		Sound.wrap(gm.constants.wDagger_Fly):play(actor.x, actor.y, 0.8, 0.9 + math.random() * 0.1)
		Sound.wrap(gm.constants.wRevive):play(actor.x, actor.y, 0.8, 0.9 + math.random() * 0.1)
	else
		for _, id in ipairs(Instance.get_data(actor).magiciansHatItems) do
			actor:item_give(id, 2, Item.StackKind.TEMPORARY_RED)
		end
		for _, tier in ipairs(Instance.get_data(actor).magiciansHatTiers) do
			if tier == 0 then
				parstar:set_color_rgb(255, 255, 255, 255, 255, 255)
			elseif tier == 1 then
				parstar:set_color_rgb(115, 115, 175, 175, 88, 88)
			elseif tier == 2 then
				parstar:set_color_rgb(192, 192, 44, 44, 65, 65)
			elseif tier == 4 then
				parstar:set_color_rgb(218, 218, 205, 205, 65, 65)
			end
			parstar:set_direction(0, 360, 0, 0)
			parstar:create(actor.x, actor.y, 2)
		end
		Sound.wrap(gm.constants.wJackbox):play(actor.x, actor.y, 1, 0.9 + math.random() * 0.1)
		Sound.wrap(gm.constants.wUI_Trials_Success):play(actor.x, actor.y, 1, 0.9 + math.random() * 0.1)
		Sound.wrap(gm.constants.wRevive):play(actor.x, actor.y, 1, 0.9 + math.random() * 0.1)
	end
	detecteditems:destroy()
	validitems:destroy()
end)

Callback.add(Callback.ON_EQUIPMENT_SWAP, Callback.Priority.NORMAL, function(actor, new, old)
	if new == hat and old ~= hat then
		Instance.get_data(actor).magiciansHatItems = List.new()
		Instance.get_data(actor).magiciansHatTiers = List.new()
	end
	if old == hat and new ~= hat then
		for _, id in ipairs(Instance.get_data(actor).magiciansHatItems) do
			for i = 1, 2 do
				local item = Item.wrap(id):create(actor.x, actor.y - (24 * actor.image_xscale))
				item.item_stack_kind = 1
			end
		end
		Instance.get_data(actor).magiciansHatItems:destroy()
		Instance.get_data(actor).magiciansHatTiers:destroy()
		hat:set_sprite(sprite_hat)
		hat.cooldown = 60 * 90
	end
end)

Callback.add(Callback.ON_GAME_END, function()
	hat:set_sprite(sprite_hat)
	hat.cooldown = 60 * 90
end)
local sprite_moonrock = Sprite.new("moonStone", path.combine(PATH, "Sprites/item/moonrockWhetstone.png"), 1, 17, 10)
local sprite_buff = Sprite.new("whetstoneBuff", path.combine(PATH, "Sprites/buffs/moonrockBuff1.png"), 1, 8, 29)
local sprite_buff2 = Sprite.new("whetstoneBuff2", path.combine(PATH, "Sprites/buffs/moonrockBuff2.png"), 1, 6, 27)

local roc = Item.new("moonStone")
roc:set_sprite(sprite_moonrock)
roc:set_tier(ItemTier.COMMON)
roc.loot_tags = Item.LootTag.CATEGORY_DAMAGE

local log = ItemLog.new_from_item(roc)
log.group = ItemLog.Group.COMMON

local buff = Buff.new("moonrockBuff")
buff.show_icon = false
buff.icon_sprite = sprite_buff

RecalculateStats.add(function(actor, api)
	if actor:item_count(roc) <= 0 then return end
	local stacks = actor:item_count(roc)
	if actor:buff_count(buff) >= 1 then
		api.critical_chance_add(9 + (3 * stacks))
	end
end)

Callback.add(roc.on_acquired, function(actor)
	Sound.wrap(gm.constants.wCrit):play(actor.x, actor.y, 1, 0.5)
end)

Callback.add(Callback.ON_ATTACK_CREATE, function(attack_info)
	for _, actor in ipairs(roc:get_holding_actors()) do
		local stacks = actor:item_count(roc)
		if attack_info.critical then
			attack_info.damage = attack_info.damage + (2 + (3 * stacks))
			--modify crit damage numbers for fun
			--(affects ceremonial dagger dmg numbers for some reason?)
			attack_info.color = Color.from_hsv(205, 12 + (3 * stacks), 100)
		end
	end
end)

Callback.add(Callback.ON_STEP, function()
	for _, actor in ipairs(roc:get_holding_actors()) do
		local tp = Instance.find(gm.constants.oTeleporter)
		local dtp = Instance.find(gm.constants.oTeleporterEpic)
		local com = Instance.find(gm.constants.oCommand)
		local data = Instance.get_data(actor)
		
		if tp.just_activated == 1 or dtp.just_activated == 1 or com.just_activated == 1 then
			actor:buff_apply(buff, 30)
		end
	end
	
end)

--I'd really like to make this an effect_display as well, but currently I don't know if making more than one for one item is possible
Callback.add(Callback.POST_HUD_DRAW, function()
	for _, actor in ipairs(roc:get_holding_actors()) do
		local data = Instance.get_data(actor)
		local yOffset = gm.sprite_get_yoffset(actor.sprite_idle)
		
		actor:draw_sprite(sprite_buff2, 0, actor.x, actor.y - yOffset)
	end
end)

roc.effect_display = EffectDisplay.func(function(actor_unwrapped)
	local actor = Instance.wrap(actor_unwrapped)
	
	if actor:item_count(roc) <= 0 then return end
	
	local tp = Instance.find(gm.constants.oTeleporter)
	local dtp = Instance.find(gm.constants.oTeleporterEpic)
	local com = Instance.find(gm.constants.oCommand)
	local data = Instance.get_data(actor)
	local yOffset = gm.sprite_get_yoffset(actor.sprite_idle)
		
	if tp.just_activated == 1 or dtp.just_activated == 1 or com.just_activated == 1 then
		local sprite = actor:draw_sprite(sprite_buff, 0, actor.x, actor.y - yOffset)
	end

end, EffectDisplay.DrawPriority.BODY_PRE)
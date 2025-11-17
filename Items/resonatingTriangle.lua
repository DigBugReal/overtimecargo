local sprite_triangle = Sprite.new("resonatingTriangle", path.combine(PATH, "Sprites/item/resonatingTriangle.png"), 1, 16, 16)
local sprite_buff = Sprite.new("resonatingTriangleBuff", path.combine(PATH, "Sprites/buffs/resonatingTriangleBuff.png"), 1, 10, 8)

local tri = Item.new("resonatingTriangle")
tri:set_sprite(sprite_triangle)
tri:set_tier(ItemTier.COMMON)
tri.loot_tags = Item.LootTag.CATEGORY_DAMAGE

local log = ItemLog.new_from_item(tri)
log.group = ItemLog.Group.COMMON

local buff = Buff.new("resonatingTriangleBuff")
buff.show_icon = true
buff.icon_sprite = sprite_buff

RecalculateStats.add(Callback.Priority.AFTER, function(actor, api)
	local stack = actor:buff_count(buff)
	if stack <= 0 then return end
	api.damage_add(5 * actor:item_count(tri))
end)

Callback.add(tri.on_acquired, function(actor)
	if Instance.get_data(actor).triangletimer == nil then
		Instance.get_data(actor).triangletimer = 0
	end
	if Instance.get_data(actor).triangleactivated == nil then
		Instance.get_data(actor).triangleactivated = false
	end
end)

Callback.add(Callback.ON_STEP, function()
	for _, actor in ipairs(tri:get_holding_actors()) do
		if Instance.get_data(actor).triangletimer > 0 then
			Instance.get_data(actor).triangletimer = Instance.get_data(actor).triangletimer - 1
		else
			actor:buff_apply(buff, 30)
			if Instance.get_data(actor).triangleactivated == false then
				Sound.wrap(gm.constants.wCrit):play(actor.x, actor.y, 1, 1)
				Instance.get_data(actor).triangleactivated = true
			end
		end
	end
end)

Callback.add(Callback.ON_DAMAGED_PROC, function(actor, hit_info)
	if Net.client then return end
 
    if actor:item_count(tri) <= 0 then return end
	
	if hit_info.damage > 0 then
		Instance.get_data(actor).triangletimer = 7 * 60
		Instance.get_data(actor).triangleactivated = false
		actor:buff_remove(buff)
		if actor:buff_count(buff) > 0 then
			Sound.wrap(gm.constants.wCrit2):play(actor.x, actor.y, 1, 1)
		end
		actor:buff_remove(buff)
	end
end)
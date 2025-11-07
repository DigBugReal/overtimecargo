local sprite_plate = Sprite.new("regenPlating", path.combine(PATH, "Sprites/item/regenPlating.png"), 1, 16, 16)
local sprite_plate_used = Sprite.new("regenPlatingUsed", path.combine(PATH, "Sprites/item/regenPlatingUsed.png"), 1, 16, 16)

local plate = Item.new("regenPlating")
plate:set_sprite(sprite_plate)
plate:set_tier(ItemTier.UNCOMMON)
plate.loot_tags = Item.LootTag.CATEGORY_UTILITY, Item.LootTag.CATEGORY_HEALING

local log = ItemLog.new_from_item(plate)
log.group = ItemLog.Group.UNCOMMON

local plate_used = Item.new("regenPlatingUsed")
plate_used:set_sprite(sprite_plate_used)
plate_used:toggle_loot(false)
plate_used.loot_tags = Item.LootTag.ITEM_BLACKLIST_VENDOR, Item.LootTag.ITEM_BLACKLIST_INFUSER

--Create var in actor used to track drone purchases
Callback.add(plate.on_acquired, function(actor, stack)
	local data = Instance.get_data(actor)

	--Tracks number of drones bought
	if not data.platingDroneBuy then
		data.platingDroneBuy = 0 

		--prevents free extra uses if you get
		--an extra stack while having a semi-used stack
	elseif data.platingDroneBuy == 1 then
		data.platingDroneBuy = 1
		
	elseif data.platingDroneBuy == 2 then
		data.platingDroneBuy = 2

		--default, resets at stage start
	else 
		data.platingDroneBuy = 0
	end

	--Limit for drones that can be bought
	if not data.platingDroneLimit then
		data.platingDroneLimit = 3
	end

end)

--shoutouts to On_x for helping me understand hooks
--called when a drone is spawned
--post script bc that's after it determines its master
Hook.add_post(gm.constants.init_drone, function(self, other)
	--"Master" is the drone's variable for its owner/parent/the player actor
	--needs to be wrapped to be used in hook
	local master = Instance.wrap(self.master)
	local data = Instance.get_data(master)
	if master:item_count(plate) > 0 then
	
		Sound.wrap(gm.constants.wCrit2):play(master.x, master.y, 1, 0.5)
		local flash = GM.instance_create(self.x, self.y, gm.constants.oEfFlash)
		flash.parent = self
		flash.rate = 0.05
		flash.image_alpha = 0.8
		flash.image_blend = Color.YELLOW
	
		if data.platingDroneBuy and data.platingDroneBuy < data.platingDroneLimit then
			--Buff drone stats
			self.armor = self.armor + 100
			self.hp_regen = self.hp_regen + 0.06

			--Increment drones bought var
			data.platingDroneBuy = data.platingDroneBuy + 1
		end
		
		--If our drones bought equals the limit, consume a stack of the item
		--(+temp item handling)
		if data.platingDroneBuy >= data.platingDroneLimit then
			Sound.wrap(gm.constants.wDroneDeath):play(master.x, master.y, 1, 0.7)
			local normal = master:item_count(plate, Item.StackKind.NORMAL)
			local temp = master:item_count(plate, Item.StackKind.TEMPORARY_BLUE)
			local temp2 = master:item_count(plate, Item.StackKind.TEMPORARY_RED)
		
			if normal > 0 and not (temp > 0 or temp2 > 0) then
				master:item_take(plate, 1, Item.StackKind.NORMAL)
				master:item_give(plate_used, 1, Item.StackKind.NORMAL)
			end
		
			if temp > 0 then
				master:item_take(plate, 1, Item.StackKind.TEMPORARY_BLUE)
				master:item_give(plate_used, 1, Item.StackKind.TEMPORARY_BLUE)
			end
		
			if temp2 > 0 then
				master:item_take(plate, 1, Item.StackKind.TEMPORARY_RED)
				master:item_give(plate_used, 1, Item.StackKind.TEMPORARY_RED)
			end
			
			--reset drones bought variable
			data.platingDroneBuy = 0
			
		end
	end
end)

--replenish Regen Plate frome used plate
Callback.add(Callback.ON_STAGE_START, function()

	for _, actor in ipairs(plate_used:get_holding_actors()) do
		Instance.get_data(actor).platingDroneBuy = 0 
		local normal = actor:item_count(plate_used, Item.StackKind.NORMAL)
		local temp = actor:item_count(plate_used, Item.StackKind.TEMPORARY_BLUE)
		local temp2 = actor:item_count(plate, Item.StackKind.TEMPORARY_RED)
		
		if normal > 0 then
			actor:item_give(plate, normal, Item.StackKind.NORMAL)
			actor:item_take(plate_used, normal, Item.StackKind.NORMAL)
		end
		
		if temp > 0 then
			actor:item_give(plate, temp, Item.StackKind.TEMPORARY_BLUE)
			actor:item_take(plate_used, temp, Item.StackKind.TEMPORARY_BLUE)
		end
		
		if temp > 0 then
			actor:item_give(plate, temp, Item.StackKind.TEMPORARY_RED)
			actor:item_take(plate_used, temp, Item.StackKind.TEMPORARY_RED)
		end
	end
	
	for _, actor in ipairs(plate:get_holding_actors()) do
		Instance.get_data(actor).platingDroneBuy = 0 
	end
end)
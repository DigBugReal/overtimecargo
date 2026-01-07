local sprite = Sprite.new("scrapMissiles", path.combine(PATH, "Sprites/item/scrapMissiles.png"), 1, 16, 16)
local missile_sprite = Sprite.new("scrapMissilesMissile", path.combine(PATH, "Sprites/fx/scrapMissilesMissile.png"), 3, 23, 5)

local missiles = Item.new("scrapMissiles")
missiles:set_sprite(sprite)
missiles:set_tier(ItemTier.COMMON)
missiles.loot_tags = Item.LootTag.CATEGORY_DAMAGE

local log = ItemLog.new_from_item(missiles)
log.group = ItemLog.Group.COMMON

local smallMissile = Object.find("EfMissileSmall")
local my_item_owners = {}

Callback.add(missiles.on_acquired, function(actor)
    if actor:item_count(missiles) == 1 then
        my_item_owners[actor.id] = true
    end
	if not actor.missileCount then
		actor.missileCount = 0
		actor.missileTimer = 0
	end
end)

Callback.add(missiles.on_removed, function(actor)
    if actor:item_count(missiles) == 1 then
        my_item_owners[actor.id] = nil
		if actor.missileCount then
			actor.missileCount = nil
			actor.missileTimer = nil
		end
    end
end)

Callback.add(Callback.ON_STEP, function()
	for _, actor in ipairs(missiles:get_holding_actors()) do
		if Instance.exists(actor) then
			if actor.missileTimer then
				if actor.missileTimer > 0 then
					actor.missileTimer = actor.missileTimer - 1
				end
				if actor.missileTimer <= 0 then
					if actor.missileCount and actor.missileCount > 0 and actor.missileCount <= 50 then
						actor.missileTimer = 10
						actor.missileCount = actor.missileCount - 1
						local miss = smallMissile:create(actor.x, actor.y)
						miss.sprite_index = missile_sprite
						miss.damage = actor.damage * 0.8
					elseif
					actor.missileCount and actor.missileCount > 50 and actor.missileCount <= 100 then
						actor.missileTimer = 5
						actor.missileCount = actor.missileCount - 1
						local miss = smallMissile:create(actor.x, actor.y)
						miss.sprite_index = missile_sprite
						miss.damage = actor.damage * 0.8
					elseif
					actor.missileCount and actor.missileCount > 100 then
						actor.missileTimer = 1
						actor.missileCount = actor.missileCount - 1
						local miss = smallMissile:create(actor.x, actor.y)
						miss.sprite_index = missile_sprite
						miss.damage = actor.damage * 0.8
					end
				end
			end
		end
	end
end)

Callback.add(Callback.ON_ENEMY_INIT, function(enemy)
	for id, _ in pairs(my_item_owners) do
		local actor = Instance.wrap(id)
		if Instance.exists(actor) then
			actor.missileCount = actor.missileCount + 2 + 1 * actor:item_count(missiles)
		else
			my_item_owners[id] = nil
		end
	end
end
)
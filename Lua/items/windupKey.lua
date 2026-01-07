local sprite_key = Sprite.new("windupKey", path.combine(PATH, "Sprites/item/windupKey.png"), 1, 16, 16)
local sprite_bolts = Sprite.new("windupKeyParticles", path.combine(PATH, "Sprites/fx/windupKeyParticles.png"), 5, 3, 3)
local sprite_vfx = Sprite.new("windupKeyVFX", path.combine(PATH, "Sprites/fx/windupKeyVFX2.png"), 8, 10, 15)

local key = Item.new("windupKey")
key:set_sprite(sprite_key)
key:set_tier(ItemTier.UNCOMMON)
key.loot_tags = Item.LootTag.CATEGORY_DAMAGE

local log = ItemLog.new_from_item(key)
log.group = ItemLog.Group.UNCOMMON

local bolts = Particle.new("windupKeyParticles")
bolts:set_life(300, 300)
bolts:set_sprite(sprite_bolts, false, false, true)
bolts:set_orientation(0, 360, -4, 0, false)
bolts:set_gravity(0.2, 270)
bolts:set_speed(5, 7, 0, 0)
bolts:set_scale(1, 1)

--effect display my beloved
key.effect_display = EffectDisplay.func(function(actor_unwrapped)
	local actor = Instance.wrap(actor_unwrapped)
	local data = Instance.get_data(actor)
	local k = Global._current_frame
	local e = 0 + (k * 0.9)
	local y = 0 + (k * 0.2)
	local yOffset = gm.sprite_get_yoffset(actor.sprite_idle)
	local xOffset = gm.sprite_get_xoffset(actor.sprite_idle)
	
	if data.windupkeybullets < 10 + 15 * actor:item_count(key) then
		if data.windupkeyshooting == true then
			GM.draw_sprite_ext(sprite_vfx, e, actor.x - ((15 + xOffset) * actor.image_xscale), actor.y + (yOffset * 0.2), actor.image_xscale, 1, 0, Color.WHITE, 1)
		elseif Util.bool(actor.z_skill) then
			GM.draw_sprite_ext(sprite_vfx, y, actor.x - ((15 + xOffset) * actor.image_xscale), actor.y + (yOffset * 0.2), actor.image_xscale, 1, 0, Color.WHITE, 1)
		else
			GM.draw_sprite_ext(sprite_vfx, 0, actor.x - ((15 + xOffset) * actor.image_xscale), actor.y + (yOffset * 0.2), actor.image_xscale, 1, 0, Color.WHITE, 1)
		end
	else
		GM.draw_sprite_ext(sprite_vfx, 0, actor.x - ((15 + xOffset) * actor.image_xscale), actor.y + (yOffset * 0.2), actor.image_xscale, 1, 0, Color.WHITE, 1)
	end
	
end, EffectDisplay.DrawPriority.BODY_PRE)

Callback.add(key.on_acquired, function(actor)
	if Instance.get_data(actor).windupkeytimer == nil then
		Instance.get_data(actor).windupkeytimer = 0
	end
	if Instance.get_data(actor).windupkeybullets == nil then
		Instance.get_data(actor).windupkeybullets = 0
	end
	if Instance.get_data(actor).windupkeyshooting == nil then
		Instance.get_data(actor).windupkeyshooting = false
	end
end)

Callback.add(Callback.ON_STEP, function()
for _, actor in ipairs(key:get_holding_actors()) do
	local stack = actor:item_count(key)
	local data = Instance.get_data(actor)
	local yOffset = gm.sprite_get_yoffset(actor.sprite_idle)
	local xOffset = gm.sprite_get_xoffset(actor.sprite_idle)
	-- if data.keyvfx == nil or data.keyvfx:exists() == false then
		-- local instkeyvfx = keyvfx:create(actor.x, actor.y)
		-- instkeyvfx:get_data().keyparent = actor
		-- instkeyvfx.image_speed = 0
		-- data.keyvfx = instkeyvfx
	-- end
	if data.windupkeyshooting == false then
		if Util.bool(actor.z_skill) and data.windupkeytimer < 3 then
			data.windupkeytimer = data.windupkeytimer + 1
		else
			data.windupkeytimer = 0
		end
		
		if data.windupkeytimer >= 3 and data.windupkeybullets < 10 + 15 * stack then
			data.windupkeybullets = data.windupkeybullets + 0.1 + 0.15 * stack
			data.windupkeytimer = 0
			if data.windupkeybullets >= 10 + 15 * stack then
				Sound.wrap(gm.constants.wSniperReload):play(actor.x, actor.y, 1, 1)
				local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
				flash.parent = actor
				flash.rate = 0.05
				flash.image_alpha = 1
			end
		end
	else
		if data.windupkeybullets > 0 then
			if math.random() <= 0.44 then
				data.windupkeybullets = data.windupkeybullets - 1
				Sound.wrap(gm.constants.wSniperShoot3):play(actor.x, actor.y, 0.3, 0.8 + math.random() * 0.4)
				Sound.wrap(gm.constants.wCasing):play(actor.x, actor.y, 0.2, 1.2 + math.random() * 0.4)
				if actor:skill_util_facing_direction() < 90 then
					bolts:set_direction(90, 180, 0, 0)
				else
					bolts:set_direction(0, 90, 0, 0)
				end
				local dmg = actor.damage * 0.02
				bolts:create(actor.x, actor.y, 1, Particle.System.BELOW)
				local attack = actor:fire_bullet(actor.x, actor.y, 1000, actor:skill_util_facing_direction() + math.random(-2, 2), dmg, nil, gm.constants.sSparks3, Tracer.SNIPER1)
				attack.attack_info.damage_color = Color.from_hex(0xc9b636)
				actor:screen_shake(1)
			end
		else
			data.windupkeyshooting = false
		end
	end
	if not Util.bool(actor.z_skill) and data.windupkeybullets > 0 then
		Instance.get_data(actor).windupkeyshooting = true
	end
end
end)
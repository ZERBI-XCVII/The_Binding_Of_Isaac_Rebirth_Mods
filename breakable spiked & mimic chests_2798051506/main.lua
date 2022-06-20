local Mod = RegisterMod("Breakable Spiked & Mimic Chests",1)

--Wiki (Chests):	https://bindingofisaacrebirth.fandom.com/wiki/Chests?so=search
--BoI LUA API Docs: https://moddingofisaac.com/docs/rep/index.html

function Mod:checkBombExplosionEffectCollision(EntityEffect)
				
		local entities = Isaac.GetRoomEntities()
		
		for i = 1, #entities do
		
			local entity = entities[i]
			if 		entity.Type == EntityType.ENTITY_PICKUP 
				and (entity.Variant == PickupVariant.PICKUP_SPIKEDCHEST or entity.Variant == PickupVariant.PICKUP_MIMICCHEST)
				and entity.SubType == ChestSubType.CHEST_CLOSED then 
				
				if EntityEffect.Position:Distance(entity.Position) < 120 then
					entity:ToPickup():TryOpenChest()
				end
				
			end
			
		end
		
		return nil
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Mod.checkBombExplosionEffectCollision, EffectVariant.BOMB_EXPLOSION)







































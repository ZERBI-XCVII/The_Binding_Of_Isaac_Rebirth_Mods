local Mod = RegisterMod("No Greed Button Damage", 1)

-- Lua API Documentation for Repentance:  https://moddingofisaac.com/docs/rep/
-- Lua API Documentation for Afterbirth+: https://moddingofisaac.com/docs/abp/				 

SFX = SFXManager()

--1) Main function used to remove the Greed Button damage
function Mod:removeGreedButtonDamage(TookDamage, DamageAmount, DamageFlags, DamageSource, DamageCountdownFrames)
	
	-- Remove damage 
	if  Game():IsGreedMode()     	     		--> Works only in Greed Mode (with function "3" this check is repeated... but I'll leave here in any case... just to be sure)
	and DamageFlags == 268435584				--> Greed Button damage flag. Is it right? In the API documentation there is nothing about it... I found it by printing in the debug console the "DamageFlags" argument passed by the callback.
	and Isaac.GetPlayer(0):GetNumCoins() > 0 	--> You need at least 1 coin in order to avoid the damage
	then
			
		--Remove 1 coin
		local player = Isaac.GetPlayer(0)
		player:AddCoins(-1)						
		
		--Spawn a coin (just because it looks cool) + SFX
		SFX:Play(SoundEffect.SOUND_BAND_AID_PICK_UP, 1, 0, false, 1, false)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, player.Position, player.Velocity * 4, player)
		
		--Add a callback to remove the coin that has been just spawned
		Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Mod.removeCoinWhenItStops)

		return false 							--> Return true or nil if the entity or player should sustain the damage, otherwise false to ignore it.
												--> BUG: Returning any value besides nil will prevent later callbacks from being executed <-- (...for the current damage... I hope).
	
	end
	
	return nil									--> In any other case the function return nil so the damage is NOT removed and other mods can work correctly
	
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--2) Function used to remove the coin spawned by Isaac whent it stops
function Mod:removeCoinWhenItStops()

	--Find the right coin between all entities
	local entities = Isaac.GetRoomEntities()
		
	for i = 1, #entities do
	
		local entity = entities[i]
		
		--Find the coin spawned by Isaac
		if  entity.SpawnerType == EntityType.ENTITY_PLAYER
		and entity.Type    == EntityType.ENTITY_PICKUP 
		and entity.Variant == PickupVariant.PICKUP_COIN
		and entity.SubType == CoinSubType.COIN_PENNY 
		then
			--Check if the coin is (almost) stopped
			if  entity.Velocity.X < 1 and entity.Velocity.Y < 1 then		--I checked the X and Y velocity because using directly a Vector(X,Y) does not seem to work..
				
				--SFX 
				SFX:Play(SoundEffect.SOUND_PLOP, 1, 0, false, 1, false)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, entity.Velocity, player)
				
				--Remove coin
				entity:Remove()
				
				--Spawn gold particles
				for d = 1, 5, 1 do 				--start, stop, increment
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GOLD_PARTICLE, 0, entity.Position + Vector(math.random(20),math.random(20)), entity.Velocity, player)
				end
				
				--Remove callback for better performance
				Mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, Mod.removeCoinWhenItStops)
	
			end
			
		end
		
	end
	
	return nil

end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--3) Function used to add/remove the callback "ModCallbacks.MC_ENTITY_TAKE_DMG" based on whethere or not we are in Greed Mode (so for better performance)
function Mod:checkGreedMode(isContinued)
	
	if  Game():IsGreedMode() then
		Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.removeGreedButtonDamage, EntityType.ENTITY_PLAYER) --> with "EntityType.ENTITY_PLAYER" the callback will be activated only when player will receive damage
	else
		Mod:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.removeGreedButtonDamage, EntityType.ENTITY_PLAYER) --> what happen if I try to remove a callback that is not present? Nothing apparently...
	end
	
	return nil
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.checkGreedMode)
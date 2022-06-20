local Mod = RegisterMod("Mega Satan Key Opens Everything", 1)

--REP LUA API Docs: https://moddingofisaac.com/docs/rep/index.html
--AB+ LUA API Docs: https://moddingofisaac.com/docs/abp/

--Function used to add a Golden Key every new level
function Mod:checkKeyPieces() 
	
	local player = Isaac.GetPlayer(0)
	
	if  player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) 
	and player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2)
	and not player:HasGoldenKey()
	then
		
		player:AddGoldenKey()
		
	end
	
	return nil
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Mod.checkKeyPieces)

-------------------------------------------------------------------------------------------------

--Function used to add a Golden Key right after acquiring both Key Pieces
function Mod:checkFullKeyFamiliar(EntityFamiliar)
	
	local player = Isaac.GetPlayer(0)
	
	if not player:HasGoldenKey() then
		
		player:AddGoldenKey()
		
	end
	
	Mod:RemoveCallback(ModCallbacks.MC_FAMILIAR_INIT, Mod.checkFullKeyFamiliar)		--> remove the callback for better performance (I need this function to work only 1 once)
	
	return nil
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Mod.checkFullKeyFamiliar, FamiliarVariant.KEY_FULL)
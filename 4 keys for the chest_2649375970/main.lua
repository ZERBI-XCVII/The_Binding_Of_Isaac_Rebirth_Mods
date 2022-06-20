local Mod = RegisterMod("4 Keys For The Chest", 1)

--List of stages: https://moddingofisaac.com/docs/rep/enums/LevelStage.html							 

--Main function
function Mod:spawn4Keys() 
	
	local game = Game()
	local currentStage = game:GetLevel():GetStage()
	local player = Isaac.GetPlayer(0)
	local numberOfKeys = player:GetNumKeys()
	
	if (currentStage == LevelStage.STAGE6 or currentStage == LevelStage.STAGE4_3) and numberOfKeys < 4 then       --> STAGE6 = The Chest / Dark Room
		player:AddKeys(4-numberOfKeys)               -- add only enough keys to reach 4 keys
	end
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Mod.spawn4Keys)
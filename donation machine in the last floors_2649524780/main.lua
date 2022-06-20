local Mod = RegisterMod("Donation Machine In The Last Floors", 1)

--List of stages:       https://moddingofisaac.com/docs/rep/enums/LevelStage.html							 
--List of all chapters: https://bindingofisaacrebirth.fandom.com/wiki/Chapters

--Main function
function Mod:spawnDonationMachine() 
	
	local game = Game()
	local currentStage = game:GetLevel():GetStage()
	local room = game:GetRoom()
	
	--NORMAL/HARD MODE
	if      room:GetBackdropType() == BackdropType.CORPSE	--> Corpse
		or	currentStage == LevelStage.STAGE4_3      --> Blue Womb (Hush)
		or  currentStage == LevelStage.STAGE5        --> Sheol, Cathedral
		or  currentStage == LevelStage.STAGE6        --> Dark Room, Chest
		or  currentStage == LevelStage.STAGE7        --> The Void
	then 
		game:SetStateFlag(GameStateFlag.STATE_DONATION_SLOT_JAMMED, false)
		Isaac.Spawn(EntityType.ENTITY_SLOT, 8, 0, Isaac.GetFreeNearPosition(Vector(160,120),40), Vector(0, 0), nil)	-- (int entityType, int entityVariant, int entitySubtype, Vector position, Vector velocity, Entity Spawner )
										-- ^ 8 = donation machine                 ^^^spawn the donation machine in the LEFT part of the room
	end                                  
	
	if  currentStage == LevelStage.STAGE8 then       --> Home
		game:SetStateFlag(GameStateFlag.STATE_DONATION_SLOT_JAMMED, false)
		Isaac.Spawn(EntityType.ENTITY_SLOT, 8, 0, Isaac.GetFreeNearPosition(Vector(480,120),40), Vector(0, 0), nil)
	end 																	--      ^^^spawn the donation machine in the RIGHT part of the room
	
	--GREED/GREEDIER MODE
	if 	game:IsGreedMode() == true and currentStage ==	LevelStage.STAGE7_GREED then
		game:SetStateFlag(GameStateFlag.STATE_GREED_SLOT_JAMMED, false)
		Isaac.Spawn(EntityType.ENTITY_SLOT, 11, 0, Isaac.GetFreeNearPosition(Vector(160,120),40), Vector(0, 0), nil)
	end 								--  ^^ 11 = greed donation machine
		
	return nil
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Mod.spawnDonationMachine)

--[[
	Slot machine variant (non sono riuscito a trovare i valori su internet... li ho trovati a mano provando):
	1 = slot machine
	2 = devil beggar
	3 = divine (?) machine ... quella viola
	4 = beggar maiale (sarà un'aggiunta della mod IPECAC questa)
	5 = devil beggar
	6 = beggar che fa il gioco con i 3 teschi
	7 = beggar maiale
	8 = slot machine
	9 = bomb beggar
	10 = restock machine
	11 = greed donation machine
	12 = wardrobe (l'armadio per i vestiti)
]]--
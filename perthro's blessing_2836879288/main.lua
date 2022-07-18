local Mod = RegisterMod("Perthro's Blessing", 1)

--LUA Repentance docs: 	https://moddingofisaac.com/docs/rep/index.html
--List of all items: 	https://bindingofisaacrebirth.fandom.com/wiki/Items

--McM: default settings
local ModSettings = {
	
	--Number of blessings
	["McMnumberOfPerthroBlessingsPerRun"]   = 1,
	["McMnumberOfPerthroBlessingsPerFloor"] = 1,
	
	--Types of rooms
	["treasureRooms"]	= true,		-- RoomType.ROOM_TREASURE
	["bossRooms"]   	= true,	    -- RoomType.ROOM_BOSS
	["miniBossRooms"] 	= true,		-- RoomType.ROOM_MINIBOSS
	["secretRooms"] 	= true,		-- RoomType.ROOM_SECRET
	["superSecretRooms"]= true,		-- RoomType.ROOM_SUPERSECRET
	["challengeRooms"] 	= true,		-- RoomType.ROOM_CHALLENGE
	["devilRooms"] 		= true,		-- RoomType.ROOM_DEVIL	
	["angelRooms"] 		= true,		-- RoomType.ROOM_ANGEL
	["dungeonRooms"] 	= true,		-- RoomType.ROOM_DUNGEON
	["bossRushRooms"] 	= true,		-- RoomType.ROOM_BOSSRUSH
	["chestRooms"] 		= true,		-- RoomType.ROOM_CHEST
	["ultraSecretRooms"]= true,		-- RoomType.ROOM_ULTRASECRET
	
	--Debug 
	["printPedestalItems"] = false
}

local numberOfPerthroBlessingsPerRun   = ModSettings["McMnumberOfPerthroBlessingsPerRun"]
local numberOfPerthroBlessingsPerFloor = ModSettings["McMnumberOfPerthroBlessingsPerFloor"]

--Main function
function Mod:spawnRuneOfPerthro() 
	
	local room = Game():GetRoom()
	local currentRoomType = room:GetType()
	local player = Isaac.GetPlayer(0)
	local activeItemInTheRoom = false
	local playerHasActiveItem = false
	local runeOfPerthroInTheRoom = false
	local playerHasRuneOfPerthro = false
	local activeItemPosition = Vector(0,0)
	
	local activeItemsTable = { 33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  44,  45,  47,  49,  56,
							   58,  65,  66,  77,  78,  83,  84,  85,  86,  93,  97, 102, 105, 107, 111,
							  123, 124, 126, 127, 130, 133, 135, 136, 137, 145, 146, 147, 158, 160, 164,
							  166, 171, 175, 177, 181, 186, 192, 263, 282, 283, 284, 285, 286, 287, 288, 
							  289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 323, 324, 325, 326, 338,
							  347, 348, 349, 351, 352, 357, 382, 383, 386, 396, 406, 419, 421, 422, 427,
							  434, 437, 439, 441, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484,
							  485, 486, 487, 488, 489, 490, 504, 507, 510, 512, 515, 516, 521, 522, 523,
							  527, 536, 545, 550, 552, 555, 556, 557, 577, 578, 580, 582, 584, 585, 604, 
							  605, 609, 611, 622, 623, 625, 628, 631, 635, 636, 638, 639, 640, 642, 650,
							  653, 655, 685, 687, 703, 704, 705, 706, 709, 710, 711, 712, 713, 714, 715, 
							  719, 720, 722, 723, 728, 729}	--all active items from the vanilla game (until REP, no mod)
	
	
	if (currentRoomType == RoomType.ROOM_TREASURE 		and 	ModSettings["treasureRooms"] 	== true)
	or (currentRoomType == RoomType.ROOM_BOSS	  		and 	ModSettings["bossRooms"] 		== true)
	or (currentRoomType == RoomType.ROOM_MINIBOSS 		and 	ModSettings["miniBossRooms"] 	== true)
	or (currentRoomType == RoomType.ROOM_SECRET 		and 	ModSettings["secretRooms"] 		== true)
	or (currentRoomType == RoomType.ROOM_SUPERSECRET 	and 	ModSettings["superSecretRooms"] == true)
	or (currentRoomType == RoomType.ROOM_CHALLENGE 		and 	ModSettings["challengeRooms"] 	== true)
	or (currentRoomType == RoomType.ROOM_DEVIL 			and 	ModSettings["devilRooms"] 		== true)
	or (currentRoomType == RoomType.ROOM_ANGEL 			and 	ModSettings["angelRooms"] 		== true)
	or (currentRoomType == RoomType.ROOM_DUNGEON 		and 	ModSettings["dungeonRooms"] 	== true)
	or (currentRoomType == RoomType.ROOM_BOSSRUSH 		and 	ModSettings["bossRushRooms"] 	== true)
	or (currentRoomType == RoomType.ROOM_CHEST 			and 	ModSettings["chestRooms"] 		== true)
	or (currentRoomType == RoomType.ROOM_ULTRASECRET 	and 	ModSettings["ultraSecretRooms"]	== true)
	then
	
		--Check all the entities in the room
		local entities = Isaac.GetRoomEntities()					--get all the entity in the room
		for i = 1, #entities do										
		
			local entity = entities[i]
			--Check if the current entity is a collectible
			if entity.Type == 5 and entity.Variant == 100 then				-- Type = 5 -> EntityType.ENTITY_PICKUP, Variant = 100 -> PickupVariant.PICKUP_COLLECTIBLE
			
				--Check if the current collectible is an active item
				for c = 1, #activeItemsTable do						
					if entity.SubType == activeItemsTable[c] then
						activeItemInTheRoom = true
						activeItemPosition = entity.Position
					end
				end
				
				--Debug: Print all the entities in the room (I will use this to add new items to the active items table while playing)
				if ModSettings["printPedestalItems"] == true then
					print("Collectible ID =", entity.SubType)	
				end	
			
			end
			
			if entity.Type == 5 and entity.Variant == 300 and  entity.SubType == 37 then		--check if the current entity is a Rune of Perthro
				runeOfPerthroInTheRoom = true
			end	
		
		end
		
		--Check player's active item
		if player:GetActiveItem(0) ~= nil then
			playerHasActiveItem = true
		end
		
		--Check player's card/rune
		for r = 0, 3, 1 do
			if player:GetCard(r) ~= nil and player:GetCard(r) == 37 then		--37 = Rune of Perthro
				playerHasRuneOfPerthro = true
			end
		end
			
		
		--Spawn Rune of Perthro
		if activeItemInTheRoom == true 
		and playerHasActiveItem == true 
		and runeOfPerthroInTheRoom == false 
		and playerHasRuneOfPerthro == false
		and numberOfPerthroBlessingPerRun > 0
		and numberOfPerthroBlessingPerFloor > 0
		then 
			Isaac.Spawn(5, 300, 37, activeItemPosition + Vector(0, 40), Vector(0, 0), nil)													--Rune of Perthro ID = 5.300.37
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, activeItemPosition + Vector(0, 40), Vector(0, 0), nil) 	--Light beam from the sky
			numberOfPerthroBlessingPerRun = numberOfPerthroBlessingPerRun - 1
			numberOfPerthroBlessingPerFloor = numberOfPerthroBlessingPerFloor - 1
		end
		       
	end                                  

	return nil
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.spawnRuneOfPerthro)

--====================================================================

function Mod:onNewFloor()

	numberOfPerthroBlessingPerFloor = ModSettings["McMnumberOfPerthroBlessingsPerFloor"] --reset the original number of blessing per FLOOR
	
	return nil
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Mod.onNewFloor)

--====================================================================

function Mod:onGameStart(IsContinued)

	if IsContinued == false then		--it will reset the number of blessing only if you are starting a NEW run
		numberOfPerthroBlessingPerRun = ModSettings["McMnumberOfPerthroBlessingsPerRun"] 
	end
	
	return nil
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.onGameStart)

--====================================================================

--McM: in-game settings
if ModConfigMenu then 
	
	local ModName = "Perthro's Blessing"
	ModConfigMenu.UpdateCategory(ModName, {
		Info = {"Mod made by ZERBI-XCVII",}
	})
	
	----------------------------------------------
	
	--Add a text for next settings
	ModConfigMenu.AddText(ModName, "Settings", function() return "Number of blessings:" end)
	
	--Setting for number of blessings per RUN
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,				--> the variable is a NUMBER
		
		CurrentSetting = function()
			return ModSettings["McMnumberOfPerthroBlessingsPerRun"]		--> select the variable form the ModSettings table 
		end,
		
		Minimum = 0,										--> set min value for the current setting (you can use float number)
		Maximum = 100,										--> set max value for the current setting (you can use float number)
		ModifyBy = 1,										--> set step value for the current setting (you can use float number)
		
		Display = function()
			return "Blessings per RUN = " .. ModSettings["McMnumberOfPerthroBlessingsPerRun"]		--> show the value in the McM
		end,
		
		OnChange = function(currentNum)						--> update the setting value
			ModSettings["McMnumberOfPerthroBlessingsPerRun"] = currentNum
		end,
		
		Info = {"Set the number of blessings per RUN (NOTE: it will reset if you exit the game)."}		--> comment in the McM
	})
	
	--Setting for number of blessings per FLOOR
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,				--> the variable is a NUMBER
		
		CurrentSetting = function()
			return ModSettings["McMnumberOfPerthroBlessingsPerFloor"]		--> select the variable form the ModSettings table 
		end,
		
		Minimum = 0,										--> set min value for the current setting (you can use float number)
		Maximum = 100,										--> set max value for the current setting (you can use float number)
		ModifyBy = 1,										--> set step value for the current setting (you can use float number)
		
		Display = function()
			return "Blessings per FLOOR = " .. ModSettings["McMnumberOfPerthroBlessingsPerFloor"]		--> show the value in the McM
		end,
		
		OnChange = function(currentNum)						--> update the setting value
			ModSettings["McMnumberOfPerthroBlessingsPerFloor"] = currentNum
		end,
		
		Info = {"Set the number of blessings per FLOOR (NOTE: it will reset if you exit the game)."}		--> comment in the McM
	})
	
	-------------------------------------------------------------------------------------------
	
	--Empty line
	ModConfigMenu.AddSpace(ModName, "Settings")
	
	--Add a text for next settings
	ModConfigMenu.AddText(ModName, "Settings", function() return "Rooms where the blessing can occur:" end)
	
	--Setting for Treasure rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["treasureRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["treasureRooms"] then
				onOff = "True"
			end
			return 'Treasure rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["treasureRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Treasure rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Boss rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["bossRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["bossRooms"] then
				onOff = "True"
			end
			return 'Boss rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["bossRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Boss rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Mini Boss rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["miniBossRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["miniBossRooms"] then
				onOff = "True"
			end
			return 'Mini Boss rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["miniBossRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Mini Boss rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Secret rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["secretRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["secretRooms"] then
				onOff = "True"
			end
			return 'Secret rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["secretRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Secret rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Super Secret rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["superSecretRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["superSecretRooms"] then
				onOff = "True"
			end
			return 'Super Secret rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["superSecretRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Super Secret rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Challenge rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["challengeRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["challengeRooms"] then
				onOff = "True"
			end
			return 'Challenge rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["challengeRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Challenge rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Devil rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["devilRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["devilRooms"] then
				onOff = "True"
			end
			return 'Devil rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["devilRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Devil rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Angel rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["angelRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["angelRooms"] then
				onOff = "True"
			end
			return 'Angel rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["angelRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Angel rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Dungeon rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["dungeonRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["dungeonRooms"] then
				onOff = "True"
			end
			return 'Dungeon rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["dungeonRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Dungeon rooms (aka Crawlspaces)."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Boss Rush rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["bossRushRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["bossRushRooms"] then
				onOff = "True"
			end
			return 'Boss Rush rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["bossRushRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Boss Rush rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Chest rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["chestRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["chestRooms"] then
				onOff = "True"
			end
			return 'Chest rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["chestRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Chest rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Ultra Secret rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["ultraSecretRooms"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["ultraSecretRooms"] then
				onOff = "True"
			end
			return 'Ultra Secret rooms: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["ultraSecretRooms"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable blessings for Ultra Secret rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	----------------------------------------------
	
	--Empty line
	ModConfigMenu.AddSpace(ModName, "Settings")
	
	--Add a text for next settings
	ModConfigMenu.AddText(ModName, "Settings", function() return "Debug messages:" end)
	
	--Setting for printing the ID of the collectible items in the rooms
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["printPedestalItems"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["printPedestalItems"] then
				onOff = "True"
			end
			return 'Pedestal items: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["printPedestalItems"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable debug messages for pedestal items (you will be able to see their ID)."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
end

--McM: save function
local json = require("json")
local SaveState = {}
function Mod:SaveGame()

	SaveState.Settings = {}
	for i, v in pairs(ModSettings) do
		SaveState.Settings[tostring(i)] = ModSettings[i]
	end
		Mod:SaveData(json.encode(SaveState))
end
Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Mod.SaveGame)

--McM: load function
function Mod:OnGameStart()
	if Mod:HasData() then	
	
		SaveState = json.decode(Mod:LoadData())	
		for i, v in pairs(SaveState.Settings) do
			ModSettings[tostring(i)] = SaveState.Settings[i]
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.OnGameStart)
local Mod = RegisterMod("Secret Room Hint",1)

--BOI LUA API: 	https://wofsauge.github.io/IsaacDocs/rep/index.html
--USR guide:	https://www.naguide.com/the-binding-of-isaac-rebirth-how-to-find-ultra-secret-rooms/
--USR wiki: 	https://bindingofisaacrebirth.fandom.com/wiki/Secret_Room#Ultra_Secret_Rooms

--[[
TO DO LIST:
- verificare che, utilizzando il mod config menu con le funzioni Mod.XXX, non vengano attivate allo stesso tempo tutte le altre funzioni con lo stesso nome.
  esempio: la funzione per salvare le modifiche del McM viene attivata tramite Mod.SaveGame. Cosa accade se un'altra mod ha la funzione Mod.SaveGame? Vengono attivate entrambe?
  nel caso si attivassero entrambe devo riscrivere quelle funzioni utilizzando nomi propri. O sennò mettere all'inizio un local Mod = nomeMod.

- mettere gli wisp per le S e SS rooms di colore verde (?)

THINGS DONE:

]]--

--McM: default settings
local ModSettings = {

	--Types of wisps
	["S_SS_wisps"]  = true,
	["USR_wisps"]   = true,
	["Crawl_wisps"] = true,
	
	--Base probability
	["baseWispsProbability"]  = 10,
	["bonusWispsProbability"] = 5,
	
	--Colour for S and SS rooms = light-blue
	["S_SS_intRed"]   = 0, 		--> These 3 values are set trough McM
	["S_SS_intGreen"] = 0,
	["S_SS_intBlue"]  = 255,
	
	["S_SS_floatRed"]   = 0,	--> These 3 values are AUTOMATICALLY set after changing the other 3^^^
	["S_SS_floatGreen"] = 0,	--  Why? Because setting a colour through a number between 0-1 is not intuitive. 
	["S_SS_floatBlue"]  = 1,	--  Instead, using the RGB scale (0-255) is easier.
	
	--Colour for USR = red
	["USR_intRed"]   = 255,
	["USR_intGreen"] = 0,
	["USR_intBlue"]  = 0,
	
	["USR_floatRed"]   = 1,
	["USR_floatGreen"] = 0,
	["USR_floatBlue"]  = 0,
	
	--Colour for Crawlspaces = purple
	["Crawl_intRed"]   = 255,
	["Crawl_intGreen"] = 0,
	["Crawl_intBlue"]  = 255,
	
	["Crawl_floatRed"]   = 1,
	["Crawl_floatGreen"] = 0,
	["Crawl_floatBlue"]  = 1
}

function Mod:onNewRoom()
	
	--Check S-SS-US Rooms based on luck
	local player = Isaac.GetPlayer(0)
	local probabilityWisp = ModSettings["baseWispsProbability"] + (player.Luck * ModSettings["bonusWispsProbability"]) 
	local randomNumb = math.random(100)

	if randomNumb <= probabilityWisp then
		
		--Check for S and SS rooms
		if ModSettings["S_SS_wisps"] then
			Mod:findSecretDoor()
		end
		
		--Check for USR
		if ModSettings["USR_wisps"] and REPENTANCE then
			Mod:findUSR()
		end
		
		--Check for Crawlspaces
		if ModSettings["Crawl_wisps"] then
			Mod:findCrawlspace()
		end
		
	end
	
	return nil
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.onNewRoom)

---------------------------------------------------------------------------------------------------------------------------------

function Mod:findSecretDoor()
	
	--Check if we are in a S or SS Room (we don't need to check if we are in a USR)
	local level = Game():GetLevel()
	local currentRoom = level:GetCurrentRoom()
	local currentRoomType = currentRoom:GetType()
	local NOT_in_a_Secret_Room = true
	if currentRoomType == RoomType.ROOM_SECRET or
	   currentRoomType == RoomType.ROOM_SUPERSECRET then
	   NOT_in_a_Secret_Room = false
	end	
	
	if NOT_in_a_Secret_Room then
	
		--Check Secret Room entrances
		local door_slot = 0									--"position type of door" -> Left, right, up, down, ecc...
		local totalDoorNumber = DoorSlot.NUM_DOOR_SLOTS
		
		while door_slot < totalDoorNumber do 
			if currentRoom:IsDoorSlotAllowed(door_slot) then
				door = currentRoom:GetDoor(door_slot)
				if door ~= nil then 						--verify that the door exist
					if door:IsRoomType(RoomType.ROOM_SUPERSECRET) or door:IsRoomType(RoomType.ROOM_SECRET) then                         
						local R = ModSettings["S_SS_floatRed"]
						local G = ModSettings["S_SS_floatGreen"]
						local B = ModSettings["S_SS_floatBlue"]
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WISP, 0, door.Position, Vector(0,0), nil):SetColor(Color(R, G, B, 1, 0, 0, 0), 1000, 1, false, false)	--for the Color set R,G,B with float between 0 and 1. A=1. R0,B0,G0 are from -255 to 255 but put 0...
					end
				end
			end
			door_slot = door_slot + 1
		end
		
	end
	
	return nil
	
end

----------------------------------------------------------------------------------------------------------------------------------

function Mod:findUSR()
		
	--Check if you own something that can make Red Rooms
	local player = Isaac.GetPlayer(0)
	local canCreateRedRoom = false
			
	--Check for items
	if player:HasCollectible(CollectibleType.COLLECTIBLE_RED_KEY, false) then
		canCreateRedRoom = true
	end
	
	--Check for cards
	for i = 0, 3, 1 do
		if player:GetCard(i) == Card.CARD_CRACKED_KEY or player:GetCard(i) == Card.CARD_SOUL_CAIN then
			canCreateRedRoom = true
		end
	end
	
	--[[
	Check for Ultra Secret Rooms (U) adiacent to the Current Room (C) with this pattern:
	
	[ ][ ][U][ ][ ]
	[ ][U][ ][U][ ]
	[U][ ][C][ ][U]
	[ ][U][ ][U][ ]
	[ ][ ][U][ ][ ]
	
	]]--
	
	--If you can make Red Rooms it checks for USR
	if canCreateRedRoom == true then
		
		local level = Game():GetLevel()
		local currentRoomIndex = level:GetCurrentRoomIndex()	-- Return the room ID based on the LEVEL grid --> https://wofsauge.github.io/IsaacDocs/rep/Level.html?h=getcurrentroomindex#getcurrentroomindex
		local roomIDpattern = { -14, -12, 12, 14, -2, 2, -26, 26}

		for i = 1, #roomIDpattern do
			local roomDescription = level:GetRoomByIdx(currentRoomIndex + roomIDpattern[i], -1)			--(RoomIdx, Dimension) put "Dimension" = -1
			local roomConfig = roomDescription.Data
			if roomConfig ~= nil then							--check only if the room exist
				local roomType = roomConfig.Type
				if roomType == RoomType.ROOM_ULTRASECRET then
					local currentRoomCentre = Game():GetRoom():GetCenterPos()
					local R = ModSettings["USR_floatRed"]
					local G = ModSettings["USR_floatGreen"]
					local B = ModSettings["USR_floatBlue"]
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WISP, 0, currentRoomCentre, Vector(0,0), nil):SetColor(Color(R, G, B, 1, 0, 0, 0), 1000, 1, false, false)
					return nil
				end
			end
		end
	end
	
	return nil
	
end

----------------------------------------------------------------------------------------------------------------------------------

function Mod:findCrawlspace()
	
	--Seed for the test: MPNXXPSS (Repentance, Normal mode -> crawl space on the second room to the left)
	
	local level = Game():GetLevel()
	local room = level:GetCurrentRoom()
	local player = Isaac.GetPlayer(0)

	local rockGridID = room:GetDungeonRockIdx()													--> grid ID of rock with a trapdoor beneath (use "debug 11" in order to show an in-game grid)
	
	if rockGridID > -1 then																		--> if rockGridID == -1 --> there is NOT a crawlspace in the room
		
		local collisionAtRockGridID = room:GetGridCollision(rockGridID)							--> type of collision on that grid ID. It must return "3" for a solid object like a rock, poop, jar, ecc...
		local rockVectorPosition = room:GetGridPosition(rockGridID)								--> convert the grid ID of the rock in a vector
		local rockIsInTheRoom = room:IsPositionInRoom(rockVectorPosition, 0)					--> check if the rock is actually in the room (is it necessary? Maybe. The collision check should be enough but I'll leave here in any case...)
		local gridEntityAtRockVectorPosition = room:GetGridEntityFromPos(rockVectorPosition)	
		local gridEntityTypeAtRockVectorPosition = gridEntityAtRockVectorPosition:GetType()		--> check the type of entity above the trapdoor --> if type == 3 --> it is a black block (unbreakable) --> the wisp will NOT spawn

		if collisionAtRockGridID == 3 and rockIsInTheRoom and gridEntityTypeAtRockVectorPosition ~= 3 then
		
			local currentRoomCentre = room:GetCenterPos()
			local R = ModSettings["Crawl_floatRed"]
			local G = ModSettings["Crawl_floatGreen"]
			local B = ModSettings["Crawl_floatBlue"]
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WISP, 0, currentRoomCentre, Vector(0,0), nil):SetColor(Color(R, G, B, 1, 0, 0, 0), 1000, 1, false, false)
	
		end

	end
				
	return nil
	
end

----------------------------------------------------------------------------------------------------------------------------------

--McM: settings modifications
if ModConfigMenu then 
	
	local ModName = "Secret Room Hint"
	ModConfigMenu.UpdateCategory(ModName, {
		Info = {"Mod made by ZERBI-XCVII",}
	})
	
	----------------------------------------------
	
	--Add a text for next settings
	ModConfigMenu.AddText(ModName, "Settings", function() return "Types of wisps:" end)
	
	--Setting for S_SS_wisps
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["S_SS_wisps"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["S_SS_wisps"] then
				onOff = "True"
			end
			return 'S and SS rooms wisps: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["S_SS_wisps"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable wisps for Secret and Super Secret Rooms."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for USR_wisps
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["USR_wisps"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["USR_wisps"] then
				onOff = "True"
			end
			return 'US rooms wisps: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["USR_wisps"] = currentBool
		end,
		
		Info = {"Enable/Disable wisps for Ultra Secret Rooms."}
	})
	
	--Setting for Crawl_wisps
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["Crawl_wisps"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["Crawl_wisps"] then
				onOff = "True"
			end
			return 'Crawlspaces wisps: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["Crawl_wisps"] = currentBool
		end,
		
		Info = {"Enable/Disable wisps for Crawlspaces."}
	})
	
	----------------------------------------------
	
	--Empty line
	ModConfigMenu.AddSpace(ModName, "Settings")
	
	--Add a text for next settings
	ModConfigMenu.AddText(ModName, "Settings", function() return "Wisps spawn probability:" end)
	
	--Setting for baseWispsProbability
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,		--> now the variable is a NUMBER
		
		CurrentSetting = function()
			return ModSettings["baseWispsProbability"]		--> select the variable form the ModSettings table 
		end,
		
		Minimum = 0,										--> set min value for the current setting (you can use float number)
		Maximum = 100,										--> set max value for the current setting (you can use float number)
		ModifyBy = 5,										--> set step value for the current setting (you can use float number)
		
		Display = function()
			return "Base probability = " .. ModSettings["baseWispsProbability"] .. "%"		--> show the value in the Mcm. With -> .. "%" <- I concatenate the symbol % to the current string shown in the screen
		end,
		
		OnChange = function(currentNum)									--> update the setting value
			ModSettings["baseWispsProbability"] = currentNum
		end,
		
		Info = {"Set the base probability for wisps to be spawned."}		--> comment in the McM
	})
		
	--Setting for bonusWispsProbability
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,		
		
		CurrentSetting = function()
			return ModSettings["bonusWispsProbability"]		
		end,
		
		Minimum = 0,										
		Maximum = 100,										
		ModifyBy = 1,										
		
		Display = function()
			return "Bonus probability = " .. ModSettings["bonusWispsProbability"] .. "%"		
		end,
		
		OnChange = function(currentNum)									
			ModSettings["bonusWispsProbability"] = currentNum
		end,
		
		Info = {"Set the bonus probability for wisps to be spawned for each point of luck you have (ex. +1 Luck = +5% probability)."}		
	})
	
	----------------------------------------------
	
	--Empty line
	ModConfigMenu.AddSpace(ModName, "Settings")
	
	--Add a text for next settings
	ModConfigMenu.AddText(ModName, "Settings", function() return "S and SS rooms wisps colour:" end)
	
	--Setting for S_SS_intRed
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,		
		
		CurrentSetting = function()
			return ModSettings["S_SS_intRed"]		
		end,
		
		Minimum = 0,										
		Maximum = 255,										
		ModifyBy = 1,										
		
		Display = function()
			return "R = " .. ModSettings["S_SS_intRed"]		
		end,
		
		OnChange = function(currentNum)									
			ModSettings["S_SS_intRed"] = currentNum
			ModSettings["S_SS_floatRed"] = ModSettings["S_SS_intRed"]/255 --> convert an integer number between 0-255 in a float number between 0-1
		end,
		
		Info = {"Set the RED value in the RGB scale."}		
	})
	
	--Setting for S_SS_intGreen
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,		
		
		CurrentSetting = function()
			return ModSettings["S_SS_intGreen"]		
		end,
		
		Minimum = 0,										
		Maximum = 255,										
		ModifyBy = 1,										
		
		Display = function()
			return "G = " .. ModSettings["S_SS_intGreen"]		
		end,
		
		OnChange = function(currentNum)									
			ModSettings["S_SS_intGreen"] = currentNum
			ModSettings["S_SS_floatGreen"] = ModSettings["S_SS_intGreen"]/255
		end,
		
		Info = {"Set the GREEN value in the RGB scale."}		
	})
	
	--Setting for S_SS_intBlue
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,		
		
		CurrentSetting = function()
			return ModSettings["S_SS_intBlue"]		
		end,
		
		Minimum = 0,										
		Maximum = 255,										
		ModifyBy = 1,										
		
		Display = function()
			return "B = " .. ModSettings["S_SS_intBlue"]		
		end,
		
		OnChange = function(currentNum)									
			ModSettings["S_SS_intBlue"] = currentNum
			ModSettings["S_SS_floatBlue"] = ModSettings["S_SS_intBlue"]/255
		end,
		
		Info = {"Set the BLUE value in the RGB scale."}		
	})
	
	----------------------------------------------
	
	--Empty line
	ModConfigMenu.AddSpace(ModName, "Settings")
	
	--Add a text for next settings
	ModConfigMenu.AddText(ModName, "Settings", function() return "US rooms wisps colour:" end)
	
	--Setting for USR_intRed
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,		
		
		CurrentSetting = function()
			return ModSettings["USR_intRed"]		
		end,
		
		Minimum = 0,										
		Maximum = 255,										
		ModifyBy = 1,										
		
		Display = function()
			return "R = " .. ModSettings["USR_intRed"]		
		end,
		
		OnChange = function(currentNum)									
			ModSettings["USR_intRed"] = currentNum
			ModSettings["USR_floatRed"] = ModSettings["USR_intRed"]/255
		end,
		
		Info = {"Set the RED value for the RGB scale."}		
	})
	
	--Setting for USR_intGreen
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,		
		
		CurrentSetting = function()
			return ModSettings["USR_intGreen"]		
		end,
		
		Minimum = 0,										
		Maximum = 255,										
		ModifyBy = 1,										
		
		Display = function()
			return "G = " .. ModSettings["USR_intGreen"]		
		end,
		
		OnChange = function(currentNum)									
			ModSettings["USR_intGreen"] = currentNum
			ModSettings["USR_floatGreen"] = ModSettings["USR_intGreen"]/255
		end,
		
		Info = {"Set the GREEN value in the RGB scale."}		
	})
	
	--Setting for USR_intBlue
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,		
		
		CurrentSetting = function()
			return ModSettings["USR_intBlue"]		
		end,
		
		Minimum = 0,										
		Maximum = 255,										
		ModifyBy = 1,										
		
		Display = function()
			return "B = " .. ModSettings["USR_intBlue"]		
		end,
		
		OnChange = function(currentNum)									
			ModSettings["USR_intBlue"] = currentNum
			ModSettings["USR_floatBlue"] = ModSettings["USR_intBlue"]/255
		end,
		
		Info = {"Set the BLUE value in the RGB scale."}		
	})
	
	----------------------------------------------
	
	--Empty line
	ModConfigMenu.AddSpace(ModName, "Settings")
	
	--Add a text for next settings
	ModConfigMenu.AddText(ModName, "Settings", function() return "Crawlspaces wisps colour:" end)
	
	--Setting for Crawl_intRed
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,		
		
		CurrentSetting = function()
			return ModSettings["Crawl_intRed"]		
		end,
		
		Minimum = 0,										
		Maximum = 255,										
		ModifyBy = 1,										
		
		Display = function()
			return "R = " .. ModSettings["Crawl_intRed"]		
		end,
		
		OnChange = function(currentNum)									
			ModSettings["Crawl_intRed"] = currentNum
			ModSettings["Crawl_floatRed"] = ModSettings["Crawl_intRed"]/255
		end,
		
		Info = {"Set the RED value in the RGB scale."}		
	})
	
	--Setting for Crawl_intBlue
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,		
		
		CurrentSetting = function()
			return ModSettings["Crawl_intBlue"]		
		end,
		
		Minimum = 0,										
		Maximum = 255,										
		ModifyBy = 1,										
		
		Display = function()
			return "G = " .. ModSettings["Crawl_intGreen"]		
		end,
		
		OnChange = function(currentNum)									
			ModSettings["Crawl_intGreen"] = currentNum
			ModSettings["Crawl_floatGreen"] = ModSettings["Crawl_intGreen"]/255
		end,
		
		Info = {"Set the GREEN value in the RGB scale."}		
	})
	
	--Setting for Crawl_intBlue
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.NUMBER,		
		
		CurrentSetting = function()
			return ModSettings["Crawl_intBlue"]		
		end,
		
		Minimum = 0,										
		Maximum = 255,										
		ModifyBy = 1,										
		
		Display = function()
			return "B = " .. ModSettings["Crawl_intBlue"]		
		end,
		
		OnChange = function(currentNum)									
			ModSettings["Crawl_intBlue"] = currentNum
			ModSettings["Crawl_floatBlue"] = ModSettings["Crawl_intBlue"]/255
		end,
		
		Info = {"Set the BLUE value in the RGB scale."}		
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

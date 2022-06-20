Arachnophobia = RegisterMod("Arachnophobia - No Spiders", 1)
local Mod = Arachnophobia

--REP LUA API Docs: https://moddingofisaac.com/docs/rep/index.html
--AB+ LUA API Docs: https://moddingofisaac.com/docs/abp/

--ModConfigMenu files and variables:
local json = require("json")
local config = {

	MonstersAndBosses 	 = true,
	BlueSpiders 	 	 = true,
	SpiderItems 		 = true,
	DebugMessages        = false
}

--Table/Map for the replacements: ["key"]={vector}
local rTable = {["851.0"] = {Type = 850, Variant = 0}, 								-- Twitchy ---------------> Level 2 Gaper
				["205.0"] = {Type = 22,  Variant = 0}, 								-- Nest ------------------> Hive
				["820.0"] = {Type = 24,  Variant = 0}, 								-- Danny -----------------> Globin
				["29.1"]  = {Type = 29,  Variant = 0}, 								-- Trite -----------------> Hopper
				["246.0"] = {Type = 29,  Variant = 0}, 								-- Ragling ---------------> Hopper
				["246.1"] = {Type = 34,  Variant = 0}, 								-- Rag Man's Ragling -----> Leaper
				["303.0"] = {Type = 54,  Variant = 0}, 								-- Blister ---------------> Flaming Hopper
				["85.0"]  = {Type = 18,  Variant = 0, respawn = true}, 				-- Spider ----------------> Attack Fly
				["94.0"]  = {Type = 80,  Variant = 0}, 								-- Big Spider ------------> Moter
				["814.0"] = {Type = 18,  Variant = 0}, 								-- Strider ---------------> Attack Fly
				["818.0"] = {Type = 61,  Variant = 6, quantity = 2},				-- Rock Spider -----------> Bloodfly (x2)
				["818.1"] = {Type = 808, Variant = 0, quantity = 2},				-- Tinted Rock Spider ----> Willo (x2)
				["818.2"] = {Type = 25,  Variant = 3, respawn = true},              -- Coal Spider -----------> Dragon Fly
				["884.0"] = {Type = 18,  Variant = 0, respawn = true}, 				-- Swarm Spider ----------> Attack Fly
				["206.0"] = {Type = 15,  Variant = 2}, 								-- Baby Long Legs --------> I.Blob
				["206.1"] = {Type = 15,  Variant = 0}, 								-- Small Baby Long Legs --> Clotty
				["207.0"] = {Type = 15,  Variant = 3}, 								-- Crazy Long Legs -------> Grilled Clotty
				["207.1"] = {Type = 15,  Variant = 1}, 								-- Small Crazy Long Legs -> Clot
				["215.0"] = {Type = 29,  Variant = 0}, 								-- Level 2 Spider --------> Hopper
				["250.0"] = {Type = 25,  Variant = 0}, 								-- Ticking Spider --------> Boom Fly
				["869.0"] = {Type = 25,  Variant = 2}, 								-- Migraine --------------> Drowned Boom Fly       
				["240.0"] = {Type = 12,  Variant = 0}, 								-- Wall Creep ------------> Horf
				["240.1"] = {Type = 868, Variant = 0, quantity = 5},				-- Soy Creep -------------> Army Fly (x5)
				["240.3"] = {Type = 61,  Variant = 7}, 								-- Tainted Soy Creep -----> Tainted Sucker
				["241.0"] = {Type = 260, Variant = 10}, 							-- Rage Creep ------------> Lil' Haunt
				["242.0"] = {Type = 25,  Variant = 1}, 								-- Blind Creep -----------> Red Boom Fly
				["304.0"] = {Type = 26,  Variant = 1}, 								-- The Thing -------------> Red Maw
				--BOSSES
				["100.0"] = {Type = 20,  Variant = 0, respawn = true}, 				-- Widow -----------------> Monstro
				["100.1"] = {Type = 269, Variant = 0, respawn = true}, 				-- The Wretched ----------> Polycephalus
				["101.0"] = {Type = 62,  Variant = 1, respawn = true}, 				-- Daddy Long Legs -------> Scolex
				["101.1"] = {Type = 68,  Variant = 1, respawn = true}, 				-- Triachnid -------------> The Bloat
				["900.0"] = {Type = 904, Variant = 0, respawn = true}, 				-- Reap Creep ------------> Siren
				}


local itemsBlackList = {288, 171, 170, 234, 266, 153, 280, 
						 89, 211, 377, 403, 367, 717, 575}


function Mod:replaceSpiderMonsters(eNPC)																							--This function receive the EntityNPC of the monster that want to be spawned.
	
	if config.MonstersAndBosses == true then
	
		local eNPCstring = tostring(eNPC.Type .. "." .. eNPC.Variant)																--I make a string made of the concatenations Type.Variant of the monster that want to be spawned.  //With ".." you can concatenate something.					
																																	--I create this string before the "for" loop in order to avoid calling (in the "if" inside the "for" loop)the function "tostring" continually.
		--Search the key in the table:
		for key, newNPC in pairs(rTable) do																							--For each step in that loop, "key" gets a key of the table, while "newNPC" gets the value (an array in our case) associated with that key.  //  Use "pairs" if the keys can be everything, use "ipairs" if the keys are only integer.
		
			if key == eNPCstring then																								--Compare the current key of the table (that is a string made of Type.Variant) with "eNPCstring" (that contains the concatenation of Type.Variant of the monster that want to be spawned)
							
				--Morph the entity that want to be spawned with the replacement monster:
				if (newNPC.respawn ~= nil) then																						--do this part only if the respawn in necessary
					--this fixes broken velocity and height (that happen when certain monsters spawn other spider monsters)
					if REPENTANCE and eNPC:GetChampionColorIdx() >= 0 then															--spawn champion monster if necessary
						Isaac.Spawn(newNPC.Type, newNPC.Variant, 0, eNPC.Position, eNPC.Velocity, nil):ToNPC():MakeChampion(Game():GetRoom():GetSpawnSeed(), eNPC:GetChampionColorIdx(), true)
						eNPC:Remove()
					else																											--spawn normal monster
						Isaac.Spawn(newNPC.Type, newNPC.Variant, 0, eNPC.Position, eNPC.Velocity, nil)
						eNPC:Remove()
					end
				else 																												--if the "respawn" is not present
					eNPC:Morph(newNPC.Type, newNPC.Variant, 0, eNPC:GetChampionColorIdx())											--If the original monster is a champion, with "eNPC:GetChampionColorIdx()" I can replace it with another champion of the same type. If the original monster is not a champion his color will be -1. If i use "morph" with colore = -1 I will create a normal monster// In general, to acces a field of an array in a table I can also use:  rTable["85.0"].Type
				end
				if config.DebugMessages == true then
					print("Spawner =", tostring(eNPC.SpawnerType .. "." .. eNPC.SpawnerVariant), "->", "Replaced =", key, "->", "Replacement =", tostring(newNPC.Type .. "." .. newNPC.Variant)) --This line is used for debug. It prints the spawner (of the monster that will be replaced), the replaced monster and the replacement monster. 
				end
				
				--Spawn additional monsters if necessary:
				if newNPC.quantity ~= nil then																						-- "~=" means NOT equal	
					for i=1, newNPC.quantity-1, 1 do
						if REPENTANCE and eNPC:GetChampionColorIdx() >= 0 then														--i need to be sure that the color is >= 0 because otherwise, if the original monster is not a champion it has color=-1 and, if you put -1 in the function "MakeChampion()", you will obtain a random champion (that is wrong because we want the same champion color as the original one)
							Isaac.Spawn(newNPC.Type, newNPC.Variant, 0, eNPC.Position, eNPC.Velocity, nil):ToNPC():MakeChampion(Game():GetRoom():GetSpawnSeed(), eNPC:GetChampionColorIdx(), true)
						else																										--if you have AB+ or if the monster in not a champion --> spawn normal monsters (because AB+ does not have the function "MakeChampion()" like REP... it has it but you cannot set the champion color so we don't need it)
							Isaac.Spawn(newNPC.Type, newNPC.Variant, 0, eNPC.Position, eNPC.Velocity, nil)
						end
						if config.DebugMessages == true then
							print("Additional replacement -------------------------->", tostring(newNPC.Type .. "." .. newNPC.Variant)) --Another line for debug
						end
					end
				end
				
				
				--Special case for "Tinted Rock" monsters --> spawn an additional "Soul Heart":
				if key == "818.1" then	
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, eNPC.Position, eNPC.Velocity, nil)
				end
				
				
				return nil																											--"return" after finding a correspondance in order to avoid looking through all the table.
			
			end																						
		end
	end
	
	return nil
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Mod.replaceSpiderMonsters)


------------------------------------------------------------------------------------------------------------------


function Mod:replaceBlueSpiders(eBlueSpider)

	if config.BlueSpiders == true then
	
		local player = Isaac.GetPlayer(0)
		
		eBlueSpider:Remove()
		player:AddBlueFlies(1, player.Position, nil)		--(Amount, Position, Target)
		
		if config.DebugMessages == true then
			print("1 Blue Spider replaced with 1 Blue Fly")
		end
		
	end
	
	return nil
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Mod.replaceBlueSpiders, FamiliarVariant.BLUE_SPIDER)


------------------------------------------------------------------------------------------------------------------


function Mod:removeItems()

	if config.SpiderItems == true then
	
		local itemPool = Game():GetItemPool()
		
		for i=1, #itemsBlackList do											--Adds a given item to the blacklist. 
																			--This item can no longer be chosen from itempools while the player is inside the current room.
			itemPool:AddRoomBlacklist(itemsBlackList[i])					--This effectively prevents the item from appearing.
																			--When the player changes the room, the Blacklist gets reset.
		end
		
	end
	
	return nil
	
end

--Callback
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.removeItems)


----------------------------------------------------------------------------------------------------------------------------------


-- Mod Config Menu load settings
function Mod:postGameStarted()
    if Mod:HasData() then
        local data = json.decode(Mod:LoadData())
        for k, v in pairs(data) do
            if config[k] ~= nil then config[k] = v end
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.postGameStarted)


-- Save settings
function Mod:preGameExit() Mod:SaveData(json.encode(config)) end
Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Mod.preGameExit)


-- Menu options
if ModConfigMenu then
  	local category = "Arachnophobia"
	ModConfigMenu.RemoveCategory(category);
  	ModConfigMenu.UpdateCategory(category, {
		Name = category,
		Info = "Change settings for Arachnophobia"
	})
	
	-- General settings
	ModConfigMenu.AddSetting(category, "General settings", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.MonstersAndBosses end,
	    Display = function() return "Monsters & Bosses: " .. (config.MonstersAndBosses and "True" or "False") end,
	    OnChange = function(bool)
	    	config.MonstersAndBosses = bool
	    end,
	    Info = {"Enable/Disable replacements for Monsters and Bosses."}
  	})
	
  	ModConfigMenu.AddSetting(category, "General settings", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.BlueSpiders end,
	    Display = function() return "Blue Spiders: " .. (config.BlueSpiders and "True" or "False") end,
	    OnChange = function(bool)
	    	config.BlueSpiders = bool
	    end,
	    Info = {"Enable/Disable replacements for Blue Spiders."}
  	})
	
	ModConfigMenu.AddSetting(category, "General settings", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.SpiderItems end,
	    Display = function() return "Spider Items: " .. (config.SpiderItems and "True" or "False") end,
	    OnChange = function(bool)
	    	config.SpiderItems = bool
	    end,
	    Info = {"Enable/Disable replacements for Spider Items."}
  	})
	
	ModConfigMenu.AddSetting(category, "General settings", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.DebugMessages end,
	    Display = function() return "Debug Messages: " .. (config.DebugMessages and "True" or "False") end,
	    OnChange = function(bool)
	    	config.DebugMessages = bool
	    end,
	    Info = {"Enable/Disable messages in the debug console."}
  	})
	
end



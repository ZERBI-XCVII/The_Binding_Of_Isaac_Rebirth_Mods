local Mod = RegisterMod("No Useless Hearts", 1) --update 21

-- Lua API Documentation for Repentance:  https://moddingofisaac.com/docs/rep/
-- Lua API Documentation for Afterbirth+: https://moddingofisaac.com/docs/abp/
-- Wiki for The Binding Of Isaac Rebirth: https://bindingofisaacrebirth.fandom.com/wiki/Binding_of_Isaac:_Rebirth_Wiki

--[[
==============================================================================
UPDATE 21:
basically I remade the mod:
- now it uses tables instead of a lot of "if"
- new Mod Confing Menu implementation
==============================================================================
COSE DA FARE
- risolvere il problema di certe player_creep che non si espandono bene... fanno tipo uno scatto
  questo accade in quella blu e gialla (quelle rosse, nere, bianche vanno bene).
==============================================================================
]]--

SFX = SFXManager()

--McM: default settings
local ModSettings = {

	--Special characters
	["blue_baby"] = true,
	["tainted_blue_baby"] = true,
	["the_lost"] = true,
	["tainted_lost"] = true,
	
	--Types of replacements
	["type_1"] = true,
	["type_2"] = true,
	["type_3"] = true,
	["type_4"] = true,
	["type_5"] = true,
	["type_6"] = true,
	["type_7"] = true,
	["type_8"] = true
	
}

--Main function
function Mod:replacementSelection(pickup, collider, low)  --this function recive from the callback the entity of the pickup that has activated the callback
	
	--Variables
	local player = Isaac.GetPlayer(0)
	local playerType = player:GetPlayerType()
	local SpecialFamiliarIsPresent = false
	local SpecialCharacterForRedHeartsIsPresent = false
	local SpecialCharacterForAllHeartsIsPresent = false
	local ModMenuCharacterIsPresent = false
	local TheLostOrTaintedLostIsPresent = false
	local SpecialTrinketIsPresent = false
	local SpecialItemIsPresent = false
	local randomNumb = math.random(100)   --a number between 1 and 100 (it will be used in the next replacements)
	
	--Tables for replacements					    				
	local half_red_heart_table 		= {["penny"]           = {prob_interval_start =  0, prob_interval_end =  40},	--40% probability
									   ["double_penny"]    = {prob_interval_start = 40, prob_interval_end =  70},	--30% probability
									   ["nickel"]          = {prob_interval_start =  0, prob_interval_end =   0},
									   ["bomb"]            = {prob_interval_start =  0, prob_interval_end =   0},
									   ["key"]             = {prob_interval_start =  0, prob_interval_end =   0},
									   ["half_soul_heart"] = {prob_interval_start = 70, prob_interval_end =  90},	--20% probability
									   ["soul_heart"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["black_heart"]     = {prob_interval_start =  0, prob_interval_end =   0},
									   ["blue_flies"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["heart_explosion"] = {prob_interval_start = 90, prob_interval_end = 100}}	--10% probability
								 
	local full_red_heart_table 		= {["penny"]           = {prob_interval_start =  0, prob_interval_end =   0},	
									   ["double_penny"]    = {prob_interval_start =  0, prob_interval_end =  30},	
								       ["nickel"]          = {prob_interval_start =  0, prob_interval_end =   0},
								       ["bomb"]            = {prob_interval_start = 30, prob_interval_end =  40},
								       ["key"]             = {prob_interval_start = 40, prob_interval_end =  50},
								       ["half_soul_heart"] = {prob_interval_start = 50, prob_interval_end =  80},	
								       ["soul_heart"]      = {prob_interval_start = 80, prob_interval_end =  85},
								       ["black_heart"]     = {prob_interval_start = 85, prob_interval_end =  90},
									   ["blue_flies"]      = {prob_interval_start =  0, prob_interval_end =   0},
								       ["heart_explosion"] = {prob_interval_start = 90, prob_interval_end = 100}}
								 
	local double_red_heart_table 	= {["penny"]           = {prob_interval_start =  0, prob_interval_end =   0},	
								       ["double_penny"]    = {prob_interval_start =  0, prob_interval_end =   0},	
									   ["nickel"]          = {prob_interval_start =  0, prob_interval_end =  10},
									   ["bomb"]            = {prob_interval_start = 10, prob_interval_end =  30},
									   ["key"]             = {prob_interval_start = 30, prob_interval_end =  50},
									   ["half_soul_heart"] = {prob_interval_start =  0, prob_interval_end =   0},	
									   ["soul_heart"]      = {prob_interval_start = 50, prob_interval_end =  70},
									   ["black_heart"]     = {prob_interval_start = 70, prob_interval_end =  90},
									   ["blue_flies"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["heart_explosion"] = {prob_interval_start = 90, prob_interval_end = 100}}
								   
	local half_soul_heart_table 	= {["penny"]           = {prob_interval_start =  0, prob_interval_end =  45},	
								       ["double_penny"]    = {prob_interval_start = 45, prob_interval_end =  90},	
								       ["nickel"]          = {prob_interval_start =  0, prob_interval_end =   0},
								       ["bomb"]            = {prob_interval_start =  0, prob_interval_end =   0},
								       ["key"]             = {prob_interval_start =  0, prob_interval_end =   0},
								       ["half_soul_heart"] = {prob_interval_start =  0, prob_interval_end =   0},	
								       ["soul_heart"]      = {prob_interval_start =  0, prob_interval_end =   0},
								       ["black_heart"]     = {prob_interval_start =  0, prob_interval_end =   0},
									   ["blue_flies"]      = {prob_interval_start =  0, prob_interval_end =   0},
								       ["heart_explosion"] = {prob_interval_start = 90, prob_interval_end = 100}}
								  
	local soul_heart_table 			= {["penny"]           = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["double_penny"]    = {prob_interval_start =  0, prob_interval_end =  20},	
							           ["nickel"]          = {prob_interval_start = 20, prob_interval_end =  30},
							           ["bomb"]            = {prob_interval_start = 30, prob_interval_end =  60},
						               ["key"]             = {prob_interval_start = 60, prob_interval_end =  90},
						               ["half_soul_heart"] = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["soul_heart"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["black_heart"]     = {prob_interval_start =  0, prob_interval_end =   0},
									   ["blue_flies"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["heart_explosion"] = {prob_interval_start = 90, prob_interval_end = 100}}
							 
	local blended_heart_table 		= {["penny"]           = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["double_penny"]    = {prob_interval_start =  0, prob_interval_end =  20},	
							           ["nickel"]          = {prob_interval_start = 20, prob_interval_end =  30},
							           ["bomb"]            = {prob_interval_start = 30, prob_interval_end =  60},
						               ["key"]             = {prob_interval_start = 60, prob_interval_end =  90},
						               ["half_soul_heart"] = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["soul_heart"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["black_heart"]     = {prob_interval_start =  0, prob_interval_end =   0},
									   ["blue_flies"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["heart_explosion"] = {prob_interval_start = 90, prob_interval_end = 100}}
								 
	local black_heart_table 		= {["penny"]           = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["double_penny"]    = {prob_interval_start =  0, prob_interval_end =  20},	
							           ["nickel"]          = {prob_interval_start = 20, prob_interval_end =  30},
							           ["bomb"]            = {prob_interval_start = 30, prob_interval_end =  60},
						               ["key"]             = {prob_interval_start = 60, prob_interval_end =  90},
						               ["half_soul_heart"] = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["soul_heart"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["black_heart"]     = {prob_interval_start =  0, prob_interval_end =   0},
									   ["blue_flies"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["heart_explosion"] = {prob_interval_start = 90, prob_interval_end = 100}}
	
	local bone_heart_table 			= {["penny"]           = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["double_penny"]    = {prob_interval_start =  0, prob_interval_end =  20},	
							           ["nickel"]          = {prob_interval_start = 20, prob_interval_end =  30},
							           ["bomb"]            = {prob_interval_start = 30, prob_interval_end =  60},
						               ["key"]             = {prob_interval_start = 60, prob_interval_end =  90},
						               ["half_soul_heart"] = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["soul_heart"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["black_heart"]     = {prob_interval_start =  0, prob_interval_end =   0},
									   ["blue_flies"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["heart_explosion"] = {prob_interval_start = 90, prob_interval_end = 100}}
								 
	local golden_heart_table 		= {["penny"]           = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["double_penny"]    = {prob_interval_start =  0, prob_interval_end =  20},	
							           ["nickel"]          = {prob_interval_start = 20, prob_interval_end =  30},
							           ["bomb"]            = {prob_interval_start = 30, prob_interval_end =  60},
						               ["key"]             = {prob_interval_start = 60, prob_interval_end =  90},
						               ["half_soul_heart"] = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["soul_heart"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["black_heart"]     = {prob_interval_start =  0, prob_interval_end =   0},
									   ["blue_flies"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["heart_explosion"] = {prob_interval_start = 90, prob_interval_end = 100}}
								  
	local eternal_heart_table 		= {["penny"]           = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["double_penny"]    = {prob_interval_start =  0, prob_interval_end =  20},	
							           ["nickel"]          = {prob_interval_start = 20, prob_interval_end =  30},
							           ["bomb"]            = {prob_interval_start = 30, prob_interval_end =  60},
						               ["key"]             = {prob_interval_start = 60, prob_interval_end =  90},
						               ["half_soul_heart"] = {prob_interval_start =  0, prob_interval_end =   0},	
							           ["soul_heart"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["black_heart"]     = {prob_interval_start =  0, prob_interval_end =   0},
									   ["blue_flies"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["heart_explosion"] = {prob_interval_start = 90, prob_interval_end = 100}}
								 
	local rotten_heart_table 		= {["penny"]           = {prob_interval_start =  0, prob_interval_end =   0},	
									   ["double_penny"]    = {prob_interval_start =  0, prob_interval_end =   0},	
									   ["nickel"]          = {prob_interval_start =  0, prob_interval_end =   0},
									   ["bomb"]            = {prob_interval_start =  0, prob_interval_end =   0},
									   ["key"]             = {prob_interval_start =  0, prob_interval_end =   0},
									   ["half_soul_heart"] = {prob_interval_start =  0, prob_interval_end =   0},	
									   ["soul_heart"]      = {prob_interval_start =  0, prob_interval_end =   0},
									   ["black_heart"]     = {prob_interval_start =  0, prob_interval_end =   0},
									   ["blue_flies"]      = {prob_interval_start =  0, prob_interval_end =  90},
									   ["heart_explosion"] = {prob_interval_start = 90, prob_interval_end = 100}}
	
	--Big if the check the collision with hearts
	if (collider.Type == EntityType.ENTITY_PLAYER and not Input.IsButtonPressed(Keyboard.KEY_ENTER, 0) ) then    --replacements are activated only if the PLAYER collides with a pickup (so two pickups that collide each other cannot activate the replacements)
	                                                                                                             --and if you are not pressing ENTER on the keyboard (<-- request by "Agitatio")
		
		--Special character for RED hearts check
		if REPENTANCE then 
			if playerType == PlayerType.PLAYER_BETHANY_B       --she converts red hearts in "blood charges"
			then
				SpecialCharacterForRedHeartsIsPresent = true
			else
				SpecialCharacterForRedHeartsIsPresent = false
			end	
		end
		
		
		--Special character for ALL hearts check 
		if (playerType == PlayerType.PLAYER_KEEPER)						  --he transforms all types of hearts into blue flies
		or (REPENTANCE and playerType == PlayerType.PLAYER_CAIN_B)        --he needs all the hearts for his "Bag of Crafting"
		or (REPENTANCE and playerType == PlayerType.PLAYER_KEEPER_B)      --he transforms all types of hearts into blue flies
		then       
			SpecialCharacterForAllHeartsIsPresent = true
		else
			SpecialCharacterForAllHeartsIsPresent = false
		end
		
		
		--Character The Lost or Tainted Lost check (for replacements from 3 to 8)
		if (playerType == PlayerType.PLAYER_THELOST)
		or (REPENTANCE and playerType == PlayerType.PLAYER_THELOST_B)
		then     
			TheLostOrTaintedLostIsPresent = true
		else
			TheLostOrTaintedLostIsPresent = false
		end	
		
		
		--ModMenuConfig characters check (these are characters that can be disabled from ModConfigMenu)
		if (playerType == PlayerType.PLAYER_XXX and ModSettings["blue_baby"] == false)                			--Blue Baby check with ModConfigMenu
		or (playerType == PlayerType.PLAYER_THELOST and ModSettings["the_lost"] == false)             			--The Lost check with ModConfigMenu
		or (REPENTANCE and playerType == PlayerType.PLAYER_XXX_B and ModSettings["tainted_blue_baby"] == false)	--Tainted Blue Baby check with ModConfigMenu
		or (REPENTANCE and playerType == PlayerType.PLAYER_THELOST_B and ModSettings["tainted_lost"] == false)	--Tainted Lost check with ModConfigMenu
		then
			ModMenuCharacterIsPresent = true
		else
			ModMenuCharacterIsPresent = false
		end
		
		
		--Special trinkets check (these are trinkets that works with red hearts)
		if REPENTANCE then		
			if player:HasTrinket(TrinketType.TRINKET_APPLE_OF_SODOM) then    --Apple of Sodom: Picking up a Red Heart has a 50% chance to consume the heart and spawn Blue Spiders
				SpecialTrinketIsPresent = true                               --^^^Has no effect on Rotten Hearts, Blended Hearts and any other type of heart.
			else                                                             --So, this trinkets should disable only replacements 1 & 2
				SpecialTrinketIsPresent = false
			end
		end
			
		
		--Special familiars check (these are familiars that works with RED hearts)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_BUM) then 	
			SpecialFamiliarIsPresent = true
		else
			SpecialFamiliarIsPresent = false
		end
			
		
		--Special collectibles check (these are items that work with RED hearts)
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_THE_JAR) and player:GetJarHearts() < 8)	--it stores up to 4 red hearts, 8 = 4 hearts
		or (REPENTANCE and player:HasCollectible(CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING))			--it needs red hearts for recipies
		then  
			SpecialItemIsPresent = true
		else
			SpecialItemIsPresent = false
		end
		
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------
		

		--1) RED hearts replacements at 0 heart CONTAINERS
		if player:GetMaxHearts() == 0 		               --GetMaxHearts() Returns the amount of Red Hearts the player can contain in their Heart Containers. 1 unit is half a red heart.
		and player:HasFullHearts() == true		           --equal to true if all red heart containers and bone hearts are full OR if you have 0 red heart containers and all bone hearts are full...  <- I put this line in order to disable this replacements if the player has 0 red heart containers BUT one or more empty bone hearts
		and ModSettings["type_1"] == true         		   --this type of replacements is not disabled by ModConfingMenu
		and SpecialFamiliarIsPresent == false      
		and SpecialCharacterForRedHeartsIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false
		and ModMenuCharacterIsPresent == false
		and SpecialTrinketIsPresent == false	
		and SpecialItemIsPresent == false	
		then  
			-----------------------------------------------------------------------------------------------------------
			if pickup.SubType == HeartSubType.HEART_HALF then 
			
				for key, array in pairs(half_red_heart_table) do 												--key = current key of the table (it indicates the type of replacement), array = object associated with the current key (an array with the probability intervals)
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
			-----------------------------------------------------------------------------------------------------------	
			elseif pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_SCARED then
				
				for key, array in pairs(full_red_heart_table) do 										
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
				
			-----------------------------------------------------------------------------------------------------------	
			elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
				
				for key, array in pairs(double_red_heart_table) do 										
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
				
			-----------------------------------------------------------------------------------------------------------				
			end
			
		end --end replacements 1
		
		
		
		--2) RED hearts replacements at max RED hearts
		if player:HasFullHearts() == true		               --equal to true if all red heart containers and bone hearts are full
		and ModSettings["type_2"] == true        			   --this type of replacements is not disabled by ModConfingMenu
		and player:GetMaxHearts() > 0    		               --to avoid the cases where you have 0 containers (because if you have 0 heart containers, you automatically have fullhearts)
		and SpecialFamiliarIsPresent == false      
		and SpecialCharacterForRedHeartsIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false
		and ModMenuCharacterIsPresent == false
		and SpecialTrinketIsPresent == false	
		and SpecialItemIsPresent == false 	then
			-----------------------------------------------------------------------------------------------------------
			if pickup.SubType == HeartSubType.HEART_HALF then 
				
				for key, array in pairs(half_red_heart_table) do 											
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
				
			-----------------------------------------------------------------------------------------------------------	
			elseif pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_SCARED then
				
				for key, array in pairs(full_red_heart_table) do 										
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
				
			-----------------------------------------------------------------------------------------------------------	
			elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
				
				for key, array in pairs(double_red_heart_table) do 										
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
				
			-----------------------------------------------------------------------------------------------------------		
			end
			
		end --end if max RED hearts
		
		
		
		--3) SOUL & BLENDED hearts replacements at max SOUL/BLACK hearts 
		if (player:CanPickSoulHearts() == false                     --remember to put in the same (  ) these 2 conditions!
		or TheLostOrTaintedLostIsPresent == true)		            --The Lost CAN pick up soul & black hearts but it does not use it, so he must do this conversion even if CanPickSoulHearts() == true             
		and ModSettings["type_3"] == true       			        --this type of replacements is not disabled by ModConfingMenu
		and SpecialItemIsPresent == false 	
		and ModMenuCharacterIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false
		then  
			-----------------------------------------------------------------------------------------------------------
			if pickup.SubType == HeartSubType.HEART_HALF_SOUL then
				
				for key, array in pairs(half_soul_heart_table) do 											
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
				
			-----------------------------------------------------------------------------------------------------------	
			elseif pickup.SubType == HeartSubType.HEART_SOUL then
				
				for key, array in pairs(soul_heart_table) do 											
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
				
			-----------------------------------------------------------------------------------------------------------
			elseif (pickup.SubType == HeartSubType.HEART_BLENDED and player:HasFullHearts() == true) then
																	--^^^without this, if you have 12 hearts (including) a BONE heart, it would fill the BONE heart and convert the blended heart              				           
				                        							--so, with this check, the BLENDED heart will be replaced only if all your BONE hearts are full (and you cannot take SOUL hearts).
				for key, array in pairs(blended_heart_table) do 											
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end	
				
			-----------------------------------------------------------------------------------------------------------
			end
			
		end --end of replacements 3
		
		

		--4) BLACK hearts replacements at max SOUL/BLACK hearts
		if (player:CanPickBlackHearts() == false                    --remember to put in the same (  ) these 2 conditions!
		or TheLostOrTaintedLostIsPresent == true) 		            --The Lost CAN pick up soul & black hearts but it does not use it, so he must do this conversion even if CanPickSoulHearts() == true
		and ModSettings["type_4"] == true            			    --this type of replacements is not disabled by ModConfingMenu
		and SpecialItemIsPresent == false		
		and ModMenuCharacterIsPresent == false 
		and SpecialCharacterForAllHeartsIsPresent == false
		then	
			-----------------------------------------------------------------------------------------------------------
			if pickup.SubType == HeartSubType.HEART_BLACK then
			
				for key, array in pairs(black_heart_table) do 											
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
				
			end
			
		end --end of replacments 4
		
		
		
		--5) ROTTEN hearts replacements at max ROTTEN hearts    
		if REPENTANCE then
			if (player:CanPickRottenHearts() == false					--remember to put in the same (  ) these 2 conditions!
			or TheLostOrTaintedLostIsPresent == true) 		            --The Lost CAN pick up ROTTEN hearts but it does not use it, so he must do this conversion 
			and ModSettings["type_5"] == true      				        --this type of replacements is not disabled by ModConfingMenu
			and SpecialItemIsPresent == false		
			and ModMenuCharacterIsPresent == false 
			and SpecialCharacterForAllHeartsIsPresent == false
			then	
				if pickup.SubType == HeartSubType.HEART_ROTTEN then
					
					for key, array in pairs(rotten_heart_table) do 											
						if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
							replaceHeart(key, pickup, player)
							return nil
						end
					end
					
				end	
			end
			
		end	--end of replacements 5
		
		
		
		--6) BONE hearts replacements at max BONE hearts      
		if (player:CanPickBoneHearts() == false			       --remember to put in the same (  ) these 2 conditions!
		or TheLostOrTaintedLostIsPresent == true) 		       --The Lost must do this conversion 	
		and ModSettings["type_6"] == true			           --this type of replacements is not disabled by ModConfingMenu     
		and SpecialItemIsPresent == false
		and ModMenuCharacterIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false	 	
		then	
			
			if pickup.SubType == HeartSubType.HEART_BONE then
				
				for key, array in pairs(bone_heart_table) do 											
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
				
			end
			
		end --end replacements 6
		
		
		
		--7) GOLDEN hearts replacements at max GOLDEN hearts     
		if (player:CanPickGoldenHearts() == false 			   --remember to put in the same (  ) these 3 conditions!
		or TheLostOrTaintedLostIsPresent == true) 		       --The Lost CAN pick up GOLDEN hearts but it does not use it, so he must do this conversion 
		and ModSettings["type_7"] == true     			       --this type of replacements is not disabled by ModConfingMenu    
		and SpecialItemIsPresent == false
		and ModMenuCharacterIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false	
		then	
			
			if pickup.SubType == HeartSubType.HEART_GOLDEN then
				
				for key, array in pairs(golden_heart_table) do 											
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
				
			end
			
		end --end replacements 7
		
		
		
		--8) ETERNAL hearts replacements at max CONTAINERS     
		if (player:GetMaxHearts() == 24    					   --24 = 12 hearts containers. Remember to put in the same (  ) these 3 conditions!
		or TheLostOrTaintedLostIsPresent == true) 		       --The Lost CAN pick up ETERNAL hearts but it does not use it, so he must do this conversion 
		and ModSettings["type_8"] == true       			   --this type of replacements is not disabled by ModConfingMenu   
		and SpecialItemIsPresent == false
		and ModMenuCharacterIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false	
		then	
			
			if pickup.SubType == HeartSubType.HEART_ETERNAL then
			
				for key, array in pairs(eternal_heart_table) do 											
					if randomNumb > array.prob_interval_start and randomNumb < array.prob_interval_end then
						replaceHeart(key, pickup, player)
						return nil
					end
				end
				
			end
			
		end --end replacements 8
	
	end --end off the collider if	
	
end --end of the main function

--Callback
Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Mod.replacementSelection, PickupVariant.PICKUP_HEART)
--^^^CallBack arguments: (callback type, function that will be activated, extra parameter for the callback)

--===============================================================================================================================

function replaceHeart(key, pickup, player)
		
	if 	key == "penny" then
		Mod:removePickupAndPlayEffects(pickup,player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pickup.Position, Vector(0,0), nil)
	elseif key == "double_penny" then
		Mod:removePickupAndPlayEffects(pickup,player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
	elseif key == "nickel" then
		Mod:removePickupAndPlayEffects(pickup,player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pickup.Position, Vector(0,0), nil)
	elseif key == "bomb" then
		Mod:removePickupAndPlayEffects(pickup,player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pickup.Position, Vector(0,0), nil)
	elseif key == "key" then
		Mod:removePickupAndPlayEffects(pickup,player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pickup.Position, Vector(0,0), nil)
	elseif key == "half_soul_heart" then
		Mod:removePickupAndPlayEffects(pickup,player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, pickup.Position, Vector(0,0), nil)
	elseif key == "black_heart" then
		Mod:removePickupAndPlayEffects(pickup,player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, pickup.Position, Vector(0,0), nil)
	elseif key == "blue_flies" then
		Mod:removePickupAndPlayEffects(pickup,player)
		player:AddBlueFlies(math.random(4), player.Position, nil)
	elseif key == "heart_explosion" then
		Mod:destroyPickupAndPlayEffects(pickup,player)
	end
	
	return nil

end

--===============================================================================================================================

function Mod:removePickupAndPlayEffects(pickup,player)

	SFX:Play(SoundEffect.SOUND_PLOP, 1, 0, false, 1, false)
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0,0), nil) --Entity Spawn ( int entityType, int entityVariant, int entitySubtype, Vector position, Vector velocity, Entity Spawner )
	pickup:Remove()
	
end -- end of the function

--===============================================================================================================================

function Mod:destroyPickupAndPlayEffects(pickup,player)

	SFX:Play(SoundEffect.SOUND_HEARTOUT, 1, 0, false, 1, false)
	
	-----------------------------------------------------------------------------------------------------------
	if pickup.SubType == HeartSubType.HEART_HALF 
		or pickup.SubType == HeartSubType.HEART_FULL 
		or pickup.SubType == HeartSubType.HEART_SCARED 
		or pickup.SubType == HeartSubType.HEART_DOUBLEPACK 
		then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, pickup.Position, Vector(0,0), player) --per gli altri cuori non ci sono effetti del genere
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, pickup.Position, Vector(0,0), player)
	-----------------------------------------------------------------------------------------------------------
	elseif pickup.SubType == HeartSubType.HEART_HALF_SOUL 
		or pickup.SubType == HeartSubType.HEART_SOUL 
		or pickup.SubType == HeartSubType.HEART_BLENDED 
		then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER, 0, pickup.Position, Vector(0,0), player)
	-----------------------------------------------------------------------------------------------------------			
	elseif pickup.SubType == HeartSubType.HEART_BLACK then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACK, 0, pickup.Position, Vector(0,0), player)
	-----------------------------------------------------------------------------------------------------------
	elseif pickup.SubType == HeartSubType.HEART_ROTTEN then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, pickup.Position, Vector(0,0), player)
	-----------------------------------------------------------------------------------------------------------
	elseif pickup.SubType == HeartSubType.HEART_BONE 
		or pickup.SubType == HeartSubType.HEART_ETERNAL then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_WHITE, 0, pickup.Position, Vector(0,0), player)
	-----------------------------------------------------------------------------------------------------------
	elseif pickup.SubType == HeartSubType.HEART_GOLDEN then 	
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_LEMON_MISHAP, 0, pickup.Position, Vector(0,0), player)
	
	end --end dei vari elseif
	
	pickup:Remove()
	
end -- end of the function

--===============================================================================================================================

--McM: settings modifications
if ModConfigMenu then 
	
	local ModName = "No Hearts LB"
	ModConfigMenu.UpdateCategory(ModName, {
		Info = {"Mod made by ZERBI-XCVII",}
	})
	
	----------------------------------------------
	
	--Add a text for next settings
	ModConfigMenu.AddText(ModName, "Settings", function() return "Replacements enabled for these characters?" end)
	
	--Setting for Blue Baby
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,	--> set the type of setting variable (boolean or number)
		
		CurrentSetting = function()
			return ModSettings["blue_baby"]   		--> select the variable from the ModSettings table
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["blue_baby"] then
				onOff = "True"
			end
			return 'Blue Baby: ' .. onOff		--> set the prhase you will see in the in-game McM
		end,
		
		OnChange = function(currentBool)
			ModSettings["blue_baby"] = currentBool			--> update the variable set through McM
		end,
		
		Info = {"Enable/Disable hearts replacements for this character."}	--> set the comment su will see in-gamne McM for the current setting
	})
	
	--Setting for Tainted Blue Baby
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["tainted_blue_baby"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["tainted_blue_baby"] then
				onOff = "True"
			end
			return 'Tainted Blue Baby: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["tainted_blue_baby"] = currentBool
		end,
		
		Info = {"Enable/Disable hearts replacements for this character."}
	})
	
	--Setting for The Lost
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["the_lost"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["the_lost"] then
				onOff = "True"
			end
			return 'The Lost: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["the_lost"] = currentBool
		end,
		
		Info = {"Enable/Disable hearts replacements for this character."}
	})
	
	--Setting for Tainted Lost
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["tainted_lost"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["tainted_lost"] then
				onOff = "True"
			end
			return 'Tainted Lost: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["tainted_lost"] = currentBool
		end,
		
		Info = {"Enable/Disable hearts replacements for this character."}
	})
	
	----------------------------------------------
	
	--Empty line
	ModConfigMenu.AddSpace(ModName, "Settings")
	
	--Add a text for next settings
	ModConfigMenu.AddText(ModName, "Settings", function() return "Types of replacements enabled:" end)
	
	--Setting for Type 1 replacement
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["type_1"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["type_1"] then
				onOff = "True"
			end
			return 'Type 1: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["type_1"] = currentBool
		end,
		
		Info = {"Enable/Disable RED hearts replacements at 0 hearts CONTAINERS."}
	})
	
	--Setting for Type 2 replacement
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["type_2"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["type_2"] then
				onOff = "True"
			end
			return 'Type 2: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["type_2"] = currentBool
		end,
		
		Info = {"Enable/Disable RED hearts replacements at max RED hearts."}
	})
	
	--Setting for Type 3 replacement
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["type_3"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["type_3"] then
				onOff = "True"
			end
			return 'Type 3: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["type_3"] = currentBool
		end,
		
		Info = {"Enable/Disable SOUL & BLENDED hearts replacements at max SOUL/BLACK hearts."}
	})
	
	--Setting for Type 4 replacement
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["type_4"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["type_4"] then
				onOff = "True"
			end
			return 'Type 4: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["type_4"] = currentBool
		end,
		
		Info = {"Enable/Disable BLACK hearts replacements at max BLACK hearts."}
	})
	
	--Setting for Type 5 replacement
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["type_5"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["type_5"] then
				onOff = "True"
			end
			return 'Type 5: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["type_5"] = currentBool
		end,
		
		Info = {"Enable/Disable ROTTEN hearts replacements at max ROTTEN hearts."}
	})
	
	--Setting for Type 6 replacement
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["type_6"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["type_6"] then
				onOff = "True"
			end
			return 'Type 6: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["type_6"] = currentBool
		end,
		
		Info = {"Enable/Disable BONE hearts replacements at max BONE hearts."}
	})
	
	--Setting for Type 7 replacement
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["type_7"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["type_7"] then
				onOff = "True"
			end
			return 'Type 7: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["type_7"] = currentBool
		end,
		
		Info = {"Enable/Disable GOLDEN hearts replacements at max GOLDEN hearts."}
	})
	
	--Setting for Type 8 replacement
	ModConfigMenu.AddSetting(ModName, "Settings", 
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		
		CurrentSetting = function()
			return ModSettings["type_8"]
		end,
		
		Display = function()
			local onOff = "False"
			if ModSettings["type_8"] then
				onOff = "True"
			end
			return 'Type 8: ' .. onOff
		end,
		
		OnChange = function(currentBool)
			ModSettings["type_8"] = currentBool
		end,
		
		Info = {"Enable/Disable ETERNAL hearts replacements at max CONTAINERS."}
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




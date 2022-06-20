NoUselessHeartsMod = RegisterMod("No Useless Hearts", 1) --update 20
--^^^this time there is no local xxxMod because it is shared with other .lua files

-- Lua API Documentation for Repentance:  https://moddingofisaac.com/docs/rep/
-- Lua API Documentation for Afterbirth+: https://moddingofisaac.com/docs/abp/
-- Wiki for The Binding Of Isaac Rebirth: https://bindingofisaacrebirth.fandom.com/wiki/Binding_of_Isaac:_Rebirth_Wiki

--[[
==============================================================================
UPDATE 20:
- better code 
  --> ho messo >= 90 al posto di > 90 su certe linee di codice
  --> ho messo dei return nil nel caso in cui il cuore venga distrutto (così esce subito senza fare gli altri if)
  --> ho reso le variabili locali (prima erano tutte globali)
- new probabilities for Half Red Heart (40% 1 moneta, 30% due monete <-- ricordarsi di cambiare l'immagine della tabella)
==============================================================================
COSE DA FARE
- risolvere il problema di certe player_creep che non si espandono bene... fanno tipo uno scatto
  questo accade in quella blu e gialla (quelle rosse, nere, bianche vanno bene).
==============================================================================
]]--

SFX = SFXManager()
SFX:Preload(SoundEffect.SOUND_PLOP)
SFX:Preload(SoundEffect.SOUND_HEARTOUT)

--Main function
function NoUselessHeartsMod:replaceHearts(pickup, collider, low)  --this function recive from the callback the entity of the pickup that has activated the callback
	
	--Variables
	local player = Isaac.GetPlayer(0)
	local SpecialFamiliarIsPresent = false
	local SpecialCharacterForRedHeartsIsPresent = false
	local SpecialCharacterForAllHeartsIsPresent = false
	local ModMenuCharacterIsPresent = false
	local TheLostOrTaintedLostIsPresent = false
	local SpecialTrinketIsPresent = false
	local SpecialItemIsPresent = false
	local randomNumb = math.random(100)   --this number will be used in the next replacements
	
	--Big if the check the collision with hearts
	if (collider.Type == EntityType.ENTITY_PLAYER and not Input.IsButtonPressed(Keyboard.KEY_ENTER, 0) ) then    --replacements are activated only if the PLAYER collides with a pickup (so two pickups that collide each other cannot activate the replacements)
	                                                                                                             --and if you are not pressing ENTER on the keyboard (<-- request by "Agitatio")
		--Special character for RED hearts check
		if REPENTANCE then 
			if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B       --she converts red hearts in "blood charges"
			then
				SpecialCharacterForRedHeartsIsPresent = true
			else
				SpecialCharacterForRedHeartsIsPresent = false
			end	
		end
		
		
		
		--Special character for ALL hearts check 
		if player:GetPlayerType() == PlayerType.PLAYER_KEEPER	then       --he transforms all types of hearts into blue flies
			SpecialCharacterForAllHeartsIsPresent = true
		else
			SpecialCharacterForAllHeartsIsPresent = false
		end
		
		if REPENTANCE then 
			if player:GetPlayerType() == PlayerType.PLAYER_CAIN_B          --he needs all the hearts for his "Bag of Crafting"
			or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B        --he transforms all types of hearts into blue flies
			then
				SpecialCharacterForAllHeartsIsPresent = true
			else
				SpecialCharacterForAllHeartsIsPresent = false
			end	
		end
		
		
		
		--Character The Lost or Tainted Lost check 
		if player:GetPlayerType() == PlayerType.PLAYER_THELOST	then       --he transforms all types of hearts into blue flies
			TheLostOrTaintedLostIsPresent = true
		else
			TheLostOrTaintedLostIsPresent = false
		end
		
		if REPENTANCE then 
			if player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
				TheLostOrTaintedLostIsPresent = true
			else
				TheLostOrTaintedLostIsPresent = false
			end	
		end
		
		
		
		--ModMenuConfig characters check (these are characters that can be disabled from ModConfigMenu)
		if (player:GetPlayerType() == PlayerType.PLAYER_XXX and NoUselessHeartsMod.Config["Blue Baby"] == false)                --Blue Baby check with ModConfigMenu
		or (player:GetPlayerType() == PlayerType.PLAYER_THELOST and NoUselessHeartsMod.Config["The Lost"] == false)             --The Lost check with ModConfigMenu
		then
			ModMenuCharacterIsPresent = true
		else
			ModMenuCharacterIsPresent = false
		end
		
		if REPENTANCE then
			if (player:GetPlayerType() == PlayerType.PLAYER_XXX_B and NoUselessHeartsMod.Config["Tainted Blue Baby"] == false)      --Tainted Blue Baby check with ModConfigMenu
			or (player:GetPlayerType() == PlayerType.PLAYER_THELOST_B and NoUselessHeartsMod.Config["Tainted Lost"] == false)       --Tainted Lost check with ModConfigMenu
			then
				ModMenuCharacterIsPresent = true
			else
				ModMenuCharacterIsPresent = false
			end
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
			
		
		
		--Special collectibles check (these are items that works with RED hearts)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_THE_JAR) then  --it stores up to 4 red hearts
			if player:GetJarHearts() < 8 then  --2 = 1 hearts -> 8 = 4 hearts  
				SpecialItemIsPresent = true
			else
				SpecialItemIsPresent = false
			end
		end
		
		if REPENTANCE then												
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING) then  --it needs red hearts for recipies
				SpecialItemIsPresent = true
			else
				SpecialItemIsPresent = false
			end
		end
			
		
		
		--1) RED hearts replacements at 0 heart CONTAINERS
		if player:GetMaxHearts() == 0 		               --GetMaxHearts() Returns the amount of Red Hearts the player can contain in their Heart Containers. 1 unit is half a red heart.
		and player:HasFullHearts() == true		           --equal to true if all red heart containers and bone hearts are full OR if you have 0 red heart containers and all bone hearts are full...  <- I put this line in order to disable this replacements if the player has 0 red heart containers BUT one or more empty bone hearts
		and NoUselessHeartsMod.Config["TYPE1"] == true     --this type of replacements is not disabled by ModConfingMenu
		and SpecialFamiliarIsPresent == false      
		and SpecialCharacterForRedHeartsIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false
		and ModMenuCharacterIsPresent == false
		and SpecialTrinketIsPresent == false	
		and SpecialItemIsPresent == false	
		then  
			-----------------------------------------------------------------------------------------------------------
			if pickup.SubType == HeartSubType.HEART_HALF then 
				
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end
				
				if  randomNumb < 40 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 70 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, pickup.Position, Vector(0,0), nil)
				end
				return nil
			-----------------------------------------------------------------------------------------------------------	
			elseif pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_SCARED then
				
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end
				
				if  randomNumb < 30 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 60 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, pickup.Position, Vector(0,0), nil)
				elseif  randomNumb < 70 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 80 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 85 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, pickup.Position, Vector(0,0), nil)
				end
				return nil
			-----------------------------------------------------------------------------------------------------------	
			elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
				
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end
				
				if  randomNumb < 20 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 40 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 60 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 80 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pickup.Position, Vector(0,0), nil)
				end
				return nil
				
			end
			
		end --end replacements 1
		
		
		
		--2) RED hearts replacements at max RED hearts
		if player:HasFullHearts() == true		               --equal to true if all red heart containers and bone hearts are full
		and NoUselessHeartsMod.Config["TYPE2"] == true         --this type of replacements is not disabled by ModConfingMenu
		and player:GetMaxHearts() > 0    		               --to avoid the cases where you have 0 containers (because if you have 0 heart containers, you automatically have fullhearts)
		and SpecialFamiliarIsPresent == false      
		and SpecialCharacterForRedHeartsIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false
		and ModMenuCharacterIsPresent == false
		and SpecialTrinketIsPresent == false	
		and SpecialItemIsPresent == false 	then
			-----------------------------------------------------------------------------------------------------------
			if pickup.SubType == HeartSubType.HEART_HALF then 
			
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end 
				
				if  randomNumb < 40 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 70 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, pickup.Position, Vector(0,0), nil)
				end
				return nil
			-----------------------------------------------------------------------------------------------------------	
			elseif pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_SCARED then
				
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end
				
				if   randomNumb < 30 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 60 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, pickup.Position, Vector(0,0), nil)
				elseif  randomNumb < 70 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 80 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 85 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, pickup.Position, Vector(0,0), nil)
				end
				return nil
			-----------------------------------------------------------------------------------------------------------	
			elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
				
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end
				
				if  randomNumb < 20 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 40 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 60 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 80 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pickup.Position, Vector(0,0), nil)
				end
				return nil
				
			end
			
		end --end if max RED hearts
		
		
		
		--3) SOUL & BLENDED hearts replacements at max SOUL/BLACK hearts 
		if (player:CanPickSoulHearts() == false                     --remember to put in the same (  ) these 2 conditions!
		or TheLostOrTaintedLostIsPresent == true)		            --The Lost CAN pick up soul & black hearts but it does not use it, so he must do this conversion even if CanPickSoulHearts() == true             
		and NoUselessHeartsMod.Config["TYPE3"] == true              --this type of replacements is not disabled by ModConfingMenu
		and SpecialItemIsPresent == false 	
		and ModMenuCharacterIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false
		then  
			-----------------------------------------------------------------------------------------------------------
			if pickup.SubType == HeartSubType.HEART_HALF_SOUL then
				
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end
			
				if  randomNumb < 45 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
				end
				return nil
			-----------------------------------------------------------------------------------------------------------	
			elseif pickup.SubType == HeartSubType.HEART_SOUL then
				
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end
				
				if  randomNumb < 20 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 30 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pickup.Position, Vector(0,0), nil)
				elseif  randomNumb < 60 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pickup.Position, Vector(0,0), nil)
				end
				return nil
			-----------------------------------------------------------------------------------------------------------
			elseif (pickup.SubType == HeartSubType.HEART_BLENDED and player:HasFullHearts() == true) then
																	--^^^without this, if you have 12 hearts (including) a BONE heart, it would fill the BONE heart and convert the blended heart              				           
				if randomNumb >= 90 then							--so, with this check, the BLENDED heart will be replaced only if all your BONE hearts are full (and you cannot take SOUL hearts).
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end	
				
				if  randomNumb < 20 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 30 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pickup.Position, Vector(0,0), nil)
				elseif  randomNumb < 60 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pickup.Position, Vector(0,0), nil)
				end
				return nil
				
			end
			
		end --end of replacements 3
		
		

		--4) BLACK hearts replacements at max SOUL/BLACK hearts
		if (player:CanPickBlackHearts() == false                    --remember to put in the same (  ) these 2 conditions!
		or TheLostOrTaintedLostIsPresent == true) 		            --The Lost CAN pick up soul & black hearts but it does not use it, so he must do this conversion even if CanPickSoulHearts() == true
		and NoUselessHeartsMod.Config["TYPE4"] == true              --this type of replacements is not disabled by ModConfingMenu
		and SpecialItemIsPresent == false		
		and ModMenuCharacterIsPresent == false 
		and SpecialCharacterForAllHeartsIsPresent == false
		then	
			-----------------------------------------------------------------------------------------------------------
			if pickup.SubType == HeartSubType.HEART_BLACK then
			
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end
				
				if  randomNumb < 20 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 30 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pickup.Position, Vector(0,0), nil)
				elseif  randomNumb < 60 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pickup.Position, Vector(0,0), nil)
				end
				return nil
			end
			
		end --end of replacments 4
		
		
		
		--5) ROTTEN hearts replacements at max ROTTEN hearts    
		if REPENTANCE then
			if (player:CanPickRottenHearts() == false					--remember to put in the same (  ) these 2 conditions!
			or TheLostOrTaintedLostIsPresent == true) 		            --The Lost CAN pick up ROTTEN hearts but it does not use it, so he must do this conversion 
			and NoUselessHeartsMod.Config["TYPE5"] == true              --this type of replacements is not disabled by ModConfingMenu
			and SpecialItemIsPresent == false		
			and ModMenuCharacterIsPresent == false 
			and SpecialCharacterForAllHeartsIsPresent == false
			then	
				if pickup.SubType == HeartSubType.HEART_ROTTEN then
					
					if randomNumb >= 90 then
						NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
						return nil
					else 
						NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
						player:AddBlueFlies(math.random(4), player.Position, nil)   --int number of flies, vector position, entity target. NOTE: math.random(4) gives a random number between 1 and 4 (not between 0 and 4)
					end
					return nil
				end	
			end
			
		end	--end of replacements 5
		
		
		
		--6) BONE hearts replacements at max BONE hearts      
		if (player:CanPickBoneHearts() == false			       --remember to put in the same (  ) these 2 conditions!
		or TheLostOrTaintedLostIsPresent == true) 		       --The Lost must do this conversion 	
		and NoUselessHeartsMod.Config["TYPE6"] == true         --this type of replacements is not disabled by ModConfingMenu     
		and SpecialItemIsPresent == false
		and ModMenuCharacterIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false	 	
		then	
			
			if pickup.SubType == HeartSubType.HEART_BONE then
				
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end
				
				if  randomNumb < 20 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 30 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pickup.Position, Vector(0,0), nil)
				elseif  randomNumb < 60 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pickup.Position, Vector(0,0), nil)
				end
				return nil
			end
			
		end --end replacements 6
		
		
		
		--7) GOLDEN hearts replacements at max GOLDEN hearts     
		if (player:CanPickGoldenHearts() == false 			   --remember to put in the same (  ) these 3 conditions!
		or TheLostOrTaintedLostIsPresent == true) 		       --The Lost CAN pick up GOLDEN hearts but it does not use it, so he must do this conversion 
		and NoUselessHeartsMod.Config["TYPE6"] == true         --this type of replacements is not disabled by ModConfingMenu    
		and SpecialItemIsPresent == false
		and ModMenuCharacterIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false	
		then	
			
			if pickup.SubType == HeartSubType.HEART_GOLDEN then
				
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end
				
				if  randomNumb < 20 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 30 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pickup.Position, Vector(0,0), nil)
				elseif  randomNumb < 60 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pickup.Position, Vector(0,0), nil)
				end
				return nil
			end
			
		end --end replacements 7
		
		
		
		--8) ETERNAL hearts replacements at max CONTAINERS     
		if (player:GetMaxHearts() == 24    					   --24 = 12 hearts containers. Remember to put in the same (  ) these 3 conditions!
		or TheLostOrTaintedLostIsPresent == true) 		       --The Lost CAN pick up ETERNAL hearts but it does not use it, so he must do this conversion 
		and NoUselessHeartsMod.Config["TYPE7"] == true         --this type of replacements is not disabled by ModConfingMenu   
		and SpecialItemIsPresent == false
		and ModMenuCharacterIsPresent == false
		and SpecialCharacterForAllHeartsIsPresent == false	
		then	
			
			if pickup.SubType == HeartSubType.HEART_ETERNAL then
			
				if randomNumb >= 90 then
					NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)
					return nil
				else 
					NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)
				end
				
				if  randomNumb < 20 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 30 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pickup.Position, Vector(0,0), nil)
				elseif  randomNumb < 60 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pickup.Position, Vector(0,0), nil)
				elseif randomNumb < 90 then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, pickup.Position, Vector(0,0), nil)
				end
				return nil
			end
			
		end --end replacements 8
	
	end --end off the collider if	
	
end --end of the main function

--Callback
NoUselessHeartsMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, NoUselessHeartsMod.replaceHearts, PickupVariant.PICKUP_HEART)
--^^^CallBack arguments: (callback type, function that will be activated, extra parameter for the callback)


----------------------------------------------------------------------------------------------------------------------------------
function NoUselessHeartsMod:removePickupAndPlayEffects(pickup,player)

	SFX:Play(SoundEffect.SOUND_PLOP, 1, 0, false, 1, false)
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0,0), nil) --Entity Spawn ( int entityType, int entityVariant, int entitySubtype, Vector position, Vector velocity, Entity Spawner )
	pickup:Remove()
	
end -- end of the function
----------------------------------------------------------------------------------------------------------------------------------
function NoUselessHeartsMod:destroyPickupAndPlayEffects(pickup,player)

	SFX:Play(SoundEffect.SOUND_HEARTOUT, 1, 0, false, 1, false)
	
	-----------------------------------------------------------------------------------------------------------
	if pickup.SubType == HeartSubType.HEART_HALF 
	or pickup.SubType == HeartSubType.HEART_FULL 
	or pickup.SubType == HeartSubType.HEART_SCARED 
	or pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, pickup.Position, Vector(0,0), player) --per gli altri cuori non ci sono effetti del genere
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, pickup.Position, Vector(0,0), player)
	-----------------------------------------------------------------------------------------------------------
	elseif pickup.SubType == HeartSubType.HEART_HALF_SOUL 
		or pickup.SubType == HeartSubType.HEART_SOUL 
		or pickup.SubType == HeartSubType.HEART_BLENDED then
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
----------------------------------------------------------------------------------------------------------------------------------

--ModConfigMenu
require("NoUselessHearts_config")
NoUselessHeartsMod.Config = NoUselessHeartsMod.DefaultConfig
NoUselessHeartsMod.Config.Version = "1.0"

require("NoUselessHearts_mod_config_menu")

-- only save and load configs when using MCM. Otherwise Config file changes arent valid
if ModConfigMenu then
	local json = require("json")
	--------------------------------
	--------Handle Savadata---------
	--------------------------------
	function OnGameStart(isSave)
		--Loading Moddata--
		if NoUselessHeartsMod:HasData() then
			local savedMcmTestConfig = json.decode(Isaac.LoadModData(NoUselessHeartsMod))
			-- Only copy Saved config entries that exist in the save
			if savedMcmTestConfig.Version == NoUselessHeartsMod.Config.Version then
				for key, value in pairs(NoUselessHeartsMod.Config) do
					if savedMcmTestConfig[key] ~= nil then
						NoUselessHeartsMod.Config[key] = savedMcmTestConfig[key]
					end
				end
			end
		end
	end
	NoUselessHeartsMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, OnGameStart)

	--Saving Moddata--
	function SaveGame()
		NoUselessHeartsMod.SaveData(NoUselessHeartsMod, json.encode(NoUselessHeartsMod.Config))
	end
	NoUselessHeartsMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveGame)
end
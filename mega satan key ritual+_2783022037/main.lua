local Mod = RegisterMod("Mega Satan Key Ritual+", 1)

-- Lua API Documentation for Repentance:  https://moddingofisaac.com/docs/rep/
-- Lua API Documentation for Afterbirth+: https://moddingofisaac.com/docs/abp/				 

local totalDamageBonus = 0    						--> this variable is used by the functions "removeThings()" & "cacheUpdate()" (always put shared variables on top)

function Mod:spawnSpike()  							--> this function is called at the beginning of each floor
	
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	
	--Controllo che sia la Dark Room
	if (       room:GetRoomConfigStage() == 16 --RoomConfigStage 16 == Dark Room        --> Dark Room, Chest
		and    Mod:checkItemsFromAngelPool(player) == false	--spikes disabled if you have an Angel item
		and (  player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) == false  -- gli devono mancare uno o più pezzi della chiave
		or	   player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) == false) ) 
	then
		--Spawn spike and statues
		room:SpawnGridEntity(42, GridEntityType.GRID_SPIKES_ONOFF, 0, 0, 1) --> (GridIndex, Type, Variant, Seed, VarData) per vedere l'index del pavimento scrivere "debug 11" nella console debug in-game
											--  
		room:SpawnGridEntity(27, GridEntityType.GRID_STATUE, 0, 0, 1) --statua
	end
	
	return nil
	
end


function Mod:checkItemsFromAngelPool(player)		--> this function is called by "Mod:spawnSpike()"
	
	--Item pool wiki: https://bindingofisaacrebirth.fandom.com/wiki/Angel_Room_(Item_Pool)
		
	local listOfAngelItems = {	 33, 124, 146, 326, 477, 490, 510, 622, 640, 653, 685,
								  7,  72,  98, 101, 108, 112, 138, 142, 156, 162, 173,
								178, 182, 184, 185, 243, 313, 331, 332, 333, 334, 335, 
								363, 374, 387, 390, 400, 413, 415, 423, 464, 498, 499,
								519, 526, 528, 533, 543, 567, 568, 573, 574, 579, 584,
								586, 601, 634, 643, 651, 686, 691, 696}
	
	for i=1, #listOfAngelItems do					--> for inizio, fine, incremento --> in questo caso asbbiamo che:
																				     --> inizio: i=1 <-- because Lua tables start at 1.
		local item = listOfAngelItems[i] 										     --> fine: #listOfAngelItems <-- il # resituisce la lunghezza dell'array/table "listOfAngelItems"
		if player:HasCollectible(item, true) then                                    --> step: quando non viene messo si sottointende 1. 
			return true 	--angel item found
		end	
		
	end
	
	return false 			--no angel item found
	
end


--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function Mod:startMegaSatanKeyRitual(TookDamage, DamageAmount, DamageFlags, DamageSource, DamageCountdownFrames) --this mod is called when you take damage
	
	local player = Isaac.GetPlayer(0)
	local level = Game():GetLevel()
	local room = Game():GetRoom()
	
	--If principale per far partire il tutto
	if (	DamageFlags == DamageFlag.DAMAGE_SPIKES 		              	--> damage from spike
		and level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()   	--> first room of the floor
		and room:GetRoomConfigStage() == 16   ) 						 	--> RoomConfigStage 16 == Dark Room
		then                            
		
		--Rimozione containers, monete, chiavi, bombe + attribuzione bonus	
		Mod:removeThings(player)
		
		--Qualche effetto sonoro/grafico
		Mod:visualEffects(player, room)
		
		--Spawn (on the floor) 1 black hearts every 2 Devil items possessed
		local countOfDevilItemsOwned = Mod:checkItemsFromDevilPool(player)
		local numberOfBlackHeartsToSpawn = countOfDevilItemsOwned
		if numberOfBlackHeartsToSpawn > 5 then
			numberOfBlackHeartsToSpawn = 5 		--limit the max number of black hearts to be spawned
		end
		local internalStep = 0  	--questa variabile mi serve dentro il ciclo for per spostare lo spawn di 40 ogni volta
		for i=1, numberOfBlackHeartsToSpawn do                         
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, Vector(320,160+internalStep), Vector(0,0), nil)   --ce ne stanno max 7 sul pavimento lungo l'asse Y
			internalStep = internalStep + 40
		end
		
		--Spawn di 2 black hearts nel caso si avesse già un pezzo della chiave
		if (	player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) 
		or 		player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2)	)
		then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, Vector(280,280), Vector(0,0), nil)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, Vector(360,280), Vector(0,0), nil)
		end
		
		--Spawn dei due pezzi della chiave (o di quello che gli manca)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) == false then 
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KEY_PIECE_1, Vector(240,160), Vector(0,0), player)
		end
		
		if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) == false then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KEY_PIECE_2, Vector(400,160), Vector(0,0), player)
		end
		
	end
	
	return true --Return true or nil if the entity or player should sustain the damage, otherwise false to ignore it.
	
end


function Mod:removeThings(player) 					--> this function is called by the function "startMegaSatanKeyRitual()"
	
	local oneHeartBonus = 0.50      --> modify this values in order to change the bonus for each scrified things
	local oneCoinBonus  = 0.01		--
	local oneKeyBonus   = 0.05		--
	local oneBombBonus  = 0.05		--
	
	--Remove all RED hearts
	local currentRedHearts = player:GetHearts()			    --2=1 heart, 1=half heart	
	player:AddHearts(-currentRedHearts)					
	local sacrifiedRedHearts = (currentRedHearts-2)/2
	if sacrifiedRedHearts < 0 then 		--for the case where the character does not have red hearts
		sacrifiedRedHearts = 0 
	end
	totalDamageBonus = totalDamageBonus + (sacrifiedRedHearts*oneHeartBonus)
		
	--Remove SOUL and BLACK hearts
	local currentSoulHearts = player:GetSoulHearts()	--2=1soul heart. 1=half soul heart  <-- this function count SOUL and BLACK hearts at the same time
	player:AddSoulHearts(-currentSoulHearts)											     --^^^GetBlackHearts() is for another thing, NOT for counting black hearts
	totalDamageBonus = totalDamageBonus + (currentSoulHearts/2*oneHeartBonus)
		
	--Remove BONE hearts
	local currentBoneHearts = player:GetBoneHearts()		--1=1 bone heart
	player:AddBoneHearts(-currentBoneHearts)
	totalDamageBonus = totalDamageBonus + (currentBoneHearts*oneHeartBonus)
	
	--Remove ROTTEN hearts
	if REPENTANCE then
		local currentRottenHearts = player:GetRottenHearts()
		player:AddRottenHearts(-currentRottenHearts)
		totalDamageBonus = totalDamageBonus + (currentRottenHearts*oneHeartBonus)
	end
	
	--Remove GOLDEN hearts
	local currentGoldenHearts = player:GetGoldenHearts()	--1=1 hearts
	player:AddGoldenHearts(-currentGoldenHearts) 			
	totalDamageBonus = totalDamageBonus + (currentGoldenHearts*5*oneCoinBonus)   --each golden heart is worth something like 5 coins
	
	--Remove coins
	local currentCoins = player:GetNumCoins()
	player:AddCoins(-currentCoins)
	totalDamageBonus = totalDamageBonus + (currentCoins*oneCoinBonus)
	
	--Remove keys
	local currentKeys = player:GetNumKeys()
	player:AddKeys(-currentKeys)
	totalDamageBonus = totalDamageBonus + (currentKeys*oneKeyBonus)
	
	--Remove bombs
	local currentBombs = player:GetNumBombs()
	player:AddBombs(-currentBombs)
	totalDamageBonus = totalDamageBonus + (currentBombs*oneBombBonus)
	if totalDamageBonus > 10 then	--limit max total bonus
		totalDamageBonus = 10
	end
	
	--Add hearts to avoid killing characters (in this moment the character does not have any types of hearts)
	local numHealthContainers = player:GetMaxHearts()/2 	--2=1 healt container
	if numHealthContainers == 0 then				
		player:AddBlackHearts(2)	--if your character has 0 health containers -> I add a black heart
		player:AddSoulHearts(2)		--I also add a soul heart that will be immediately lost due to spike damage 
	elseif numHealthContainers == 1	then 		
		player:AddHearts(2)			--add 1 red heart
		player:AddSoulHearts(2)		--for the spike damage
	elseif numHealthContainers > 1 then 		
		player:AddHearts(4) 		--add 2 red hearts (1 will be lost due to spike damage)
	end
	
	--Saving the player's stats changes (damage bonus in this case)
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)	--> this flag indicate what I am going to update
	player:EvaluateItems()      					--> Trigger of a cache reevaluation --> Will trigger the MC_EVALUATE_CACHE callback                        
	
	return nil
	
end


function Mod:checkItemsFromDevilPool(player)		--> this funxtion is called by "Mod:removeThings()"

	--Item pool wiki: https://bindingofisaacrebirth.fandom.com/wiki/Devil_Room_(Item_Pool)?so=search
	
	local listOfDevilItems = {	123, 126, 127, 133, 145, 186, 292,  34,  35, 441, 475, 477,
								536, 545, 556, 577, 704, 705, 706, 712, 728,  83,  84,  97,
								109, 113, 114, 115, 118, 122, 134, 157, 159, 163, 172, 187,
								212, 215, 216, 225, 230, 237, 241, 259, 262, 268, 269, 275,
								278, 311, 360, 391, 399, 408, 409, 411, 412, 417, 420, 431,
								433, 442, 462, 468, 498, 503,  51, 519, 526, 530, 554, 569, 
								572, 606, 634, 646, 654, 665,  67, 672, 679, 684, 692, 694,
								695, 698, 699, 702,  74,  79,   8,  80,  81,  82}
								
	local countOfDevilItemsOwned = 0
	
	for i=1, #listOfDevilItems do			
																				   
		local item = listOfDevilItems[i] 										   
		if player:HasCollectible(item) then                                   
			countOfDevilItemsOwned = countOfDevilItemsOwned + 1
		end	
		
	end
	
	return countOfDevilItemsOwned

end


function Mod:visualEffects(player, room)			--> this function is called by the function "startMegaSatanKeyRitual()"
	
	--Punti del pavimento
	--alle cooardinate (x,y)=(320,280) siamo al centro del pavimento
	--la coordinata (40,120) si trova in alto a sx dello schermo (vedi la foto)
	--scendendo verso il basso dello schermo la coordinata y aumenta
	--andando verso dx dello schermo la coordinata x aumenta
	
	local num = 0
	local inizio = 0
	local fine = 0
	local step = 40 					--a quanto pare ogni cella della grid (quella che si vede con debug 11) si approssima bene con una dimensione (40,40)
	local centreX = 320					--centro del pavimento coordinata x
	local centreY = 280              	--centro del pavimento coordinata y
	local MAX_UP = centreY-step*3    	--punto più alto della barra verticale della croce. Cambiando il valore 5 posso allargare la croce.
	local MAX_DOWN = centreY+step*1		--punto più basso della barra verticale della croce
	local MAX_SX = centreX-step*1		--punto più alto della barra verticale della croce. Cambiando il valore 5 posso allungare la croce.
	local MAX_DX = centreX+step*1		--punto più alto della barra verticale della croce
	
	local SFX = SFXManager()
	
	--Game effects
	Game():ShakeScreen(100)						--(int Timeout)
		
	--Suoni e sangue
	SFX:Play(SoundEffect.SOUND_SATAN_GROW, 1, 0, false, 1, false)
	room:EmitBloodFromWalls(3, 5) --(Duration, Count)
	SFX:Play(SoundEffect.SOUND_HEARTOUT, 1, 0, false, 1, false)
	
	--Ciclo for per fare la sbarra verticale della croce sul pavimento
	inizio = MAX_UP
	fine = MAX_DOWN
	for num=inizio,fine,step do 
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, Vector(centreX,num), Vector(0,0), player) --( int entityType, int entityVariant, int entitySubtype, Vector position, Vector velocity, Entity Spawner ) --> (320,280) è il centro della stanza
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, Vector(centreX,num), Vector(0,0), player) --> abbassa le performance
	end
	
	--Ciclo for per fare la sbarra orizzontale della croce sul pavimento
	inizio = MAX_SX
	fine = MAX_DX
	for num=inizio,fine,step do 
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, Vector(num,centreY), Vector(0,0), player)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, Vector(num,centreY), Vector(0,0), player) --> abbassa le performance
	end
	
	--Remove spike	
	room:RemoveGridEntity(42, 0, false) --( int GridIndex, int PathTrail, boolean KeepDecoration )
	
	return nil
	
end


function Mod:cacheUpdate(player, flag) 				--> this function is called by Mod:removeThings()

	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + totalDamageBonus
	end
	
	return nil
	
end


--Callback
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Mod.spawnSpike)
Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.startMegaSatanKeyRitual, EntityType.ENTITY_PLAYER) -- mettendo "EntityType.ENTITY_PLAYER" il callback verrà attivato solamente quando è il giocatore a ricevere danno
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.cacheUpdate)
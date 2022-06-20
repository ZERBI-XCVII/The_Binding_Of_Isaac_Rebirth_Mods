local Mod = RegisterMod("Mega Satan Key Ritual", 1)

-- Lua API Documentation for Repentance:  https://moddingofisaac.com/docs/rep/
-- Lua API Documentation for Afterbirth+: https://moddingofisaac.com/docs/abp/				 

function Mod:tryToSpawnSpike()					--funzione chiamata da ModCallbacks.MC_POST_NEW_ROOM
	
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local level = Game():GetLevel()
	
	--Little if in order to avoid checking the stage if I am not in the first room
	if Mod:checkFirstRoomOfTheFloor(level) == false then
		return nil
	end
		
	--Spawn the spike and other things
	if  (player:GetNumKeys() >= 20 					--deve avere almeno 20 chiavi
		and Mod:needKeyPiece(player)  				--gli devono mancare uno o più pezzi della chiave 
		and Mod:stageVietato(level) == false		--non deve essere su uno stage vietato
		and Mod:checkItemsFromAngelPool(player)	== false) then 		--non deve avere oggetti di angeli

		--Spawn spike and statues
		room:SpawnGridEntity(37, GridEntityType.GRID_SPIKES_ONOFF, 0, 0, 1) --> (GridIndex, Type, Variant, Seed, VarData) per vedere l'index del pavimento scrivere "debug 11" nella console debug in-game
											--               ^^^ for some reasons normal spikes don't work
		room:SpawnGridEntity(18, GridEntityType.GRID_STATUE, 0, 0, 1) --statua a sx
		room:SpawnGridEntity(26, GridEntityType.GRID_STATUE, 0, 0, 1) --statua a dx
		
		--Spawn piccola croce di fuoco a sx
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(160,240), Vector(0,0), player)
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(160,280), Vector(0,0), player)
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(160,320), Vector(0,0), player)
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(160,360), Vector(0,0), player)
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(120,320), Vector(0,0), player)
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(200,320), Vector(0,0), player)
		
		--Spawn piccola croce di fuoco a dx
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(480,240), Vector(0,0), player)
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(480,280), Vector(0,0), player)
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(480,320), Vector(0,0), player)
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(480,360), Vector(0,0), player)
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(440,320), Vector(0,0), player)
		Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 0, 0, Vector(520,320), Vector(0,0), player)
		
    end
	
	return nil
	
end


function Mod:checkFirstRoomOfTheFloor(level) 	--funzione chiamata da Mod:tryToSpawnSpike() e da Mod:startMegaSatanKeyRitual()
		
	local currentRoomIndex = level:GetCurrentRoomIndex()
	local startingRoomIndex = level:GetStartingRoomIndex()
	
	if currentRoomIndex == startingRoomIndex then
		return true
	else
		return false
	end 

end


function Mod:needKeyPiece(player)				--funzione chiamata da Mod:tryToSpawnSpike()
	
	if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) == false
	or player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) == false
	then
		return true		--gli manca un pezzo
	else
		return false	--ha entrambi i pezzi
	end
	
end


function Mod:stageVietato(level)				--funzione chiamata da Mod:tryToSpawnSpike()
	
	local currentStage = level:GetStage()
	
	if  (   currentStage == LevelStage.STAGE4_3      --> Blue Womb (Hush)
		or  currentStage == LevelStage.STAGE6        --> Dark Room, Chest
		or  currentStage == LevelStage.STAGE7        --> The Void
		or  currentStage == LevelStage.STAGE8        --> Home
		or  Game():IsGreedMode() == true ) 
	then
		return true --se questa variabile è vera allora NON devo spawnare gli spike
	else
		return false
	end
	
end


function Mod:checkItemsFromAngelPool(player)	--funzione chiamata da Mod:tryToSpawnSpike()
	
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


--/////////////////////////////////////////////////////////////////////////////////////////////////////////////


function Mod:startMegaSatanKeyRitual(TookDamage, DamageAmount, DamageFlags, DamageSource, DamageCountdownFrames) 		--> funzione chiamata da ModCallbacks.MC_ENTITY_TAKE_DMG

	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local level = Game():GetLevel()	
	
	--If principale per far partire il tutto
	if (DamageFlags == DamageFlag.DAMAGE_SPIKES 		--il danno deve essere ricevuto dagli spike
		and player:GetNumKeys() >= 20					--bisogna avere almeno 20 chiavi
		and Mod:checkFirstRoomOfTheFloor(level)			--bisogna essere nella prima stanza del piano
		and Game():IsGreedMode() == false ) then		--non bisogna essere in greed mode
	
		--Rimozione di cuori, monete, chiavi, bombe
		Mod:removeThings(player)
		
		--Qualche effetto sonoro/grafico
		Mod:visualEffects(player, room)
		
		--Spawn dei due pezzi della chiave (o di quello che gli manca)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) == false then 
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KEY_PIECE_1, Vector(160,320), Vector(0,0), player)
		else	--se ha già il pezzo spawna un black heart tanto per dare qualcosa
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, Vector(160,320), Vector(0,0), nil)
		end
		
		if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) == false then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KEY_PIECE_2, Vector(480,320), Vector(0,0), player)
		else
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, Vector(480,320), Vector(0,0), nil)
		end
		
	end
	--[[
	--If per rimuovere il danno dai fuochi
	if (DamageFlags == DamageFlag.DAMAGE_FIRE
		and player:GetNumKeys() >= 20					--bisogna avere almeno 20 chiavi
		and Mod:checkFirstRoomOfTheFloor(level)			--bisogna essere nella prima stanza del piano
		and Game():IsGreedMode() == false ) then		--non bisogna essere in greed mode
		
		return false --no damage from fires in the first room
	end	
	]]--
	return nil --Return true or nil if the entity or player should sustain the damage, otherwise false to ignore it.
	
end


function Mod:removeThings(player) 					--this mod is called by the function "startMegaSatanKeyRitual()"
	
	--Remove all RED hearts
	local currentRedHearts = player:GetHearts()			    --2=1 heart, 1=half heart)		
	player:AddHearts(-currentRedHearts)					
	
	--Remove SOUL and BLACK hearts
	local currentSoulHearts = player:GetSoulHearts()	--2=1soul heart. 1=half soul heart  <-- this function count SOUL and BLACK hearts at the same time
	player:AddSoulHearts(-currentSoulHearts)											     --^^^GetBlackHearts() is for another thing, NOT for counting black hearts
		
	--Remove BONE hearts
	local currentBoneHearts = player:GetBoneHearts()		--1=1 bone heart
	player:AddBoneHearts(-currentBoneHearts)
	
	--Remove ROTTEN hearts
	if REPENTANCE then
		local currentRottenHearts = player:GetRottenHearts()
		player:AddRottenHearts(-currentRottenHearts)
	end
	
	--Remove GOLDEN hearts
	local currentGoldenHearts = player:GetGoldenHearts()	--1=1 hearts
	player:AddGoldenHearts(-currentGoldenHearts) 			
	
	--Remove coins
	local currentCoins = player:GetNumCoins()
	player:AddCoins(-currentCoins)
	
	--Remove keys
	local currentKeys = player:GetNumKeys()
	player:AddKeys(-currentKeys)
	
	--Remove bombs
	local currentBombs = player:GetNumBombs()
	player:AddBombs(-currentBombs)

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
	
	return nil
	
end


function Mod:visualEffects(player, room)			--this mod is called by the function "startMegaSatanKeyRitual()"
	
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
		local MAX_UP = centreY-step*2    	--punto più alto della barra verticale della croce. Cambiando il valore 5 posso allargare la croce.
		local MAX_DOWN = centreY+step*2		--punto più basso della barra verticale della croce
		local MAX_SX = centreX-step*1		--punto più alto della barra verticale della croce. Cambiando il valore 5 posso allungare la croce.
		local MAX_DX = centreX+step*1		--punto più alto della barra verticale della croce
		
		local SFX = SFXManager()
		
		--Game effects
		Game():ShakeScreen(100)										--(int Timeout)
		if REPENTANCE then
			Game():ShowHallucination(30, BackdropType.DARKROOM)		--(int FrameCount, Backdrop)
		end
		
		--Qualche effetto sonoro
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
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, Vector(num,centreY+step*1), Vector(0,0), player)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, Vector(num,centreY+step*1), Vector(0,0), player) --> abbassa le performance
		end
		
		--Remove spike	
		room:RemoveGridEntity(37, 0, false) --( int GridIndex, int PathTrail, boolean KeepDecoration )
		
		return nil
	
end



--Callback
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.tryToSpawnSpike)
Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.startMegaSatanKeyRitual, EntityType.ENTITY_PLAYER) -- mettendo "EntityType.ENTITY_PLAYER" il callback verrà attivato solamente quando è il giocatore a ricevere danno

if ModConfigMenu then

	--Characters selections
	ModConfigMenu.AddText("No Hearts LB", "Settings", function() return "Mod enabled for:" end) --first line
	
	--Setting for Blue Baby
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["Blue Baby"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["Blue Baby"] then
					onOff = "True"
				end
				return 'Blue Baby: ' .. onOff
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["Blue Baby"] = currentBool
			end
		}
	)
	
	--Setting for Tainted Blue Baby
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["Tainted Blue Baby"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["Tainted Blue Baby"] then
					onOff = "True"
				end
				return 'Tainted Blue Baby: ' .. onOff
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["Tainted Blue Baby"] = currentBool
			end
		}
	)
	
	--Setting for The Lost
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["The Lost"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["The Lost"] then
					onOff = "True"
				end
				return 'The Lost: ' .. onOff
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["The Lost"] = currentBool
			end
		}
	)
	
	--Setting for Tainted Lost
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["Tainted Lost"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["Tainted Lost"] then --this is the string that contains the boolean state (I think...)
					onOff = "True"
				end
				return 'Tainted Lost: ' .. onOff  --this is what you see in the ModMenu (I think...)
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["Tainted Lost"] = currentBool
			end
		}
	)
	
	--Types of replacements selections
	ModConfigMenu.AddText("No Hearts LB", "Settings", function() return " " end) --empty line in the ModConfigMenu
	ModConfigMenu.AddText("No Hearts LB", "Settings", function() return "Types of hearts replacements:" end) 
	
	--Setting for replacements type 1 (RED hearts replacements at 0 hearts CONTAINERS)
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["TYPE1"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["TYPE1"] then --this is the string that contains the boolean state (I think...)
					onOff = "True"
				end
				return 'RED at 0 CONTAINERS: ' .. onOff  --this is what you see in the ModMenu (I think...)
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["TYPE1"] = currentBool
			end
		}
	)
	
	--Setting for replacements type 2 (RED hearts replacements at max RED hearts)
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["TYPE2"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["TYPE2"] then --this is the string that contains the boolean state (I think...)
					onOff = "True"
				end
				return 'RED at MAX RED: ' .. onOff  --this is what you see in the ModMenu (I think...)
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["TYPE2"] = currentBool
			end
		}
	)
	
	--Setting for replacements type 3 (SOUL & BLENDED hearts replacements at max SOUL/BLACK hearts)
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["TYPE3"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["TYPE3"] then --this is the string that contains the boolean state (I think...)
					onOff = "True"
				end
				return 'SOUL & BLENDED hearts: ' .. onOff  --this is what you see in the ModMenu (I think...)
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["TYPE3"] = currentBool
			end
		}
	)
	
	--Setting for replacements type 4 (BLACK hearts replacements at max SOUL/BLACK hearts)
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["TYPE4"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["TYPE4"] then --this is the string that contains the boolean state (I think...)
					onOff = "True"
				end
				return 'BLACK hearts: ' .. onOff  --this is what you see in the ModMenu (I think...)
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["TYPE4"] = currentBool
			end
		}
	)
	
	--Setting for replacements type 5 (ROTTEN hearts replacements at max ROTTEN hearts)
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["TYPE5"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["TYPE5"] then --this is the string that contains the boolean state (I think...)
					onOff = "True"
				end
				return 'ROTTEN hearts: ' .. onOff  --this is what you see in the ModMenu (I think...)
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["TYPE5"] = currentBool
			end
		}
	)
	
	--Setting for replacements type 6 (BONE hearts replacements at max BONE hearts)
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["TYPE6"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["TYPE6"] then --this is the string that contains the boolean state (I think...)
					onOff = "True"
				end
				return 'BONE hearts: ' .. onOff  --this is what you see in the ModMenu (I think...)
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["TYPE6"] = currentBool
			end
		}
	)
	
	--Setting for replacements type 7 (GOLDEN hearts replacements at max GOLDEN hearts)
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["TYPE7"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["TYPE7"] then --this is the string that contains the boolean state (I think...)
					onOff = "True"
				end
				return 'GOLDEN hearts: ' .. onOff  --this is what you see in the ModMenu (I think...)
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["TYPE7"] = currentBool
			end
		}
	)
	
	--Setting for replacements type 8 (ETERNAL hearts replacements at max CONTAINERS)
	ModConfigMenu.AddSetting(
		"No Hearts LB",
		"Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return NoUselessHeartsMod.Config["TYPE8"]
			end,
			Display = function()
				local onOff = "False"
				if NoUselessHeartsMod.Config["TYPE8"] then --this is the string that contains the boolean state (I think...)
					onOff = "True"
				end
				return 'ETERNAL hearts: ' .. onOff  --this is what you see in the ModMenu (I think...)
			end,
			OnChange = function(currentBool)
				NoUselessHeartsMod.Config["TYPE8"] = currentBool
			end
		}
	)
	
end
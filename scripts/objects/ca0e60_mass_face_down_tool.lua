--DXHHH101

function onload(saved_data)

	if saved_data ~= "" then
		local loaded_data = JSON.decode(saved_data)
	end

	
	self.createButton({
        click_function = "massMorph",
        function_owner = self,
        label = "Morph",
        position = {-1.1, 0.06, -1.2},
        width = 1000, height = 300,
        font_size = 160, color = {0, 0, 0, 0.9}, font_color = {1, 1, 1, 1}
    })
	
	self.createButton({
        click_function = "massManifest",
        function_owner = self,
        label = "Manifest",
        position = {1.1, 0.06, -1.2},
        width = 1000, height = 300,
        font_size = 160, color = {0, 0, 0, 0.9}, font_color = {1, 1, 1, 1}
    })
	
	self.createButton({
        click_function = "massDisguise",
        function_owner = self,
        label = "Disguise",
        position = {-1.1, 0.06, -0.4},
        width = 1000, height = 300,
        font_size = 160, color = {0, 0, 0, 0.95}, font_color = {1, 1, 1, 1}
    })
	
	self.createButton({
        click_function = "massCloak",
        function_owner = self,
        label = "Cloak",
        position = {1.1, 0.06, -0.4},
        width = 1000, height = 300,
        font_size = 160, color = {0, 0, 0, 0.95}, font_color = {1, 1, 1, 1}
    })
	
	self.createButton({
        click_function = "massCyberman",
        function_owner = self,
        label = "Cyberman",
        position = {-1.1, 0.06, 0.4},
        width = 1000, height = 300,
        font_size = 160, color = {0, 0, 0, 0.95}, font_color = {1, 1, 1, 1}
    })
	
	self.createButton({
        click_function = "massCreature",
        function_owner = self,
        label = "Creature",
        tooltip = "For face-down permanents with no innate ability to flip over (Ixidron)",
        position = {1.1, 0.06, 0.4},
        width = 1000, height = 300,
        font_size = 160, color = {0, 0, 0, 0.95}, font_color = {1, 1, 1, 1}
    })
	
	self.createButton({
        click_function = "massForest",
        function_owner = self,
        label = "Forest",
        tooltip = "For Yedora, Grave Gardener",
        position = {-1.1, 0.06, 1.2},
        width = 1000, height = 300,
        font_size = 160, color = {0, 0, 0, 0.95}, font_color = {1, 1, 1, 1}
    })
	
	self.createButton({
        click_function = "massFaceUp",
        function_owner = self,
        label = "Face Up",
        position = {1.1, 0.06, 1.2},
        width = 1000, height = 300,
        font_size = 160, color = {0, 0, 0, 0.95}, font_color = {1, 1, 1, 1}
    })
	
	
	Encoder=Global.getVar('Encoder')

end

function massFaceDown(color, faceDownTechnicalName)
    MorphinTime = Global.getVar("MorphinTime")
    
    selectedObjects = Player[color].getSelectedObjects()
    
    if Encoder ~= nil and MorphinTime ~= nil and selectedObjects ~= nil then
    
        for _,card in pairs(selectedObjects) do
            if card.type == "Card" then --skip if not card
                Encoder.call("APIencodeObject",{obj=card}) --make sure it's encoded

                if not Encoder.call("APIobjIsPropEnabled",{obj=card,propID="MorphinTime"}) then
                    --If Morphin Time isn't enabled, enable it with a specific mode
                    MorphinTime.call("genericFlip", {card, faceDownTechnicalName})
                else
                    --If Morphin Time is enabled, just change the mode
                    MorphinTime.call("genericChangeMode", {card, faceDownTechnicalName})
                end
            end
        end
   
    end
end

function massFaceUp(_obj, color, _alt_click)
    MorphinTime = Global.getVar("MorphinTime")
    
    selectedObjects = Player[color].getSelectedObjects()
    
    if Encoder ~= nil and MorphinTime ~= nil and selectedObjects ~= nil then
    
        for _,card in pairs(selectedObjects) do
            if card.type == "Card" then --skip if not card
                Encoder.call("APIencodeObject",{obj=card}) --make sure it's encoded

                if Encoder.call("APIobjIsPropEnabled",{obj=card,propID="MorphinTime"}) then
                    --If Morphin Time is enabled, turn it off, otherwise do nothing
                    MorphinTime.call("genericFlipUp", card)
                end
            end
        end
   
    end
end

function massMorph(_obj, color, _alt_click)
    massFaceDown(color, "mtg_faceDownMorph")
end

function massManifest(_obj, color, _alt_click)
    massFaceDown(color, "mtg_faceDownManifest")
end

function massDisguise(_obj, color, _alt_click)
    massFaceDown(color, "mtg_faceDownDisguise")
end

function massCloak(_obj, color, _alt_click)
    massFaceDown(color, "mtg_faceDownCloak")
end

function massCyberman(_obj, color, _alt_click)
    massFaceDown(color, "mtg_faceDownCyberman")
end

function massCreature(_obj, color, _alt_click)
    massFaceDown(color, "mtg_faceDownCreature")
end

function massForest(_obj, color, _alt_click)
    massFaceDown(color, "mtg_faceDownForest")
end
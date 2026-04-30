function onload(saved_data)
  obj = getObjectFromGUID(self.guid)
  
  
  otherStates = obj.getStates()
  for k,v in pairs(otherStates) do
    table.insert(otherStateData, v.lua_script_state)
  end


  deckDir=-1
  if saved_data ~= "" then
    local loaded_data = JSON.decode(saved_data)
    deckDir = loaded_data[1]
    

    if otherStateData[1] ~= "" then
        decodedOtherStateData = JSON.decode(otherStateData[1])
        deckDir = decodedOtherStateData[1]
        updateSave()
    end
  end

  stateId = obj.getStateId()
  
  buttonLabel = "Error"
  if stateId ~= -1 then
    buttonLabel = faceDownTypes[stateId].name
  end
  
  self.createButton({
    label=buttonLabel,
    click_function="toggleState",
    tooltip=ttText,
    function_owner=self,
    position={0,0.2,0.15},
    height=450,
    width=450,
    scale={1.5,1.5,1.5},
    font_size=300,
    font_color={1,1,1,90},
    color={0,0,0,0},
    tooltip='Change between Manifest and Cloak'
  })
  Encoder=Global.getVar('Encoder')
  if deckDir==1 then
    lab='→'
    tip='card extraction: [b]right[/b]'
  else
    lab='←'
    tip='card extraction: [b]left[/b]'
  end
  self.createButton({
    label=lab,
    tooltip=tip,
    click_function="changeDeckDir",
    function_owner=self,
    position={-1.6,0.1,-1.3},
    height=200,
    width=400,
    font_size=500,
    font_color={1,1,1,90},
    color={0,0,0,0},
  })
end

otherStateData = {}

faceDownTypes={
    {
        name="Manifest",
        technicalName="mtg_faceDownManifest"
    },
    
    {
        name="Cloak",
        technicalName="mtg_faceDownCloak"
    }
}

function changeDeckDir()
  if deckDir==nil then deckDir=-1 end
  deckDir=deckDir*-1
  if deckDir==1 then
    lab='→'
    tip='card extraction: [b]right[/b]'
  else
    lab='←'
    tip='card extraction: [b]left[/b]'
  end
  self.editButton({index=1,label=lab,tooltip=tip})
  updateSave()
end
function updateSave()
  local data_to_save = {deckDir}
  saved_data = JSON.encode(data_to_save)
  self.script_state = saved_data
end
function toggleState(obj, _color, alt_click)
    states = obj.getStates()

    if states[1] ~= nil then
        obj.setState(states[1].id)
    else
        print("Error, this object is missing states, please reload it.")
    end
end


function morphCard(card)
    MorphinTime = Global.getVar("MorphinTime")
    if Encoder ~= nil and MorphinTime ~= nil then
        Encoder.call("APIencodeObject",{obj=card})

        technicalName = faceDownTypes[getObjectFromGUID(self.guid).getStateId()].technicalName
        
        MorphinTime.call("genericFlip", {card, technicalName})
    end
end

function onCollisionEnter(co)

	nowt=os.time()
	if prevt==nil then prevt=0 end
	if nowt-prevt<1 then return end
	prevt=nowt
	deck = co.collision_object
	if deck.type == "Deck" then
    nCards=1

    castPos=deck.getPosition()+deck.getTransformRight():scale(deckDir*3.6)
    targPos=deck.getPosition()+deck.getTransformForward():scale(-3.4)
    local castPars={
      origin=castPos,
      direction = vector(0,0,1),
      type = 3,
      size = {4,4,2},
      max_distance=0,
    }
    local castOutput = Physics.cast(castPars)
    for _,castO in pairs(castOutput) do
      local hitObj = castO.hit_object
      if hitObj.type=='Card' or hitObj.type=='Deck' then
        local hitObjPos=hitObj.getPosition()
        local newObjPos=hitObjPos
        newObjPos[3]=targPos[3]
        hitObj.setPositionSmooth(newObjPos,false,true)
      end
    end
    for i=1,nCards do
      Wait.time(function()
      crot=deck.getRotation()
      crot[3]=180
      cpos=deck.getPosition()+deck.getTransformRight():scale(deckDir*2.4)
      cpos[2]=2
      deck.takeObject({position=cpos,rotation=crot,callback_function=morphCard})

      end,i*0.1)
    end
    self.setPosition({0,0,500})
    self.setLock(true)
    Wait.time(function()
      if self then
        Wait.frames(function() self.destruct() end,1)
      end
    end,10)
	end
end
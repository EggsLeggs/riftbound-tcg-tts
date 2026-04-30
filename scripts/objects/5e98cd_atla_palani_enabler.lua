function onload(saved_data)
  searchTerm1='creature'
  searchTerm2='creature'
  keepGoing=false
  cDeck=nil
  deck=nil
  nReps = 1
  deckDir = -1
  if saved_data ~= "" then
    local loaded_data = JSON.decode(saved_data)
    nReps = loaded_data[1]
    deckDir = loaded_data[2]
  end
  self.createButton({
    label=tostring(nReps),
    click_function="add_subtract",
    tooltip=ttText,
    function_owner=self,
    position={0,0.2,0.15},
    height=450,
    width=450,
    scale={1.5,1.5,1.5},
    font_size=800,
    font_color={1,1,1,90},
    color={0,0,0,0},
    tooltip='   number of creatures to extract\ntype # or left/right click to change'
  })
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
  local data_to_save = {nReps,deckDir}
  saved_data = JSON.encode(data_to_save)
  self.script_state = saved_data
end
function add_subtract(_obj, _color, alt_click)
  mod = alt_click and -1 or 1
  new_value = math.min(math.max(nReps + mod, 0), 99)
  if nReps ~= new_value then
    nReps = new_value
    updateVal()
    updateSave()
  end
end
function updateVal()
  self.editButton({
    index = 0,
    label = tostring(nReps),
    })
end
self.max_typed_number=99
function onNumberTyped(col,int)
  nReps = int
  updateVal()
  updateSave()
end

function onCollisionEnter(co)
	nowt=os.time()
	if prevt==nil then prevt=0 end
	if nowt-prevt<1 then return end
	prevt=nowt
	collobj = co.collision_object

	if collobj.type == "Deck" then
    deck=collobj
    deck.interactable=false

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

    runningRep=0
    for nRep=1,nReps do

      repsDone={}
      repsDone[nRep]=false

      Wait.condition(function()

        runningRep=runningRep+1

        nCards=0
        cardFound=false
        for _,card in pairs(deck.getObjects()) do
          nCards=nCards+1
          cname=card.name:lower():gsub('%p','')
          if cname:match(searchTerm1) or cname:match(searchTerm2) then
            cardFound=true
            break
          end
        end
        if cardFound==false then
          printToAll('could not find any valid cards')
          return
        end
        for i=1,nCards do
          Wait.time(function()
            if i<nCards then
              crot=deck.getRotation()
              crot[3]=0
              cpos=deck.getPosition()+deck.getTransformRight():scale(deckDir*2.4)
              cpos[2]=cpos[2]
              deck.takeObject({position=cpos,rotation=crot,callback_function=groupCards})
            else
              crot=deck.getRotation()
              crot[3]=0
              cpos=deck.getPosition()+deck.getTransformRight():scale(deckDir*4.8+deckDir*(runningRep-1)*1.5)
              finalCard=deck.takeObject({position=cpos,rotation=crot})
              Wait.frames(function()
                Wait.condition(function()
                  if finalCard then
                    finalCard.highlightOn('Red',3)
                  end
                  keepGoing=true
                end, function() return finalCard==nil or finalCard.resting end)
              end,1)
            end
          end,i*0.1)
        end

        Wait.condition(function()
          waitT=0.1
          if cDeck~=nil then
            waitT=1
            cDeck.shuffle()
            local dpos=deck.getPosition()
            local drot=deck.getRotation()
            cDeck.setRotation(drot,false,true)
            Wait.frames(function()
              Wait.condition(function()
                dpos[2]=0.95
                cDeck.shuffle()
                cDeck.setPositionSmooth(dpos,false,true)
                deck.setPositionSmooth(deck.getPosition()+vector(0,2,0),false,true)
                if cDeck.type=='Deck' then deck=cDeck end
              end,function() return not(cDeck.isSmoothMoving()) end)
            end,2)
          end
          if runningRep==nReps then
            deck.interactable=true
            return
          end
          Wait.time(function()
            repsDone[runningRep]=true
            keepGoing=false
            cDeck=nil
          end, waitT)
        end, function() return keepGoing and deck.resting end)

      end,function()
        return (nRep-1==0 or repsDone[nRep-1]==true)
      end)
    end

    self.destruct()
	end
end

function groupCards(c)
  if cDeck==nil then
    cDeck=c
  else
    cDeck=cDeck.putObject(c)
  end
end

function onObjectEnterContainer(container, enter_object)
  if enter_object==cDeck then
    cDeck=container
  end
  if enter_object==deck then
    deck=container
  end
end
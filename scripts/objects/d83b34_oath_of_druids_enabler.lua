function onLoad(saved_data)
  searchTerm1='creature'
  searchTerm2='creature'
  keepGoing1=false
  keepGoing2=false
  cDeck=nil
  
  gravFor=Global.getVar('gravFor')
  if gravFor==nil then
    gravFor=-4.14
  end
  
  if saved_data~='' then
	deckDir=tonumber(saved_data)
  else
	deckDir=-1
  end
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
	deckDir=deckDir*-1
	if deckDir==1 then
		lab='→'
		tip='card extraction: [b]right[/b]'
	else
		lab='←'
		tip='card extraction: [b]left[/b]'
	end
	self.editButton({index=0,label=lab,tooltip=tip})
  self.script_state = deckDir
end

function groupCards(c)
  if cDeck==nil then
    cDeck=c
  else
    cDeck=cDeck.putObject(c)
  end
  keepGoing2=true
end

function onCollisionEnter(co)
	nowt=os.time()
	if prevt==nil then prevt=0 end
	if nowt-prevt<1 then return end
	prevt=nowt
	deck = co.collision_object
	if deck.type == "Deck" then
    nCards=0
    for _,card in pairs(deck.getObjects()) do
      nCards=nCards+1
      cname=card.name:lower():gsub('%p','')
      if cname:match(searchTerm1) or cname:match(searchTerm2) then
        cardInd=i
        break
      end
    end
    castPos=deck.getPosition()+deck.getTransformRight():scale(deckDir*2.4)
    targPos=deck.getPosition()+deck.getTransformForward():scale(-3.4)
    local castPars={
      origin=castPos,
      direction = vector(0,0,1),
      type = 3,
      size = {1,4,2},
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
        if i<nCards then
          crot=deck.getRotation()
          crot[3]=0
          cpos=deck.getPosition()+deck.getTransformRight():scale(deckDir*2.4)
          cpos[2]=cpos[2]+0.1*i
          deck.takeObject({position=cpos,rotation=crot,callback_function=groupCards})
        else
          crot=deck.getRotation()
          crot[3]=0
          cpos=deck.getPosition()+deck.getTransformRight():scale(deckDir*4.8)
          finalCard=deck.takeObject({position=cpos,rotation=crot})
          Wait.frames(function() finalCard.highlightOn('Red',5) end, 1)
          Wait.time(function() keepGoing1=true end, 1)
        end
      end,i*0.1)
    end

    Wait.condition(function()
      Wait.time(function()
        if cDeck==nil then return end
		cDeck.interactable=false
		cDeck.use_gravity=false
		Wait.time(function()
		  cDeck.interactable=true
		  cDeck.use_gravity=true
          local rot = cDeck.getRotation()
          local pos = deck.getPosition() - deck.getTransformForward():scale(gravFor)
		  rot.z=0
          pos[2]=3
          cDeck.setRotationSmooth(rot,false,true)
          cDeck.setPositionSmooth(pos,false,true)
        end, 1)
      end,0.5)
    end, function() return keepGoing1 and keepGoing2 end)

    self.destruct()
	end
end

function onObjectEnterContainer(container, enter_object)
  if enter_object==cDeck then
    cDeck=container
  end
end
function onload(saved_data)
  CascadeCMC = 5
  deckDir=-1
  if saved_data ~= "" then
    local loaded_data = JSON.decode(saved_data)
    CascadeCMC = loaded_data[1]
    deckDir = loaded_data[2]
  end
  self.createButton({
    label=tostring(CascadeCMC),
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
    tooltip='         CMC value to cascade for\ntype # or left/right click to change'
  })
  Encoder=Global.getVar('Encoder')
  keepGoing1=false
  keepGoing2=false
  cDeck=nil
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
  local data_to_save = {CascadeCMC,deckDir}
  saved_data = JSON.encode(data_to_save)
  self.script_state = saved_data
end
function add_subtract(_obj, _color, alt_click)
  mod = alt_click and -1 or 1
  new_value = math.min(math.max(CascadeCMC + mod, 0), 99)
  if CascadeCMC ~= new_value then
    CascadeCMC = new_value
    updateVal()
    updateSave()
  end
end
function updateVal()
  self.editButton({
    index = 0,
    label = tostring(CascadeCMC),
    })
end
self.max_typed_number=99
function onNumberTyped(col,int)
  CascadeCMC = int
  updateVal()
  updateSave()
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
      cdesc=card.description
      cmc=getCMC(cname,cdesc)
      if cmc~=nil and tonumber(cmc)<=CascadeCMC then
        cardInd=i
        break
      end
    end

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
    cascadingNow=true
    for i=1,nCards do
      Wait.time(function()
        if i<nCards then
          crot=deck.getRotation()
          crot[3]=0
          cpos=deck.getPosition()+deck.getTransformRight():scale(deckDir*2.4)
          cpos[2]=2
          deck.takeObject({position=cpos,rotation=crot,callback_function=groupCards})
        else
          crot=deck.getRotation()
          crot[3]=0
          cpos=deck.getPosition()+deck.getTransformRight():scale(deckDir*4.8)
          cpos[2]=2
          finalCard=deck.takeObject({position=cpos,rotation=crot})
          Wait.condition(function()
            cascadingNow=false
            if finalCard==nil then return end
            finalCard.highlightOn('Red',5)
            -- reset encoder object data
            if Encoder then
              Encoder.call('APIencodeObject',{obj=finalCard})
              Encoder.call('APIdisableEncoding',{obj=finalCard})
            end
            -- create buttons on card to accept or decline casting it
            -- decline
            local backpars={    -- background frame
              label='', tooltip='', click_function = 'null',
              position = {-0.5, 0.2, 2}, width = 500, height = 400, font_size = 400,
              scale = {0.75,0.75,0.75}, rotation = {0,0,180},
              color = {0.7,0.7,0.7}, font_color = {1, 1, 1}}
            finalCard.createButton(backpars)
            local forgpars=backpars
            forgpars.label='✗'
            forgpars.tooltip='[b]DO NOT CAST THE CARD[/b]\nmove all the cascaded\n'..
                             'cards to the bottom of the\nlibrary in random order'
            forgpars.click_function='declineCascade'
            forgpars.function_owner=self
            forgpars.rotation = {0,0,0}
            forgpars.font_color = {0.8,0,0}
            forgpars.color = {0.16,0.16,0.16}
            forgpars.hover_color = {0.4,0.4,0.4}
            forgpars.scale = {0.67,0.67,0.67}
            finalCard.createButton(forgpars)
            -- accept
            local backpars={    -- background frame
              label='', tooltip='', click_function = 'null',
              position = {0.5, 0.2, 2}, width = 500, height = 400, font_size = 400,
              scale = {0.75,0.75,0.75}, rotation = {0,0,180},
              color = {0.7,0.7,0.7}, font_color = {1, 1, 1}}
            finalCard.createButton(backpars)
            local forgpars=backpars
            forgpars.label='✓'
            forgpars.tooltip='[b]CAST THE CARD[/b]\nmove all the other cascaded\n'..
                             'cards to the bottom of the\nlibrary in random order'
            forgpars.click_function='acceptCascade'
            forgpars.function_owner=self
            forgpars.rotation = {0,0,0}
            forgpars.font_color = {0,0.6,0}
            forgpars.color = {0.16,0.16,0.16}
            forgpars.hover_color = {0.4,0.4,0.4}
            forgpars.scale = {0.67,0.67,0.67}
            finalCard.createButton(forgpars)
          end, function() return finalCard==nil or finalCard.resting end)
        end
      end,i*0.1)
    end
    self.setPosition({0,0,500})
    self.setLock(true)
    Wait.time(function()
      if self then
        Wait.frames(function() self.destruct() end,1)
      end
      if finalCard then
        acceptCascade(finalCard)
      end
    end,10)
	end
end

function acceptCascade(card)
  finalCard=nil
  if Encoder then
    if Encoder.call('APIobjectExists',{obj=card}) then
      Encoder.call('APIenableEncoding',{obj=card})
    end
  end
  card.setGMNotes('')
  card.clearButtons()
  if cDeck then     -- put any other cascaded cards onto libBot
    moveCDeckToBot(cDeck)
  end
  self.destruct()
end

function declineCascade(card)
  finalCard=nil
  if Encoder then
    if Encoder.call('APIobjectExists',{obj=card}) then
      Encoder.call('APIenableEncoding',{obj=card})
    end
  end
  card.setGMNotes('')
  card.clearButtons()
  if cDeck then       -- add the card to other cascaded cards and then put all on libBot
    card.setPositionSmooth(cDeck.getPosition()+vector(0,0.05,0),false,true)
    Wait.frames(function() cDeck.putObject(card) end, 1)
    Wait.time(function() moveCDeckToBot(cDeck) end, 1)
  else                -- move just the one cards on libBot
    local pos=deck.getPosition()
    pos.y=0.96
    local rot=card.getRotation()
    rot.z=180
    card.setRotationSmooth(rot,false,true)
    Wait.time(function() card.setPositionSmooth(pos,false,true) end, 0.25)
  end
  self.destruct()
end

function moveCDeckToBot(cDeck)
  if cDeck==nil then return end
  dpos=deck.getPosition()
  dpos[2]=1
  drot=deck.getRotation()
  drot[3]=180
  cDeck.shuffle()
  Wait.time(function()
    cDeck.setRotationSmooth(drot,false,true)
    cDeck.setPositionSmooth(dpos,false,true)
  end,0.1)
  deck.setPositionSmooth(deck.getPosition()+vector(0,2,0),false,true)
end

function onObjectEnterContainer(container, enter_object)
  if cascadingNow and enter_object==cDeck then
    cDeck=container
  end
end
function getCMC(name,desc)
  cmc=name:lower():match('(%d+) ?cmc')
  if cmc==nil then
    cmc=name:lower():match('cmc ?(%d+)')
  end
  if cmc==nil then
    cmc=desc:lower():match('(%d+) ?cmc')
  end
  if cmc==nil then
    cmc=desc:lower():match('cmc ?(%d+)')
  end
  isLand=name:lower():match('land')
  if (cmc==nil or cmc=='0') and isLand then
    cmc=nil
  end
  return cmc
end
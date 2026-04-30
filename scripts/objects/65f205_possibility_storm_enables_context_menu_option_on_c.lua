function onLoad()
  data=Global.getTable('data')
  deckDirs=Global.getTable('deckDirs')
  types={'land','creature','artifact','enchantment','planeswalker','instant','sorcery'}
  for _,obj in pairs(Global.getObjects()) do
    if obj.type=='Card' then
      obj.addContextMenuItem('Possibility Storm',possibility)
    end
  end
end

function onDrop()
  broadcastToAll('[i]Possibility Storm[/i] initiated.\nRight click a card and select the option to simplify the procedure.',{1,0,0})
end

function onObjectEnterScriptingZone(zone,obj)
  Wait.frames(function()
    if obj==nil then return end
    if obj.type=='Card' then
      obj.addContextMenuItem('Possibility Storm',possibility)
    end
  end,1)
end

function onObjectExitScriptingZone(zone,obj)
  Wait.frames(function()
    if obj==nil then return end
    if obj.type=='Card' then
      obj.addContextMenuItem('Possibility Storm',possibility)
    end
  end,1)
end

function possibility(ply)

  if data==nil or deckDirs==nil then
    broadcastToAll("this one only works on Pie's MTG tables")
  end

  keepGoing=false
  cardInd=nil
  local deck = getDeckFromZone(data[ply]["libraryZone"])
  local objs = Player[ply].getSelectedObjects()
  local castCard = objs[1]
  Player[ply].clearSelectedObjects()
  if castCard.type~='Card' then return end
  if deck==nil then return end

  local searchTypes={}
  for _,type in pairs(types) do
    if castCard.getName():lower():find(type) then
      table.insert(searchTypes,type)
    end
  end

  local nCards=0
  for i,card in pairs(deck.getObjects()) do
    nCards=nCards+1
    local cname=card.name:lower():gsub('%p','')
    for _,type in pairs(searchTypes) do
      if cname:find(type) then
        cardInd=i
        foundCard=card.name
        break
      end
    end
    if cardInd~=nil then break end
  end

  local deckDir=deckDirs[ply]
  local castPos=deck.getPosition()+deck.getTransformRight():scale(deckDir*3.6)
  local targPos=deck.getPosition()+deck.getTransformForward():scale(-3.4)
  local castPars={
    origin=castPos,
    direction = vector(0,0,1),
    type = 3,
    size = {3,4,2},
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

  local cpos=deck.getPosition()+deck.getTransformRight():scale(deckDir*2.4)
  local crot=deck.getRotation()
  crot[3]=0
  castCard.setPositionSmooth(cpos,false,true)
  castCard.setRotationSmooth(crot,false,true)
  cDeck=castCard

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
        broadcastToAll(Player[ply].steam_name..' wanted to cast [i]'..castCard.getName():gsub('\n.*','')..
                        '[/i] but got [i]'..foundCard:gsub('\n.*','')..'[/i] instead',Color.fromString(ply))
        Wait.time(function() keepGoing=true end, 1)
      end
    end,i*0.1)
  end

  Wait.condition(function()
    Wait.time(function()
      if cDeck==nil then return end
      dpos=deck.getPosition()
      dpos[2]=1
      drot=deck.getRotation()
      drot[3]=180
      cDeck.shuffle()
      Wait.time(function()
        cDeck.setRotationSmooth(drot,false,true)
        cDeck.setPositionSmooth(dpos,false,true)
        cDeck=nil
      end,0.1)
      deck.setPositionSmooth(deck.getPosition()+vector(0,2,0),false,true)
    end,0.5)
  end, function() return keepGoing end)

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
end

function getDeckFromZone(zone)
  local deck = nil
  local objects = zone.getObjects()
  for i,obj in pairs(objects) do
    if obj.type=='Deck' then
      deck = obj
      return deck
    end
  end
  return deck
end
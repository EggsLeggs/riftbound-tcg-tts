function onLoad()
  self.createButton({
    click_function='mindmoil',
    function_owner=self,
    position={0,0.1,0},
    width=1200,
    height=900,
    color={0.1,0.1,0.1,0.85},
		hover_color={0.1,0.1,0.1,0.9},
    tooltip='put hand on bottom of library\n         draw same # cards'
  })
  data=Global.getTable('data')
  deckDats={}
  trackDraw={}
  for _,ply in pairs(Player.getAvailableColors()) do
    if data~=nil and data[ply]["libraryZone"] then
      useDeckZones=true
    else
      useDeckZones=false
      deckDats[ply]=nil
    end
  end
end

function mindmoil(obj,ply,alt)
  local deck = getDeck(ply)
  if deck==nil then
    if useDeckZones then
      Player[ply].broadcast('Could not find your deck.\nMake sure there is a deck in the designated library zone.')
    else
      Player[ply].broadcast('Could not find your deck.\nPick your deck up briefly to register it and then press the button again.')
      deckSearch=ply
    end
    return
  end
  local objs=Player[ply].getHandObjects(1)
  local cards={}
  for _,obj in pairs(objs) do
    if obj.type=='Card' or obj.type=='Deck' then
      local rot=obj.getRotation()
      rot[3]=180
      obj.setRotationSmooth(rot,false,true)
      table.insert(cards,obj)
    end
  end
  local nCards=#cards
  Wait.time(function()
	local gr
    if nCards>1 then
      gr=group(cards)
	     gr=gr[1]
    else
      gr=cards[1]
    end
    if gr==nil then return end
    gr.use_gravity=false
    gr.interactable=false
    gr.shuffle()
    Wait.time(function()
      if gr.type=='Card' then
        handTrigger(gr)
      end
      gr.use_gravity=true
      gr.interactable=true
      gr.shuffle()
      if deck~=nil then
        local pos=deck.getPosition()
        pos[2]=1
        gr.setPositionSmooth(pos,false,true)
        gr.setRotationSmooth(deck.getRotation(),false,true)
        deck.setPositionSmooth(deck.getPosition()+Vector(0,2,0),false,true)
      else
        local rot = gr.getRotation()
        rot.z=180
        local pos = data[ply]["libraryZone"].getPosition()
        pos[2]=1
        gr.setRotationSmooth(rot,false,true)
        gr.setPositionSmooth(pos,false,true)
      end
      Wait.time(function()
        deck = getDeck(ply)
        deck.deal(nCards,ply,1)
      end,1)
    end, 1)
  end, 0.5)
end

function onObjectLeaveContainer(deck,card)
  if useDeckZones then return end
  if card.type=='Card' and deck.type=='Deck' then
    Wait.frames(function()
      Wait.condition(function()
        if card==nil then return end
        for _,ply in pairs(Player.getAvailableColors()) do
          for _,obj in pairs(Player[ply].getHandObjects(1)) do
            if obj==card then
              if trackDraw[deck.getGUID()]==nil then trackDraw[deck.getGUID()]=0 end
              trackDraw[deck.getGUID()]=trackDraw[deck.getGUID()]+1
              if trackDraw[deck.getGUID()]>=7 then
                deckDats[ply]=deck
                -- print(deckDats[ply].getGUID())
              end
              return
            end
          end
        end
      end,function() return card==nil or card.resting end)
    end,2)
  end
end

function onObjectEnterContainer(container,enter_object)
  if useDeckZones then return end
  for _,ply in pairs(Player.getAvailableColors()) do
    if enter_object==deckDats[ply] then
      deckDats[ply]=container
      -- print(deckDats[ply].getGUID())
    end
  end
end

function onObjectPickUp(ply, obj)
  if obj.type~='Deck' then return end
  if deckSearch~=ply then return end
  deckDats[ply]=obj
  Player[ply].broadcast('Deck '..obj.getName():gsub('\n',' | ')..' registered to '..Player[ply].steam_name)
  deckSearch=nil
end

function getDeck(ply)
  local deck
  if useDeckZones then
    deck = getDeckFromZone(data[ply]["libraryZone"])
    if deck==nil then
      deck = getCardFromZone(data[ply]["libraryZone"])
    end
  else
    deck = deckDats[ply]
  end
  return deck
end

function getCardFromZone(zone)
  local card = nil
  local highY = 0
  local highObj = nil
  local objects = zone.getObjects()
  for i,obj in pairs(objects) do
    if obj.type=='Deck' or (obj.type=='Card' and obj.use_gravity) then
      if obj.getPosition().y>highY then
        highY=obj.getPosition().y
        highObj=obj
      end
    end
  end
  if highObj~=nil then
    if highObj.type=='Deck' then     -- pull one card from the top of the deck
      local deck = highObj
      local cardPresent, card = pcall(deck.takeObject)
      if cardPresent and card.type=='Card' then
        deck.setLock(true)
        Wait.frames(function() deck.setLock(false) end, 1)
        card.use_hands = true
        gravityTrigger(card)
        return card
      end
    elseif highObj.type=='Card' then
      local card=highObj
      card.use_hands = true
      gravityTrigger(card)
      return card
    end
  end
  return card   -- if nil?
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

function handTrigger(obj)
  if obj~=nil then
    obj.use_hands=false
    Wait.time(function() handOn(obj) end, 0.1)
  end
end
function handOn(obj)
  if obj~=nil then
    obj.use_hands=true
  end
end
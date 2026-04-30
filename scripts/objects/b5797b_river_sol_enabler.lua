function onLoad()
  self.createButton({
    click_function='drawBottom',
    function_owner=self,
    position={0,0.1,0},
    width=1200,
    height=900,
    color={0.1,0.1,0.1,0.85},
		hover_color={0.1,0.1,0.1,0.9},
    tooltip='draw from bottom'
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

function drawBottom(obj,ply,alt)
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

  local dpos = deck.getPosition()
  dpos.y = 2
  deck.setPositionSmooth(dpos,false,true)

  local bpos = deck.getPosition()+deck.getTransformForward()
  bpos.y=0.98

  local card=deck.takeObject({
    position=bpos,
    smooth=false,
    top=false
  })

  Wait.condition(function() card.deal(1,ply,1) end,
                 function() return not(card.spawning) end)

end

function getDeck(ply)
  local deck
  if useDeckZones then
    deck = getDeckFromZone(data[ply]["libraryZone"])
  else
    deck = deckDats[ply]
  end
  return deck
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

function onObjectPickUp(ply, obj)
  if obj.type~='Deck' then return end
  if deckSearch~=ply then return end
  deckDats[ply]=obj
  Player[ply].broadcast('Deck '..obj.getName():gsub('\n',' | ')..' registered to '..Player[ply].steam_name)
  deckSearch=nil
end

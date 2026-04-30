function onLoad()
  self.createButton({
    click_function='scramble',
    function_owner=self,
    position={0,0.1,0},
    width=1200,
    height=900,
    color={0.1,0.1,0.1,0.85},
		hover_color={0.1,0.1,0.1,0.9},
    tooltip='assign non-land permanents randomly\nto players seated at the table'
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

function scramble(obj,ply,alt)
  for _, player in ipairs(Player.getPlayers()) do
    color=player.color
    if data==nil or data[color]==nil or data[color]["playmat"]==nil then
      broadcastToAll("this one only works on Pie's MTG tables")
      return
    end
  end

  if nClicks==nil then nClicks=0 end
  if lastClick==nil then lastClick=os.time()-10 end
  if (os.time()-lastClick)>0.5 then
    nClicks=0
  end
  lastClick=os.time()
  nClicks=nClicks+1

  wid=Wait.time(function()
    if nClicks==1 and not(announceOff) then
      broadcastToAll('Scambleverse!',{0.8,0,0})
      Wait.time(function()
        broadcastToAll("All individual cards within each player's zone will be redistributed. Cards that are stacked into decks will not be affected.",{0.55,0.55,0.55})
      end,1)
      Wait.time(function()
        broadcastToAll('Cards with counters representing multiple copies need to be split-up/copied into individual cards.',{0.7,0.7,0.7})
      end,2)
      Wait.time(function()
        broadcastToAll('Cards need to have the [i]type[/i] in the namefield (otherwise it will also redistribute the lands).',{0.85,0.85,0.85})
      end,3)
      Wait.time(function()
        broadcastToAll('Any player out of the game needs to have a [i]Skip Turn[/i] puck or be a specator (Grey/Black) or not have any cards in their playzone.',{1,1,1})
      end,4)
      Wait.time(function()
        broadcastToAll('[b]Double-click[/b] the button to Scrambleverse.',{1,0,0})
      end,5)
      announceOff=true
      Wait.time(function() announceOff=false end,10)
      return
    end
  end,1)

  if nClicks<2 then return end

  if wid then
    Wait.stop(wid)
  end

  broadcastToAll('Enacting Scambleverse!',{0.8,0,0})
  printToAll('For each nonland permanent, choose a player at random. Then each player gains '..
      'control of each permanent for which they were chosen. Untap those permanents.',{1,0,0})

  math.randomseed( os.time() )
  for i=1,100+math.random(100) do
    math.random()
  end
  seatedColors={}
  nCol={}
  for _, player in ipairs(Player.getPlayers()) do
    if player.seated then
      table.insert(seatedColors,player.color)
      nCol[player.color]=0
    end
  end

  skipColors={}
  for _, obj in pairs(Global.getObjects()) do
    if obj.getName()=='Turn Skipper' and obj.is_face_down then
      local skipCol=obj.getColorTint()
      print('skipping ',skipCol)
      for i,seatCol in ipairs(seatedColors) do
        print(Color.fromString(seatCol))
        print(Color.fromString(seatCol)==skipCol)
        if Color.fromString(seatCol)==skipCol then
          table.remove(seatedColors,i)
        end
      end
    end
  end

  -- seatedColors={'Blue','White'}
  -- nCol={Blue=0,White=0}

  for _,color in ipairs(seatedColors) do
    if color~='Grey' and color~='Black' then
      cardAssign={}
      nCard=0
      for _,card in pairs(data[color]["playmat"].getObjects()) do
        if card.type=='Card' and not(card.getName():lower():find('land')) then
          nCard=nCard+1
          Wait.time(function()
            local selCol=seatedColors[math.random(#seatedColors)]
            card.highlightOn(Color.fromString(color))
            local nDown=math.floor(nCol[selCol]/10)
            local nRight=nCol[selCol]-nDown*10
            nCol[selCol]=nCol[selCol]+1
            local targPos=data[selCol]["playmat"].getPosition()+data[selCol]["playmat"].getTransformRight():scale(nRight*(-2.4)+10.75)+data[selCol]["playmat"].getTransformForward():scale(nDown*3.2-8)
            local rotDiff=data[selCol]["playmat"].getRotation()-data[color]["playmat"].getRotation()
            local targRot=card.getRotation()+rotDiff
            targPos.y=1
            card.setPositionSmooth(targPos,false,false)
            card.setRotationSmooth(targRot,false,false)
          end,0.05*nCard)
        end
      end
    end
  end


end

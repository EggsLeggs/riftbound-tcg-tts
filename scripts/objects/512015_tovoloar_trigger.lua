function onLoad(savedat)
  line1='at the beginning of each upkeep, if no spells were cast last turn, transform'
  line2='at the beginning of each upkeep, if a player cast two or more spells last turn, transform'
  if savedat and savedat~='' then
    state=tonumber(savedat)
  else
    state=1
  end
  data=Global.getTable('data')
  plys=Player.getAvailableColors()
  enc = Global.getVar('Encoder')
  makeButtons()
end

function makeButtons()
  self.clearButtons()
  if state==1 then
    self.highlightOff()
    self.highlightOn({1,1,0.5})
    self.createButton({
      click_function='switchState',
      function_owner=self,
      label='switch to [i][b]night[/b][/i]\nhumans to [i][b]werewolves[/b][/i]',
      position={0,0.1,0},
      scale={0.5,0.5,0.5},
      width=2200,
      height=1000,
      font_size=200,
      color={0,0,0,0.7},
      font_color={1,1,1,1/0.7}
    })
  elseif state==2 then
    self.highlightOff()
    self.highlightOn({0,0,0.5})
    self.createButton({
      click_function='switchState',
      function_owner=self,
      label='switch to [i][b]day[/b][/i]\nwerewolves to [i][b]humans[/b][/i]',
      position={0,0.1,0},
      scale={0.5,0.5,0.5},
      width=2200,
      height=1000,
      font_size=200,
      color={0,0,0,0.7},
      font_color={1,1,1,1/0.7}
    })
  end
end

function switchState(_,plyCol)
  state=3-state
  makeButtons()

  if state==1 then
    self.script_state = '1'
    for _,ply in pairs(plys) do
      for _,card in pairs(data[ply].playmat.getObjects()) do
        if card.type=='Card' and card.getName()~='[b]Day[/b]' and (card.getDescription():lower():match('nightbound') or ( card.getDescription():lower():match(line2)) and ply==plyCol ) then
          card=card.setState(1)
          enc.call("APIencodeObject",{obj=card})
          enc.call("APIobjEnableProp",{obj=card, propID = "_MTG_Simplified_UNIFIED"})
          enc.call("APIrebuildButtons",{obj=card})
          pcall(function() Wait.time(function() card.highlightOn({1,1,0.5},0.1) end,0.2,5) end)
        end
      end
    end
    dat=self.getCustomObject()
    dat.image='https://c1.scryfall.com/file/scryfall-cards/art_crop/front/f/9/f953fad3-0cd1-48aa-8ed9-d7d2e293e6e2.jpg'
    self.setCustomObject(dat)
    self.reload()

  elseif state==2 then
    self.script_state = '2'
    for _,ply in pairs(plys) do
      for _,card in pairs(data[ply].playmat.getObjects()) do
        if card.type=='Card' and card.getName()~='[b]Night[/b]' and (card.getDescription():lower():match('daybound') or ( card.getDescription():lower():match(line1)) and ply==plyCol ) then
          card=card.setState(2)
          enc.call("APIencodeObject",{obj=card})
          enc.call("APIobjEnableProp",{obj=card, propID = "_MTG_Simplified_UNIFIED"})
          enc.call("APIrebuildButtons",{obj=card})
          pcall(function() Wait.time(function() card.highlightOn({0,0,0.5},0.1) end,0.2,5) end)
        end
      end
    end
    dat=self.getCustomObject()
    dat.image='https://c1.scryfall.com/file/scryfall-cards/art_crop/back/f/9/f953fad3-0cd1-48aa-8ed9-d7d2e293e6e2.jpg'
    self.setCustomObject(dat)
    self.reload()
  end

end

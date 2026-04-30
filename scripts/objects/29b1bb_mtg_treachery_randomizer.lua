function onLoad()
  Nplayers=4
  Uon=true
  Ron=true
  Mon=true
  makeButtons()

  math.randomseed(os.time()+math.random(1,100))
  for i=1,100+math.random(1,100) do math.random() end

end

function makeButtons()
  self.clearButtons()

  bpars={
    function_owner=self,
    scale={0.3,0.3,0.3},
    font_size=500,
    color={0,0,0},
    font_color={0.9,0,0}
  }

  bpars.label=Nplayers..' player start'
  bpars.position={0,0,1.5}
  bpars.tooltip=' click to get the randomly\nselected identity cards for\n the selected player count'
  bpars.click_function='start'
  bpars.width=3400
  bpars.height=800
  self.createButton(bpars)

  bpars.label='+'
  bpars.position={1.35,0,1.5}
  bpars.tooltip='increase number of players'
  bpars.click_function='incPl'
  bpars.height=600
  bpars.width=600
  self.createButton(bpars)

  bpars.label='-'
  bpars.position={-1.35,0,1.5}
  bpars.tooltip='decrease number of players'
  bpars.click_function='decPl'
  self.createButton(bpars)

  if Uon then
    col={0,0,0}
    tip='[i]Uncommon[/i] selected'
  else
    col={0,0,0,0.5}
    tip='[i]Uncommon[/i] [b]not[/b] selected'
  end
  bpars.scale={0.2,0.2,0.2}
  bpars.tooltip=tip
  bpars.color=col
  bpars.label='[i]U[/i]'
  bpars.position={1.75,0,-0.4}
  bpars.click_function='toggleU'
  self.createButton(bpars)

  if Ron then
    col={0,0,0}
    tip='[i]Rare[/i] selected'
  else
    col={0,0,0,0.5}
    tip='[i]Rare[/i] [b]not[/b] selected'
  end
  bpars.tooltip=tip
  bpars.color=col
  bpars.label='[i]R[/i]'
  bpars.position={1.75,0,0}
  bpars.click_function='toggleR'
  self.createButton(bpars)

  if Mon then
    col={0,0,0}
    tip='[i]Mythic[/i] selected'
  else
    col={0,0,0,0.5}
    tip='[i]Mythic[/i] [b]not[/b] selected'
  end
  bpars.tooltip=tip
  bpars.color=col
  bpars.label='[i]M[/i]'
  bpars.position={1.75,0,0.4}
  bpars.click_function='toggleM'
  self.createButton(bpars)

end

function toggleU(obj,ply)
  Uon=not(Uon)
  makeButtons()
end

function toggleR(obj,ply)
  Ron=not(Ron)
  makeButtons()
end

function toggleM(obj,ply)
  Mon=not(Mon)
  makeButtons()
end

function incPl()
  Nplayers=Nplayers+1
  Nplayers=math.min(Nplayers,8)
  makeButtons()
end

function decPl()
  Nplayers=Nplayers-1
  Nplayers=math.max(Nplayers,4)
  makeButtons()
end

function start(obj,ply)

  selected={}

  if not(Uon) and not(Ron) and not(Mon) then
    Player[ply].broadcast("can't select any identities if all the rarities are turned off\n(buttons on the right of the box)",{0.8,0,0})
    return
  end

  printToAll(' ');
  broadcastToAll('[i]TREACHERY INITIATED[/i]',{0.8,0,0})
  printToAll('-----------------------------------------------------',{0.8,0,0})
  if Nplayers == 4 then
   printToAll(' [i]4 player game:[/i] 1 Leader, 1 Traitor, 2 Assassins',{0.8,0,0})
  end
  if Nplayers == 5 then
   printToAll(' [i]5 player game:[/i] 1 Leader, 1 Traitor, 2 Assassins, 1 Guardian',{0.8,0,0})
  end
  if Nplayers == 6 then
   printToAll(' [i]6 player game:[/i] 1 Leader, 1 Traitor, 3 Assassins, 1 Guardian',{0.8,0,0})
  end
  if Nplayers == 7 then
   printToAll(' [i]7 player game:[/i] 1 Leader, 1 Traitor, 3 Assassins, 2 Guardians',{0.8,0,0})
  end
  if Nplayers == 8 then
   printToAll(' [i]8 player game:[/i] 1 Leader, 2 Traitors, 3 Assassins, 2 Guardians',{0.8,0,0})
  end
  printToAll(' - The [b]Leader[/b] and the [b]Guardians[/b] win if they are the last players standing (the Guardians still win if they die but the Leader survives).',{0.8,0,0})
  printToAll(' - The [b]Assassins[/b] win if the Leader is eliminated.',{0.8,0,0})
  printToAll(' - The [b]Traitor[/b] wins if they are the last player standing. [i](This implies killing the Leader/Guardians after the Assassins are eliminated.)[/i]',{0.8,0,0})
  printToAll('-----------------------------------------------------',{0.8,0,0})
  printToAll(' ');

  nIds={
    [4]={leader=1,traitor=1,assassin=2,guardian=0},
    [5]={leader=1,traitor=1,assassin=2,guardian=1},
    [6]={leader=1,traitor=1,assassin=3,guardian=1},
    [7]={leader=1,traitor=1,assassin=3,guardian=2},
    [8]={leader=1,traitor=2,assassin=3,guardian=2}
  }
  pos=self.getPosition()
  rig=self.getTransformRight()

  data=self.getData()
  for _,ddat in pairs(data.ContainedObjects) do
    dname=ddat.Nickname:lower()
    if dname:match('leaders') then
      selectCards(ddat,nIds[Nplayers].leader)
    elseif dname:match('guardians') then
      selectCards(ddat,nIds[Nplayers].guardian)
    elseif dname:match('assassins') then
      selectCards(ddat,nIds[Nplayers].assassin)
    elseif dname:match('traitors') then
      selectCards(ddat,nIds[Nplayers].traitor)
    -- elseif dname:match('token') then
    --   ddat.Transform.rotZ=0
    --   local dpos=self.getPosition()+self.getTransformRight():scale(-1.5)+self.getTransformForward():scale(-3.5)
    --   ddat.Transform.posX=dpos.x
    --   ddat.Transform.posY=dpos.y
    --   ddat.Transform.posZ=dpos.z
    --   spawnObjectData({data=ddat})
    elseif dname:match('rules') then
      ddat.Transform.rotZ=0
      local dpos=self.getPosition()+self.getTransformForward():scale(-4)
      ddat.Transform.posX=dpos.x
      ddat.Transform.posY=dpos.y
      ddat.Transform.posZ=dpos.z
      ddat.Transform.scaleX=1.5
      ddat.Transform.scaleY=1.5
      ddat.Transform.scaleZ=1.5
      spawnObjectData({data=ddat})
    end
  end

  for _,cdat in pairs(permute(selected)) do
    cdat.Transform=data.Transform
    cdat.Transform.rotZ=180
    cdat.Transform.scaleX=1
    cdat.Transform.scaleY=1
    cdat.Transform.scaleZ=1
    card=spawnObjectData({data=cdat,callback_function=function(spawned_object) addToDeck(spawned_object) end})
  end

  self.setLock(true)
  self.setPosition({0,500,0})
  Wait.time(function()
    self.destruct()
  end, 1)

end

function selectCards(ddat,N)

  -- print('---')

  possible={}
  for _,cdat in pairs(ddat.ContainedObjects) do
    cname=cdat.Nickname:lower()
    if (Uon and cname:match('uncommon')) or (Ron and cname:match('rare')) or (Mon and cname:match('mythic')) then
      table.insert(possible,cdat)
    end
  end
  possible=permute(possible)

  lis={}
  for i=1,N do
    pickAgain=true
    while pickAgain do
      ind=math.random(1,#possible)
      pickAgain=false
      for _,ii in pairs(lis) do
        -- print('   '..ind..' ! '..ii)
        if ind==ii then
          -- print('   '..ind..' = '..ii)
          pickAgain=true
        end
      end
    end
    table.insert(lis,ind)
    table.insert(selected,possible[ind])
    -- print(ind)
  end

end

function addToDeck(card)
  if finalDeck==nil then
    finalDeck=card
  else
    finalDeck.putObject(card)
    finalDeck.shuffle()
  end
end

function permute(tab)
  n = #tab
  for i = 1, n do
    local j = math.random(i, n)
    tab[i], tab[j] = tab[j], tab[i]
  end
  return tab
end

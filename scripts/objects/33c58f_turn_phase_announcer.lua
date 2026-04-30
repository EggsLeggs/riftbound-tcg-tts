function onLoad()
  phases={'untap','upkeep','draw','1st main','combat','2nd main','end turn','clean up'}
  i=1
  self.addContextMenuItem('untap', pha1)
  self.addContextMenuItem('upkeep', pha2)
  self.addContextMenuItem('draw', pha3)
  self.addContextMenuItem('1st main', pha4)
  self.addContextMenuItem('combat', pha5)
  self.addContextMenuItem('2nd main', pha6)
  self.addContextMenuItem('end turn', pha7)
  self.addContextMenuItem('clean up', pha8)
  createButtons()
end

function pha1(ply)
  i=1
  announceAndButtons(ply)
end
function pha2(ply)
  i=2
  announceAndButtons(ply)
end
function pha3(ply)
  i=3
  announceAndButtons(ply)
end
function pha4(ply)
  i=4
  announceAndButtons(ply)
end
function pha5(ply)
  i=5
  announceAndButtons(ply)
end
function pha6(ply)
  i=6
  announceAndButtons(ply)
end
function pha7(ply)
  i=7
  announceAndButtons(ply)
end
function pha8(ply)
  i=8
  announceAndButtons(ply)
end

function announceAndButtons(ply)
  broadcastToAll(phases[i],ply)
  createButtons()
end

function createButtons()
  self.clearButtons()
  self.createButton({
    click_function='nextPhase',
    function_owner=self,
    label=phases[i],
    position={0,0.28,0},
    scale={1,1,1},
    width=1000,
    height=400,
    font_size=200,
    color={0,0,0,0.7},
    font_color={1,1,1,1/0.7}
  })
end

function nextPhase(obj,ply,alt)
  if alt then
    i=i-1
  else
    i=i+1
  end
  if i<1 then
    i=8
  end
  if i>8 then
    i=1
  end
  announceAndButtons(ply)
end

function onPlayerTurnStart()
  i=1
  createButtons()
end

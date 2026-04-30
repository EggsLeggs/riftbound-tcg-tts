--By Tispy Hobbit
--with small rework of node position and scale calculations by Oops I Baked a Pie (PieHere)

debugV = false

compass = {
TS={l={x=0,y=0,z=1}},
TN={l={x=0,y=0,z=-1}},
TW={l={x=1,y=0,z=0}},
TE={l={x=-1,y=0,z=0}},
SW={l={x=1,y=0,z=1}},
SE={l={x=-1,y=0,z=1}},
NW={l={x=1,y=0,z=-1}},
NE={l={x=-1,y=0,z=-1}}}
compT = {'TN','TS','TE','TW'}
compO = {'NE','NW','SE','SW'}
compN = {}
--Testing

--Node = {position, adjacent, distance, scale, card}
nodeTable = {}
graveList = {}
centerNode = nil
deckScript = nil

nodeDepth = 3
deck = nil

function onload(save_data)
  --deck = getObjectFromGUID('f33381')    -- could hard-code a dekc into this

  -- save current position and rotation
  oldRot = self.getRotation()
  oldPos = self.getPosition()

  for k,v in pairs(compass) do
    compN[v.l.x..":"..v.l.z] = k
  end

	centerNode = createNode(nodeDepth,nil,nil)
  prepFunctions()

  if save_data ~= nil and save_data ~= "" then
    local dtl = JSON.decode(save_data)
    deckScript = getObjectFromGUID(dtl["Zonesdeck"])
    if dtl["Deck"] ~= nil then
      deck = getObjectFromGUID(dtl["Deck"])
    end
    for k,v in pairs(nodeTable) do
      if v ~= nil then
        nodeTable[k].card = getObjectFromGUID(dtl["Nodes_"..k])
      end
    end
  end

  createZones()
  createButtons()
end
function onSave()
  local dts = {}
  dts["Zonesdeck"] = deckScript.getGUID()
  dts["Deck"] = deck ~= nil and deck.getGUID() or nil
  for k,v in pairs(nodeTable) do
    if v.card ~= nil then
      dts["Nodes_"..k] = v.card.getGUID()
    end
  end

  return JSON.encode(dts)
end
function onDestroy()
  if deckScript ~= nil then
    deckScript.destruct()
  end
  if deck ~= nil then
      deck.interactable = true
  end
end
function onObjectDestroy(obj)
  if deck ~= nil and obj.getGUID() == deck.getGUID() then
    for k,v in pairs(nodeTable) do
      if v.card ~= nil then
        v.card.destruct()
        nodeTable[k].card = nil
      end
    end
    deck = nil
    createButtons()
  end
end


--Prepstuff
function prepFunctions()
  for k,v in pairs(compass) do
    _G["move"..k] = function()
      shiftMap(k)
    end
  end
end

function createNode(dist,prev,dir)
  local node = nil
  if prev == nil then
    node = {l_pos={x=0,y=1,z=0},g_pos=l_pos2g_pos({x=0,y=1,z=0},0),adj={},dis=0,sca=1,card=nil,name=""}
  else
    node = {l_pos=addVectors(prev.l_pos,dir.l),g_pos=nil,adj={},dis=nil,sca=1,card=nil}
    node.dis = math.abs(node.l_pos.x)+math.abs(node.l_pos.z)
    node.sca = 1 - node.dis*0.1     -- card scale -- PieHere
	  node.g_pos = l_pos2g_pos(node.l_pos,node.dis)
  end
  node.name = nodeName(node.l_pos)
  nodeTable[node.name] = node
  for i,k in pairs(compT) do
    v = compass[k]
    dPose = addVectors(node.l_pos,v.l)
    if node.dis < dist then
      if nodeTable[nodeName(dPose)] == nil then
        createNode(dist,node,v)
      end
    end
  end
  for i,v in pairs(compass) do
    dPose = addVectors(node.l_pos,v.l)
    node.adj[i] = nodeTable[nodeName(dPose)]
  end
  return node
end

function nodeName(pos)
  return pos.x..":"..pos.z
end

function recalcNodePos()
  --recalc positions
  for k,v in pairs(nodeTable) do
    node = v
    node.g_pos = l_pos2g_pos(node.l_pos,node.dis)
  end
  --recalc card rotation
  cardRot = getCardRot()
  moveCards()
end

function onCollisionEnter(cI)
  if deckScript == nil then
    createZones()
  else
    deckScript.setPosition(addVectors(addVectors(self.getPosition(),multVector(self.getTransformRight(),0)),multVector(self.getTransformForward(), 0)))
  end
  recalcNodePos()
  createButtons()
end

function createZones()
  if deckScript == nil then
    local params = {}
    params.type = "scriptingTrigger"
    params.position = addVectors(addVectors(self.getPosition(),multVector(self.getTransformRight(),0)),multVector(self.getTransformForward(), 0))
    params.rotation = cardRot
    params.scale = {self.getScale().x, 2, self.getScale().x}
    deckScript = spawnObject(params)
  end
end

--Buttons
function createButtons()
  local yPos = 0.1
  local matScale = self.getScale().x
  self.clearButtons()
  if deck == nil then
    self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="getDeck",function_owner=self,label='gather the planes',position={0.02,yPos,-0.3+0.02},rotation={0,0,0},width=0,height=0,font_size=800,color={0,0,0,0},font_color= {0,0,0,75},tooltip="drop deck onto the board\nand click to register it"})
    self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="getDeck",function_owner=self,label='gather the planes',position={0,yPos*10,-0.3},rotation={0,0,0},width=6000,height=1000,font_size=800,color={0,0,0,0},font_color= {1,1,1,100},tooltip="drop deck onto the board\nand click to register it"})
    self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="getDeck",function_owner=self,label='',position={0,yPos,0},rotation={0,-90,180},width=42*400/matScale,height=60*400/matScale,font_size=10,color={0,0,0,0.9},font_color= {1,1,1,1}})
    self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="getDeck",function_owner=self,label='',position={0,yPos,0},rotation={0,-90,180},width=52*400/matScale,height=70*400/matScale,font_size=10,color={0,0,0,0.8},font_color= {1,1,1,1}})
  else
    local h=0.93
    local w=1.03
    local h_se=0.455
    local w_se=0.815

    self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="lockMat",function_owner=self,label='⌂',position={w*0.44,yPos,-(h)},rotation={0,0,0},width=400,height=400,font_size=250,color={0,0,0,0.8},font_color= self.interactable and {1,1,1,1} or {0.8,0,0,1},tooltip="Lock Mat and Deck"})
    self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="reset",function_owner=self,label='RESET',position={-w*0.37,yPos,-(h)},rotation={0,0,0},width=1200,height=400,font_size=350,color={0,0,0,0.8},font_color= {1,1,1,1},tooltip="resets the map"})

    if math.abs(self.getRotation().x)>45 then
      tvtip = "place the map flat"
    else
      tvtip = "place the map vertically\nlike a TV screen"
    end
    self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="tvMode",function_owner=self,label='TV',position={w*0.34,yPos,-(h)},rotation={0,0,0},width=500,height=400,font_size=250,color={0,0,0,0.8},font_color={1,1,1,1},tooltip=tvtip})

    --Directional Shadows
    self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="moveTW",function_owner=self,label='►',position={-w,yPos*2,0},rotation={0,-180,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={0,0,0,100},tooltip="W"})
    self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="moveTE",function_owner=self,label='►',position={w,yPos*2,0},rotation={0,0,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={0,0,0,100},tooltip="E"})
    self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="moveTN",function_owner=self,label='►',position={0,yPos*2,-h},rotation={0,-90,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={0,0,0,100},tooltip="N"})
    self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="moveTS",function_owner=self,label='►',position={0,yPos*2,h},rotation={0,90,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={0,0,0,100},tooltip="S"})
    if nodeTable["-1:1"].card == nil then self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="moveNW",function_owner=self,label='►',position={-w_se,yPos*2,-h_se},rotation={0,-150,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={0,0,0,100},tooltip="NW"})end
    if nodeTable["-1:-1"].card == nil then self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="moveSW",function_owner=self,label='►',position={-w_se,yPos*2,h_se},rotation={0,-210,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={0,0,0,100},tooltip="SW"})end
    if nodeTable["1:1"].card == nil then self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="moveNE",function_owner=self,label='►',position={w_se,yPos*2,-h_se},rotation={0,-30,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={0,0,0,100},tooltip="NE"})end
    if nodeTable["1:-1"].card == nil then self.createButton({scale={x=0.1,y=0.1,z=0.1},click_function="moveSE",function_owner=self,label='►',position={w_se,yPos*2,h_se},rotation={0,30,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={0,0,0,100},tooltip="SE"})end

    --Directionals
    self.createButton({scale={x=0.06,y=0.06,z=0.06},click_function="moveTW",function_owner=self,label='►',position={-w,yPos*2,0},rotation={0,-180,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={1,0,0,100},tooltip="W"})
    self.createButton({scale={x=0.06,y=0.06,z=0.06},click_function="moveTE",function_owner=self,label='►',position={w,yPos*2,0},rotation={0,0,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={1,0,0,100},tooltip="E"})
    self.createButton({scale={x=0.06,y=0.06,z=0.06},click_function="moveTN",function_owner=self,label='►',position={0,yPos*2,-h},rotation={0,-90,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={1,0,0,100},tooltip="N"})
    self.createButton({scale={x=0.06,y=0.06,z=0.06},click_function="moveTS",function_owner=self,label='►',position={0,yPos*2,h},rotation={0,90,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={1,0,0,100},tooltip="S"})
    if nodeTable["-1:1"].card == nil then self.createButton({scale={x=0.06,y=0.06,z=0.06},click_function="moveNW",function_owner=self,label='►',position={-w_se,yPos*2,-h_se},rotation={0,-150,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={1,0,0,100},tooltip="NW"})end
    if nodeTable["-1:-1"].card == nil then self.createButton({scale={x=0.06,y=0.06,z=0.06},click_function="moveSW",function_owner=self,label='►',position={-w_se,yPos*2,h_se},rotation={0,-210,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={1,0,0,100},tooltip="SW"})end
    if nodeTable["1:1"].card == nil then self.createButton({scale={x=0.06,y=0.06,z=0.06},click_function="moveNE",function_owner=self,label='►',position={w_se,yPos*2,-h_se},rotation={0,-30,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={1,0,0,100},tooltip="NE"})end
    if nodeTable["1:-1"].card == nil then self.createButton({scale={x=0.06,y=0.06,z=0.06},click_function="moveSE",function_owner=self,label='►',position={w_se,yPos*2,h_se},rotation={0,30,0},width=900,height=950,font_size=800,color={0,0,0,0},font_color={1,0,0,100},tooltip="SE"})end
  end
end

-- functions for non-directional buttons
function getDeck()
  for k,v in pairs(deckScript.getObjects()) do
    if v~= self and (v.type == "Deck") then
      deck = v
      broadcastToAll('place the deck somewhere safe\nand click any direction to begin')
    end
  end
  createButtons()
end

function lockMat()
  if self.interactable then
    self.interactable = false
    self.setLock(true)
    if deck ~= nil then
      deck.interactable = false
    end
  else
    self.interactable = true
    if deck ~= nil then
      deck.interactable = true
    end
  end
  recalcNodePos()
  createButtons()
end

function tvMode()
  if self.resting then
    local xRot = self.getRotation().x
    if self.getLock() then
      self.setLock(false)
      self.use_gravity = false
    end
    if math.abs(xRot)<10 then   -- currently flat-ish, swap to vertical
      oldRot = self.getRotation()
      oldPos = self.getPosition()
      local bounds = self.getBoundsNormalized()
      local shiftZ = multVector(self.getTransformForward(),bounds.size.z*0.3)
      local shiftY = {x=0,y=bounds.size.z*0.5,z=0}
      local shift = addVectors(shiftZ,shiftY)
      local newPos = addVectors(oldPos,shift)
      local newRot = {x=80,y=oldRot.y,z=oldRot.z}
      self.setPositionSmooth(newPos,false,false)
      self.setRotationSmooth(newRot,false,false)
      Wait.condition(function() lockInPosition() end, checkResting )
    else              -- currently vertical, swap to flat
      if self.getLock() then
        self.setLock(false)
      end
      if oldPos==nil then
        oldPos = {x=0,y=10,z=0}
      end
      if oldRot==nil then
        oldRot = {x=0,y=0,z=0}
      end
      self.setPositionSmooth(oldPos,false,false)
      self.setRotationSmooth(oldRot,false,false)
      Wait.condition(function() lockInPosition() end, checkResting )
    end
  end
end

function checkResting()
  return self.resting
end
function lockInPosition()
  self.setLock(true)
  self.use_gravity = true
  Wait.frames(function() recalcNodePos() end, 30)
  Wait.frames(function() createButtons() end, 30)
end

function reset()
  -- set all cards into the "graveList"
  for k,v in pairs(nodeTable) do
    if v.card ~= nil then
      graveList[v.card.getGUID()] = v.card
      nodeTable[k].card = nil
    end
  end
  recalcNodePos()
  if deck~=nil then
    deck.interactable = true
    deck.setLock(false)
  end
  deck=nil  -- reset deck
  createButtons()
end


-- functions for directional buttons and moving cards around
function shiftMap(dir)
  if deck ~= nil then
    local oldTable = {}
    local opp = multVector(compass[dir].l,-1)

    for k,v in pairs(nodeTable) do
      oldTable[k] = v.card
    end

    for k,v in pairs(nodeTable) do
      local prev = nodeName(addVectors(v.l_pos,opp))
      if nodeTable[prev] ~= nil then
        nodeTable[k].card = oldTable[prev]
      else
        nodeTable[k].card = nil
      end
      if oldTable[k] ~= nil and nodeTable[nodeName(addVectors(v.l_pos,compass[dir].l))] == nil then
        graveList[oldTable[k].getGUID()] = oldTable[k]
      end
    end
    moveCards()

    local hellride = true
    for k,v in pairs(compT) do
      if k == dir then
        hellride = false
      end
      if centerNode.adj[v].card == nil then
        dealCard(centerNode.adj[v],true)
      end
    end
    if hellride and centerNode.card == nil then
      dealCard(centerNode,true)
    end
  end
  createButtons()
end

function moveCards()
  local pos = self.getPosition()
  local matScale = self.getScale().x
  for k,v in pairs(nodeTable) do
    if v.card ~= nil then
      if v.card.getPosition() ~= addVectors(pos,v.g_pos) then
        v.card.setPositionSmooth(addVectors(pos,v.g_pos),false, true)
        v.card.setRotation(cardRot)
        v.card.setScale(multVector(multVector({x=1,y=1,z=1},nodeTable[k].sca),matScale/12))  --- card scale is relative to board scale x
        v.card.use_hands = false
        if v.l_pos.x==0 and v.l_pos.z==0 then     -- highlight card in middle
          v.card.highlightOn({r=0,g=0,b=1})
        else
          v.card.highlightOff()
        end
      end
      if upright(v.card) < 0 then
        v.card.flip()
      end
    end
  end
  for k,v in pairs(graveList) do
    if v ~= nil then
      if upright(v) >= 0 then
        flipEnt(v)
      end
      v.setRotationSmooth(deck.getRotation(),false,true)
      v.setPositionSmooth(addVectors(deck.getPosition(),{x=0,y=4,z=0}),false,true)
      v.setLock(false)
      v.setScale(deck.getScale())
    end
  end
  return 1
end

function dealCard(node,flip)
  local matScale = self.getScale().x
  local enc = Global.getVar('MTGEncoder')
  local pos = self.getPosition()
  if deck ~= nil then
    deck.randomize()
  end
  local params = {}
  params.position = addVectors(self.getPosition(), multVector(node.g_pos,{x=1,y=1,z=1}) )
  params.rotation = cardRot
  params.flip = flip
  params.top = true
  node.card = deck.takeObject(params)
  node.card.setLock(true)
  node.card.setScale(multVector(multVector({x=1,y=1,z=1},node.sca),matScale/12))
  if enc ~= nil then
    if enc.call("apiObjExist",{card=node.card}) == false then
      enc.call("apiAddCard",{card=node.card})
    end
  end
  moveCards()
end


--Math
function addVectors(a,b)
  return {x=a['x']+b['x'],y=a['y']+b['y'],z=a['z']+b['z']}
end
function multVector(a,b)
  if type(b) ~= "table" then
    b={x=b,y=b,z=b}
  end
  return {x=a['x']*b['x'],y=a['y']*b['y'],z=a['z']*b['z']}
end
--Returns true when upsidedown
function upright(ent)
  return ent.getTransformUp()['y']/(ent.getTransformUp()['y']>0 and ent.getTransformUp()['y'] or ent.getTransformUp()['y']*-1)
end
function flipEnt(ent)
  local rot = ent.getRotation()
  local pos = ent.getPosition()
  local flip = upright(ent)
  ent.setRotation({x=rot.x,y=rot.y,z=rot.z+180})
  if flip > 0 then
    ent.setPosition(addVectors(pos,{x=0,y=0.2,z=0}))
  else
    ent.setPosition(addVectors(pos,{x=0,y=-0.2,z=0}))
  end
end
function waitFrames(num_frames)
  for i=0, num_frames, 1 do
    if destroying == true then
      i = num_frames+1
    else
      coroutine.yield(0)
    end
  end
  return 1
end

function null()
end

function sign(a)
  if a<0 then
	return -1
  else
    return 1
  end
end
-- random function that makes nodes further away step away in smaller
function diminish(a)
  return a-sign(a)*a*a*0.05
end

function l_pos2g_pos(l_pos,dis)  -- transforms l_pos (simple integer coordinates) to g_pos (coordinates relative to the board)
  -- get transform relative to board rotation and scale
  local matScale = self.getScale().x
  local xrot=self.getTransformRight()
  local zrot=self.getTransformForward()
  local yrot=self.getTransformUp()

  -- if the board wasn't rotated these are the coordinates
  local xloc = (-0.3)*diminish(l_pos.x)*matScale
  local zloc = (-0.2)*diminish(l_pos.z)*matScale
  local yloc = (nodeDepth-dis)*0.5+0.2

  -- get rotated coordinates
  local g_pos = addVectors( addVectors( multVector(xrot,xloc) , multVector(zrot,zloc) ) , multVector(yrot,yloc) )

  return g_pos
end

function getCardRot()
  local ri = self.getTransformRight()
  local up = self.getTransformUp()
  local fo = self.getTransformForward()

  local r21 = ri.x*(-1)
  local r31 = ri.y*(-1)
  local r11 = ri.z*(-1)

  local r22 = fo.x
  local r32 = fo.y
  local r12 = fo.z

  local r23 = up.x
  local r33 = up.y
  local r13 = up.z

  local y = math.atan2(r21,r11)/math.pi*180
  local x = math.atan2(r31*(-1),math.sqrt(r32*r32+r33*r33))/math.pi*180
  local z = math.atan2(r32,r33)/math.pi*180

  return {x=x,y=y,z=z}
end
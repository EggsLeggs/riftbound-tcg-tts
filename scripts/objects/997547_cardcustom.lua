function onLoad(saved_data)
  owner=nil
  locked=true
  noencode=true
  picounter=0
  createButtons()
end

function onObjectEnterZone(zone,obj)
  if obj~=self then return end
  for _,hand in pairs(Hands.getHands()) do
    if zone==hand then
      if hand.getValue()~=nil then
        locked=false
        picounter=0
        owner=hand.getValue()
        createButtons()
      end
    end
  end
end

function onObjectLeaveZone(zone,obj)
  if obj~=self then return end
  for _,hand in pairs(Hands.getHands()) do
    if zone==hand then
      if hand.getValue()~=nil then
        locked=true
        owner=hand.getValue()
        createButtons()
      end
    end
  end
end

function createButtons()
  self.clearButtons()
  if owner~=nil then
    self.createButton({
      click_function='null',
      function_owner=self,
      label=tostring(Player[owner].steam_name),
      position=Vector(0,1,-1.8),
      rotation=Vector(0,0,0),
      width=0,
      height=0,
      font_size=1000,
      scale={0.2,1,0.4},
      color={0,0,0,1},
      hover_color={0,0,0,1},
      font_color=Color.fromString(owner),
    })
  end

  pos = Vector(0,1.5,0.1)
  bpars={
    click_function='null',
    function_owner=self,
    label=tostring(picounter),
    position=pos,
    rotation=Vector(0,0,0),
    width=0,
    height=0,
    font_size=1000,
    scale={0.75,1,1.5},
    color={0,0,0,0},
    hover_color={0,0,0,0},
    font_color={0,0,0,100},
  }
  for i=-1,1,1 do         -- outline
    for j=-1,1,1 do
      opars=bpars
      opars.position=pos+Vector(0.02*i,0,0.02*j)
      self.createButton(opars)
    end
  end
  bpars.position=Vector(-0.1,0.3,0.2)
  bpars.font_color={0.1,0.1,0.1,90}
  self.createButton(bpars)    -- shadow
  bpars.click_function='add_subtract'
  bpars.position=pos
  bpars.width=600
  bpars.height=600
  bpars.font_color={1,1,1,100}
  if locked then
    bpars.tooltip='[b]number locked in[/b]\nyou can only edit number while in hand'
  else
    bpars.tooltip='left/right click or type number'
  end
  self.createButton(bpars)    -- the button
end

function add_subtract(obj,ply,alt)
  if not locked and ply==owner then
    new_value = math.min(math.max(picounter + (alt and -1 or 1), 0), 999)
    if picounter ~= new_value then
      picounter = new_value
      createButtons()
    end
  end
end

self.max_typed_number=999
function onNumberTyped(ply, int)
  if not locked and ply==owner then
    picounter=int
    createButtons()
  end
  return true
end

function null()
end

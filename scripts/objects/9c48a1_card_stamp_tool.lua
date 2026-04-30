function onLoad()
	updateSelf()
  prevt=0
end

-- keep a track of the last player interacting with the stamp tool
-- get image url from object's description field when hovered over
function onHover(ply)
  held_color = ply
	updateSelf()
end
function onDrop(ply)
  held_color = ply
  updateSelf()
end
function onPickUp(ply)
  held_color = ply
  updateSelf()
end

-- get image url from object's description field
function updateSelf()
	stampName = self.getName()
	stampUrl  = self.getDescription()

	self.highlightOff({r=1,g=0,b=0})
  local sc = 2

  if stampUrl==nil or stampUrl=='' then
		stampUrl='https://steamusercontent-a.akamaihd.net/ugc/1889849524252081898/B50CED50DC70BDB5FF2B7858256AA6F5062CBDB2/'
		Wait.time(function() self.highlightOn({r=1,g=0,b=0},0.1) end,0.2,5)
    sc = 1.5
  end

	self.setDecals({{
                name     = 'stampImage',
                url      = stampUrl,
                position = {0, self.getBoundsNormalized().size[2], 0},
                rotation = {90, 180, 0},
                scale    = {sc, sc, 1},
  }})

end

-- lock cards that are being hovered over while the stamp tool is being held
-- (allows to right click while holding stamp tool without picking up the card)
function onObjectHover(ply, obj)
		if obj==nil or obj.locked or obj.type~="Card" then return end
		if self.held_by_color == ply then
			obj.setLock(true)
			Wait.condition(
			function() obj.setLock(false) end,
			function() return Player[ply].getHoverObject()~=obj end,
			3,
			function() obj.setLock(false) end
			)
		end
end

-- apply decal upon collision of stamp object with a card
function onCollisionEnter(co)

  if prevt==nil then prevt=0 end
  local nowt=os.time()

	if nowt-prevt<1 then return end     -- run the script once per second (at most)

  local stampUrl = self.getDescription()
	if stampUrl==nil or stampUrl=='' then return end

  if co.collision_object.type ~= "Card" then return end
  prevt=os.time()

	local card = co.collision_object
  local contact = co.contact_points

  -- get mean position of all the contact points
  local pos = {x=0,y=0,z=0}
  for i,p in pairs(contact) do
    count=i;
    pos.x=pos.x+p[1]
    pos.y=pos.y+p[2]
    pos.z=pos.z+p[3]
  end
  pos.x=pos.x/count
  pos.y=pos.y/count
  pos.z=pos.z/count

	-- is the card flipped or not
	local flip = 1
	if card.getRotation().z>90 and card.getRotation().z<270 then
		flip=-1
	end

  -- convert contact position to be local to the card
  local decalPos = card.positionToLocal(pos)
  decalPos.y = flip

	-- decal rotations in TTS are super weird but this does the trick
	local decalRot = {x=180-flip*90, y=90+flip*(90+self.getRotation().y - card.getRotation().y), z=0}

	-- decal scale
	local decalScale = {x=1,y=1,z=1}
	decalScale.x = self.getScale().x / card.getScale().x * 2
	decalScale.y = self.getScale().z / card.getScale().z * 2

	-- prepare decal parameters
  if stampName==nil or stampName=='' then
    stampName='stamp'
  end
	local newDecal = {
								name     = stampName,
								url      = stampUrl,
								position = decalPos,
								rotation = decalRot,
								scale    = decalScale ,
	}

	-- check for pre-existing decals on the card
  local decals = card.getDecals()

  if decals~=nil then
    table.insert(decals,newDecal)
  else
    decals={newDecal}
  end

	-- apply updated decals
  success=pcall(
    function()
      card.setDecals(decals)
    end
  )

  if held_color~=nil then
    broadcastToColor('decal applied to card, use the decal tool (F9) to remove it',held_color)
  end

end

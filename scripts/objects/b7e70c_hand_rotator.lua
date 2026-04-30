function onLoad(saved_data)

	allHands = true
	counterclock = true

	if saved_data ~= "" then
		local loaded_data = JSON.decode(saved_data)
		allHands = loaded_data[1]
		counterclock = loaded_data[2]
	end
  self.script_state = JSON.encode({allHands, counterclock})

	createButtons()

end


function createButtons()
	self.clearButtons()

	lab='↻'
  ttip = 'click to rotate hands [b]clockwise[/b]\n(right-click to switch direction)'
	if counterclock then
		lab='↺'
    ttip = 'click to rotate hands [b]counter-clockwise[/b]\n      (right-click to switch direction)'
	end
	fun = 'rotateHands'
	col = {.9,.9,.9,100}

	if rotating then
		fun = 'doNothing'
		ttip = 'rotating...'
		col = {.4,.4,.4,100}
	end

	self.createButton({
		click_function = fun,
		function_owner = self,
		label = lab,
    tooltip = ttip,
		position = {0,0.5,.2},
		rotation = {0,0,0},
		width = 600,
		height = 600,
    scale = {1.5,1.5,1.5},
		font_size = 1000,
    font_color = col,
    color = {0,0,0,0},
    hover_color={0,0,0,.1},
	})

	if allHands then
		lab2 = 'all hands'
	else
		lab2 = 'only seated'
	end

	self.createButton({
		click_function = 'swapPlayerList',
		function_owner = self,
		label = lab2,
		tooltip = '   swap whether or not to\nonly include seated players',
		position = {0,-0.5,0},
		rotation = {0,0,180},
		width = 800,
		height = 300,
		font_size = 200,
		font_color = {.9,.9,.9,100},
		color = {0,0,0,0},
	})

end


function rotateHands(obj,ply,alt)

  if alt then
    counterclock = not counterclock
    self.script_state = JSON.encode({allHands, counterclock})
    createButtons()
    return
  end

	rotating=true
	createButtons()
	Wait.condition(function()
		createButtons()
	end,function() return not(rotating) end)

	activePlayers={}
	allObjs={}

	if allHands then
		plys=Player.getAvailableColors()
	else
		plys=getSeatedPlayers()
	end

	for i,ply in pairs(plys) do
		num=#Player[ply].getHandObjects(1)
		if num>0 then
			table.insert(activePlayers,ply)
		end
	end

	for i,ply in pairs(activePlayers) do
		if counterclock then
			iMoveTo = (i-1) % (#activePlayers)
		else
			iMoveTo = (i+1) % (#activePlayers)
		end
		if iMoveTo==0 then iMoveTo=#activePlayers end

		local objs=Player[ply].getHandObjects()
		for _,obj in ipairs(objs) do
			allObjs[obj]=activePlayers[iMoveTo]
		end
	end

	k=0
	for obj,ply in pairs(allObjs) do
		k=k+1
		lastObj=obj
		Wait.frames(function()
			obj.deal(1,ply)
			Wait.time(function()
				checkMoveSuccess(obj,ply)
			end,1)
		end,k*2)
	end

	Wait.frames(function()
		Wait.condition(function()
			rotating = false
		end,function()
			return not(lastObj.isSmoothMoving())
		end)
	end,k*2+5)

end


function checkMoveSuccess(obj,ply)

  if obj==nil then
    return
  end

	didNotMakeIt=true
	for _,o in pairs(Player[ply].getHandObjects()) do
		if obj==o then
			didNotMakeIt=false
			break
		end
	end

  if didNotMakeIt then
		local target=Player[ply].getHandTransform(1)
		target.rotation.y=target.rotation.y+180
    obj.setPosition(target.position)
		obj.setRotation(target.rotation)
		-- Wait.time(function() obj.highlightOn(ply,0.1) end,0.2,3)
  end

end


function swapPlayerList()
	allHands = not allHands
	self.script_state = JSON.encode({allHands, counterclock})
	createButtons()
	return
end

function doNothing() end

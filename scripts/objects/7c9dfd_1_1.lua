-- a counter by Oops I baked a pie
-- based off Idan's "better notecards and counters"

MIN_VALUE = -999
MAX_VALUE = 999

function onload(saved_data)
  light_mode = true
  tooltip_show = true
  valP = 1
	valT = 1
	fsize= 500

  if saved_data ~= "" then
    local loaded_data = JSON.decode(saved_data)
    valP = loaded_data[1]
    valT = loaded_data[2]
    fsize = loaded_data[3]
  end

  createAll()
  updateVal()
end

function updateSave()
    local data_to_save = {valP, valT, fsize}
    saved_data = JSON.encode(data_to_save)
    self.script_state = saved_data
end

function createAll()

  s_color = {0.5, 0.5, 0.5, 95}
  if light_mode then
      f_color = {0.9,0.9,0.9,95}
  else
      f_color = {0.05,0.05,0.05,100}
  end

	ttext1  = '\n+1 left click\n-1 right click\n10 button above'
	ttext10 = '\n+10 left click\n-10 right click'

  self.createButton({
    label='+1',
	  tooltip='power:'..ttext1,
    click_function="add_subtractP",
    function_owner=self,
    position={-1.4,0.05,0},
    height=400,
    width=450,
    alignment = 3,
    scale={x=1.5, y=1.5, z=1.5},
    font_size=fsize,
    font_color=f_color,
    color={0,0,0,0},
	  hover_color = {1,1,1,0.2},
	  press_color = {0,0,0,0.2}
  })

	self.createButton({
    label='+1',
	  tooltip='toughness:'..ttext1,
    click_function="add_subtractT",
    function_owner=self,
    position={1.4,0.05,0},
    height=400,
    width=450,
    alignment = 3,
    scale={x=1.5, y=1.5, z=1.5},
    font_size=fsize,
    font_color=f_color,
    color={0,0,0,0},
	  hover_color = {1,1,1,0.2},
	  press_color = {0,0,0,0.2}
  })

	self.createButton({
    label='/',
	  tooltip='adjust both:'..ttext1,
    click_function="add_subtractPT",
    function_owner=self,
    position={0,0.05,0},
    height=400,
    width=450,
    alignment = 3,
    scale={x=1.5, y=1.5, z=1.5},
    font_size=fsize,
    font_color=f_color,
    color={0,0,0,0},
	  hover_color = {1,1,1,0.2},
	  press_color = {0,0,0,0.2}
  })

	self.createButton({
	  tooltip='power:'..ttext10,
    click_function="add_subtractP10",
    function_owner=self,
    position={-1.4,0.05,-0.8},
    height=200,
    width=450,
    alignment = 3,
    scale={x=1.5, y=1.5, z=1.5},
    font_size=fsize,
    font_color=f_color,
    color={0,0,0,0},
	  hover_color = {1,1,1,0.2},
	  press_color = {0,0,0,0.2}
  })

	self.createButton({
	  tooltip='toughness:'..ttext10,
    click_function="add_subtractT10",
    function_owner=self,
    position={1.4,0.05,-0.8},
    height=200,
    width=450,
    alignment = 3,
    scale={x=1.5, y=1.5, z=1.5},
    font_size=fsize,
    font_color=f_color,
    color={0,0,0,0},
	  hover_color = {1,1,1,0.2},
	  press_color = {0,0,0,0.2}
  })

	self.createButton({
	  tooltip='adjust both:'..ttext10,
    click_function="add_subtractPT10",
    function_owner=self,
    position={0,0.05,-0.8},
    height=200,
    width=450,
    alignment = 3,
    scale={x=1.5, y=1.5, z=1.5},
    font_size=fsize,
    font_color=f_color,
    color={0,0,0,0},
	  hover_color = {1,1,1,0.2},
	  press_color = {0,0,0,0.2}
  })

	lightButtonText = "[ swap text color ]"
  self.createButton({
    label=lightButtonText,
    tooltip=lightButtonText,
    click_function="swap_fcolor",
    function_owner=self,
    position={0,-0.05,0.5},
    rotation={180,180,0},
    height=150,
    width=1200,
    scale={x=1, y=1, z=1},
    font_size=150,
    font_color=s_color,
    color={0,0,0,0}
  })

  self.createButton({
    label="[ Reset ]",
    tooltip="[ Reset ]",
    click_function="reset_val",
    function_owner=self,
    position={0,-0.05,-0.5},
    rotation={180,180,0},
    height=250,
    width=1200,
    scale={x=1, y=1, z=1},
    font_size=250,
    font_color=s_color,
    color={0,0,0,0}
  })

end

function swap_fcolor(_obj, _color, alt_click)
  light_mode = not light_mode
	self.removeButton(0)
	self.removeButton(1)
	self.removeButton(2)
	self.removeButton(3)
	self.removeButton(4)
	self.removeButton(5)
	self.removeButton(6)
	self.removeButton(7)
	createAll()
end

function add_subtractP(_obj, _color, alt_click)
  mod = alt_click and -1 or 1
  new_valueP = math.min(math.max(valP + mod, MIN_VALUE), MAX_VALUE)
	valP = new_valueP
  updateSave()
	updateVal()
end

function add_subtractT(_obj, _color, alt_click)
  mod = alt_click and -1 or 1
  valT = math.min(math.max(valT + mod, MIN_VALUE), MAX_VALUE)
  updateSave()
	updateVal()
end

function add_subtractPT(_obj, _color, alt_click)
  mod = alt_click and -1 or 1
	valP = math.min(math.max(valP + mod, MIN_VALUE), MAX_VALUE)
  valT = math.min(math.max(valT + mod, MIN_VALUE), MAX_VALUE)
  updateSave()
  updateVal()
end

function add_subtractP10(_obj, _color, alt_click)
  mod = alt_click and -1 or 1
  valP = math.min(math.max(valP + mod*10, MIN_VALUE), MAX_VALUE)
  updateSave()
  updateVal()
end

function add_subtractT10(_obj, _color, alt_click)
  mod = alt_click and -1 or 1
  valT = math.min(math.max(valT + mod*10, MIN_VALUE), MAX_VALUE)
  updateSave()
	updateVal()
end

function add_subtractPT10(_obj, _color, alt_click)
  mod = alt_click and -1 or 1
	valP = math.min(math.max(valP + mod*10, MIN_VALUE), MAX_VALUE)
  valT = math.min(math.max(valT + mod*10, MIN_VALUE), MAX_VALUE)
  updateSave()
	updateVal()
end

function updateVal()
	if valP>0 then
    labelP = '+'..tostring(valP)
	else
    labelP = tostring(valP)
	end

	if valT>0 then
    labelT = '+'..tostring(valT)
	else
    labelT = tostring(valT)
	end

	updatefsize()

  self.editButton({
    index = 0,
    label = labelP,
    tooltip = 'power\nleft click +1\nright click -1',
    font_size=fsize
  })

	self.editButton({
    index = 1,
    label = labelT,
    tooltip = 'toughness\nleft click +1\nright click -1',
		font_size=fsize
  })

	self.editButton({
		index = 2,
		font_size=fsize
	})

  self.setName(labelP..'/'..labelT)
end

function updatefsize()
	if #(labelP..'/'..labelT)>8 then
		fsize=300
	elseif #(labelP..'/'..labelT)>7 then
		fsize=350
	elseif #(labelP..'/'..labelT)>6 then
		fsize=400
	elseif #(labelP..'/'..labelT)>5 then
		fsize=450
	else
		fsize=500
	end
  updateSave()
end

function reset_val()
  valP = 1
	valT = 1
  updateVal()
  updateSave()
end

self.max_typed_number=999
function onNumberTyped(col,int)
  valP = int
  valT = int
  updateVal()
  updateSave()
end

function null()
end

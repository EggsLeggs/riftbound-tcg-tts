MIN_VALUE = 0
MAX_VALUE = 21

function updateSave()
    local data_to_save = {light_mode, val, tooltip_show}
    saved_data = JSON.encode(data_to_save)
    self.script_state = saved_data
end


function onSave()
 local data_to_save = {saved_count = count}
 saved_data = JSON.encode(data_to_save)
 return saved_data
end

function onload(saved_data)
 count = 0
 generateButtonParamiters()
 if saved_data != '' then
     local loaded_data = JSON.decode(saved_data)
     count = loaded_data.saved_count
     else
     count = 0
end

self.createButton(b_display)
self.createButton(b_plus5)
self.createButton(b_reset)
end

function increase5()
 count = count + 5
 updateDisplay()
end

function reset()
 count = 0
 updateDisplay()
end

function add_subtract(_obj, _color, alt_click)
 mod = alt_click and -1 or 1
 new_value = math.min(math.max(count + mod, MIN_VALUE), MAX_VALUE)
 if count ~= new_value then
 count = new_value
 updateDisplay()
 updateSave()
 end
end

function updateDisplay()
 if count >= 21 then
 count = 21
end

b_display.label = tostring(count)
 self.editButton(b_display)
end

function generateButtonParamiters()
b_display = {
 index = 0,
 click_function = 'add_subtract',
 function_owner = self,
 label = tostring(count),
 font_color = {255, 255, 255, 1}, 
 color= {0, 0, 0, 1}, 
 position = {0.0,0.1,-0.1},
 tooltip="Commander DMG",
 width = 880,
 height = 810,
 font_size = 1000
}
b_plus5 = {
 click_function = 'increase5', 
 function_owner = self, label =  '+5',
 position = {0.6,0.1,1.30},
 tooltip="+5 Dmg",
 font_color = {255, 255, 255, 1},
 color= {0, 0, 0, 1},
 width = 510,
 height = 420,
 font_size = 420
}
b_reset = {
 click_function = 'reset',
 function_owner = self,
 label =  '{R}',
 position = {-0.7,0.1,1.30},
 tooltip="Reset DMG",
 font_color = {255, 255, 255, 1},
 color= {0, 0, 0, 1},
 width = 450,
 height = 380,
 font_size = 340
}
end
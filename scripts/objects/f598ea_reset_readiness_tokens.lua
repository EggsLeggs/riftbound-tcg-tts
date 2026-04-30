function onload()
    local button_parameters = {}
    button_parameters.click_function = "onClick_RotateHands"
    button_parameters.function_owner = self
    button_parameters.label = "Reset\nReady\nTokens"
    button_parameters.position = {0, 0.5, 0}
    --button_parameters.rotation = {float x, float y, float z} ???Optional
    button_parameters.width = 400
    button_parameters.height = 400
    button_parameters.font_size = 100
    self.createButton(button_parameters)
end

function onClick_RotateHands()
    for i,obj in ipairs(getAllObjects()) do
        if obj.getVar('tobiiDraftTools_isReadyToken')
        then 
            cur = obj.getRotation()
            obj.setRotation({cur.x,cur.y,180})
        end
    end
end


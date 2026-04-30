function onLoad()
  scaleMultiplier=2
  data=Global.getTable('data')
  playmats={}
  for i,col in ipairs(Player.getAvailableColors()) do
    playmats[i]=data[col]["playmat"]
  end
end

function onObjectEnterScriptingZone(zone, obj)
    if obj==nil or not(obj.type=='Card') then return end

    local isPlayZone=false
    for _,playmat in pairs(playmats) do
      if zone==playmat then
        isPlayZone=true
      end
    end

    if isPlayZone then
      obj.setScale({scaleMultiplier,1,scaleMultiplier})
    end

end

function onObjectLeaveScriptingZone(zone, obj)

  if obj==nil or not(obj.type=='Card') then return end

  local isPlayZone=false
  for _,oZone in pairs(obj.getZones()) do
    for _,playmat in pairs(playmats) do
      if oZone==playmat and not(oZone==zone) then
        isPlayZone=true
      end
    end
  end

  if isPlayZone then
    obj.setScale({scaleMultiplier,1,scaleMultiplier})
  else
    obj.setScale({1,1,1})
  end

end

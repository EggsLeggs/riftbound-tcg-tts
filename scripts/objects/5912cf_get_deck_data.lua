function onCollisionEnter(co)
	nowt=os.time()
	if prevt==nil then prevt=0 end
	if nowt-prevt<1 then return end
	prevt=nowt
	deck = co.collision_object
	if deck.type == "Deck" then
		fixDeckText(deck)
		self.destruct()
	end
end

function onPickUp(ply)
	pickUpPlayer=ply
end

function fixDeckText(deck)
	if pickUpPlayer~=nil then
		ply=pickUpPlayer
	else
		ply='Black'
	end
  local col=stringColorToRGB(ply)
  col[4]=100
  local colHex='['..Color[ply]:toHex()..']'
  deckData = deck.getData()
  deck.interactable=false
  deck.hide_when_face_down=false
  local bpars={click_function='null',label='fetching data\nfrom scryfall',
    width=0,height=0,scale={0.3,0.3,0.3},font_size=500,
    position={0,0.5,0},rotation={0,0,0},color={0,0,0,0},font_color={1,1,1,100}}
  deck.createButton(bpars)
	bpars.position={0,-0.5,0}
	bpars.rotation={0,0,180}
	deck.createButton(bpars)

  ncards=0
  npross=0
	for i,card in ipairs(deckData.ContainedObjects) do
    ncards=ncards+1
    if card.Nickname == nil or card.Nickname == "" then
      Player[ply].broadcast("error for card #"..i..": "..' [i]no name on card = no way to fetch data[/i]',{1,0.6,0.6})
      npross=npross+1
    elseif card.Nickname ~= nil and card.Nickname ~= "" then
			local name = card.Nickname:gsub('\n.*',''):gsub('%[.-%]','')
			local requestBaseUrl = "https://api.scryfall.com/cards/named?fuzzy="
			local requestUrl = requestBaseUrl .. encodeString(name)
			WebRequest.get(requestUrl, function(webReturn) fixText(webReturn,i,name,ply) end)
		else
      npross=npross+1
    end
	end

  Wait.condition(
    function()
			Player[ply].broadcast('Scryfall data fetch for [i]'..colHex..deck.getName():gsub('\n',' | ')..'[/i][-] deck complete.',{0.6,0.6,0.6})
      deck.destruct()
      spawnObjectData({data = deckData})
    end, function() return ncards==npross end, 10,
    function()
      Player[ply].broadcast('Scryfall data fetch timed out :(',{0.6,0.6,0.6})
      deck.interactable=true
      deck.hide_when_face_down=true
      deck.clearButtons()
    end)
end

function fixText(webReturn,i,name,ply)
  if webReturn.is_error then
    Player[ply].broadcast("error for card #"..i..": "..name,{1,0.6,0.6})
    errorJson(webReturn.text, ply)
  else
    local object = string.match(webReturn.text, '"object":"(.-)"')
    if object == nil then
      Player[ply].broadcast("error for card #"..i..": "..name,{1,0.6,0.6})
      errorJson(webReturn.text, ply)
    else
      local cardDat=deckData.ContainedObjects[i]
      local faceName = cardDat.Nickname:gsub('\n.*',''):gsub('%[.-%]','')
      local cardName,oracle,oracleID=getCardText(webReturn.text,faceName)
      cardDat.Nickname=cardName
      cardDat.Description=oracle
      cardDat.Memo=oracleID
      if cardDat.States then
        for i,state in pairs(cardDat.States) do
          local backName=state.Nickname:gsub('\n.*',''):gsub('%[.-%]','')
          local cardName,oracle,oracleID=getCardText(webReturn.text,backName)
          state.Nickname=cardName
          state.Description=oracle
          state.Memo=oracleID
        end
      end
      deckData.ContainedObjects[i]=cardDat
    end
  end
  npross=npross+1
end

function getCardText(json,name)
  local c = JSONdecode(json)
  c.oracle=''
  if c.card_faces then
    if c.card_faces[2].name:lower():gsub('%W','')==name:lower():gsub('%W','') then
      c.name=c.card_faces[2].name:gsub('"','')..'\n'..c.card_faces[2].type_line..' '..c.cmc..'CMC'
      c.oracle=setOracle(c.card_faces[2])
    else
      c.name=c.card_faces[1].name:gsub('"','')..'\n'..c.card_faces[1].type_line..' '..c.cmc..'CMC'
      c.oracle=setOracle(c.card_faces[1])
    end
  else
    c.name=c.name:gsub('"','')..'\n'..c.type_line..' '..c.cmc..'CMC'
    c.oracle=setOracle(c)
  end
  return c.name,c.oracle,c.oracle_id
end

function setOracle(c)
  if c.power then
    c.oracle_text=c.oracle_text..'\n[b]'..c.power..'/'..c.toughness..'[/b]'
  elseif c.loyalty then
    c.oracle_text=c.oracle_text..'\n[b]'..tostring(c.loyalty)..'[/b]'
  end
  return c.oracle_text:gsub('\\"','"')
end

function errorJson(json, player)
	local json = JSON.decode(json)
	if json.status == 404 then
		Player[player].broadcast("Card name not found in scryfall database.",{1,0.6,0.6})
	else
		Player[player].broadcast(json.details,{1,0.6,0.6})
	end
end

function encodeString(str)
	local output, t = string.gsub(str,"[^%w]",encodeChar)
	return output
end

function encodeChar(chr)
	return string.format("%%%X",string.byte(chr))
end



--------------------------------------------------------------------------------
-- pie's manual "JSONdecode" for scryfall's "object":"card"
--------------------------------------------------------------------------------

normal_card_keys={
  'object',
  'id',
  'oracle_id',
  'name',
  'lang',
  'layout',
  'image_uris',
  'mana_cost',
  'cmc',
  'type_line',
  'oracle_text',
  'loyalty',
  'power',
  'toughness',
  'loyalty',
  'legalities',
  'set',
  'rulings_uri',
  'prints_search_uri',
  'collector_number'
}

image_uris_keys={    -- "image_uris":{
  'small',
  'normal',
  'large',
  'png',
  'art_crop',
  'border_crop',
}

legalities_keys={    -- "legalities":{
  'standard',
  'future',
  'historic',
  'gladiator',
  'pioneer',
  'modern',
  'legacy',
  'pauper',
  'vintage',
  'penny',
  'commander',
  'brawl',
  'duel',
  'oldschool',
  'premodern',
}

related_card_keys={     -- "all_parts":[{"object":"related_card",
  'id',
  'component',
  'name',
  'uri',
}

card_face_keys={        -- "card_faces":[{"object":"card_face",
  'name',
  'mana_cost',
  'type_line',
  'oracle_text',
  'power',
  'toughness',
  'loyalty',
  'image_uris',
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function JSONdecode(txt)
  local txtBeginning = txt:sub(1,16)
  local jsonType = txtBeginning:match('{"object":"(%w+)"')

  -- not scryfall? use normal JSON.decode
  if not(jsonType=='card' or jsonType=='list') then
    return JSON.decode(txt)
  end

  ------------------------------------------------------------------------------
  -- parse list: extract each card, and parse it separately
  -- used when one wants to decode a whole list
  if jsonType=='list' then
    local txtBeginning = txt:sub(1,80)
    local nCards=txtBeginning:match('"total_cards":(%d+)')
    local cardEnd=0
    local cardDats = {}
    for i=1,nCards do     -- could insert max number cards to parse here
      local cardStart=string.find(txt,'{"object":"card"',cardEnd+1)
      local cardEnd = findClosingBracket(txt,cardStart)
      local cardDat = JSONdecode(txt:sub(cardStart,cardEnd))
      table.insert(cardDats,cardDat)
    end
    local dat = {object="list",total_cards=nCards,data=cardDats}    --ignoring hast_more...
    return dat
  end

  ------------------------------------------------------------------------------
  -- parse card

  txt=txt:gsub('}',',}')    -- comma helps parsing last element in an array

  local cardDat={}
  local all_parts_i=string.find(txt,'"all_parts":')
  local card_faces_i=string.find(txt,'"card_faces":')

  -- if all_parts exist
  if all_parts_i~=nil then
    local st=string.find(txt,'%[',all_parts_i)
    local en=findClosingBracket(txt,st)
    local all_parts_txt = txt:sub(all_parts_i,en)
    local all_parts={}
    -- remove all_parts snip from the main text
    txt=txt:sub(1,all_parts_i-1)..txt:sub(en+2,-1)
    -- parse all_parts_txt for each related_card
    st=1
    local cardN=0
    while st~=nil do
      st=string.find(all_parts_txt,'{"object":"related_card"',st)
      if st~=nil then
        cardN=cardN+1
        en=findClosingBracket(all_parts_txt,st)
        local related_card_txt=all_parts_txt:sub(st,en)
        st=en
        local s,e=1,1
        local related_card={}
        for i,key in ipairs(related_card_keys) do
          val,s=getKeyValue(related_card_txt,key,s)
          related_card[key]=val
        end
        table.insert(all_parts,related_card)
        if cardN>30 then break end   -- avoid inf loop if something goes strange
      end
      cardDat.all_parts=all_parts
    end
  end

  -- if card_faces exist
  if card_faces_i~=nil then
    local st=string.find(txt,'%[',card_faces_i)
    local en=findClosingBracket(txt,st)
    local card_faces_txt = txt:sub(card_faces_i,en)
    local card_faces={}
    -- remove card_faces snip from the main text
    txt=txt:sub(1,card_faces_i-1)..txt:sub(en+2,-1)

    -- parse card_faces_txt for each card_face
    st=1
    local cardN=0
    while st~=nil do
      st=string.find(card_faces_txt,'{"object":"card_face"',st)
      if st~=nil then
        cardN=cardN+1
        en=findClosingBracket(card_faces_txt,st)
        local card_face_txt=card_faces_txt:sub(st,en)
        st=en
        local s,e=1,1
        local card_face={}
        for i,key in ipairs(card_face_keys) do
          val,s=getKeyValue(card_face_txt,key,s)
          card_face[key]=val
        end
        table.insert(card_faces,card_face)
        if cardN>4 then break end   -- avoid inf loop if something goes strange
      end
      cardDat.card_faces=card_faces
    end
  end

  -- normal card (or what's left of it after removing card_faces and all_parts)
  st=1
  for i,key in ipairs(normal_card_keys) do
    val,st=getKeyValue(txt,key,st)
    cardDat[key]=val
  end

  return cardDat
end

--------------------------------------------------------------------------------
-- returns data for one card at a time from a scryfall's "object":"list"
function getNextCardDatFromList(txt,startHere)

  if startHere==nil then
    startHere=1
  end

  local cardStart=string.find(txt,'{"object":"card"',startHere)
  if cardStart==nil then
    print('error: no more cards in list')
    startHere=nil
    return nil,nil,nil
  end

  local cardEnd = findClosingBracket(txt,cardStart)
  if cardEnd==nil then
    print('error: no more cards in list')
    startHere=nil
    return nil,nil,nil
  end

  -- startHere is not a local variable, so it's possible to just do:
  -- getNextCardFromList(txt) and it will keep giving the next card or nil if there's no more
  startHere=cardEnd+1

  local cardDat = JSONdecode(txt:sub(cardStart,cardEnd))

  return cardDat,cardStart,cardEnd
end

--------------------------------------------------------------------------------
function findClosingBracket(txt,st)   -- find paired {} or []
  local ob,cb='{','}'
  local pattern='[{}]'
  if txt:sub(st,st)=='[' then
    ob,cb='[',']'
    pattern='[%[%]]'
  end
  local txti=st
  local nopen=1
  while nopen>0 do
    if txti==nil then return nil end
    txti=string.find(txt,pattern,txti+1)
    if txt:sub(txti,txti)==ob then
      nopen=nopen+1
    elseif txt:sub(txti,txti)==cb then
      nopen=nopen-1
    end
  end
  return txti
end

--------------------------------------------------------------------------------
function getKeyValue(txt,key,st)
  local str='"'..key..'":'
  local st=string.find(txt,str,st)
  local en=nil
  local value=nil
  if st~=nil then
    if key=='image_uris' then     -- special case for scryfall's image_uris table
      value={}
      local s=st
      for i,k in ipairs(image_uris_keys) do
        local val,s=getKeyValue(txt,k,s)
        value[k]=val
      end
      en=s
    elseif txt:sub(st+#str,st+#str)~='"' then      -- not a string
      en=string.find(txt,',"',st+#str+1)
      value=tonumber(txt:sub(st+#str,en-1))
    else                                           -- a string
      en=string.find(txt,'",',st+#str+1)
      value=txt:sub(st+#str+1,en-1):gsub('\\"','"'):gsub('\\n','\n'):gsub('(\\u....)','')
    end
  end
  if type(value)=='string' then
    value=value:gsub(',}','}')    -- get rid of the previously inserted comma
  end
  return value,en
end
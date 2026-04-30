--[[
"MTG Deck Loader DX" by DXHHH101
Originally written by Omes (https://steamcommunity.com/sharedfiles/filedetails/?id=2163084841)
Credit to Amuzet as well for ideas taken from their importer.

This is my approach to a rewrite/recycling of Omes' code to comply with Scryfall's API rules.
This is just the "playmat" to actually import the decks onto, the "MTG Importer DX" module is
required for this to function properly.

Feel free to contribute if you spot a bug or something to improve!
https://github.com/DXHHH101/TabletopSimulatorScripts/tree/main/MTGImporter
]]

-- ============================================================================
-- Variables GITHUB AUTO-UPDATE
-- ============================================================================
local ScriptVersion = "1.0.0"
--pi local ScriptClass = 'MTGImporter.DeckloaderMat'
--pi local checkUpdateTimeout = 1

-- ============================================================================
-- UI CONSTANTS / UI IDS
-- ============================================================================
local UI_ADVANCED_PANEL = "MTGDeckLoaderAdvancedPanel"

-- ============================================================================
-- RUNTIME STATE (GLOBAL STATE)
-- ============================================================================
local playerColor = nil

--UI Toggles
local advanced = false
local cardBackInput = ""
local blowCache = false
local pngGraphics = false
local spawnEverythingFaceDown = false
local skipMaybeboard = false
local skipSideboard = false
local skipTokens = false

local pendingDeckSpawns = 0 --used to figure out when all the decks have been fully spawned


-- ============================================================================
-- CONSTANTS (URLS, TYPES, OFFSETS, DEFAULTS)
-- ============================================================================
local TAPPEDOUT_BASE_URL = "https://tappedout.net/mtg-decks/"
local TAPPEDOUT_URL_SUFFIX = "/"
local TAPPEDOUT_URL_MATCH = "tappedout%.net"

local ARCHIDEKT_BASE_URL = "https://archidekt.com/api/decks/"
local ARCHIDEKT_URL_SUFFIX = "/?format=json" -- This used to be "/small/?format=json", which loaded faster, but that endpoint doesn't work properly as of 2024-05.
local ARCHIDEKT_URL_MATCH = "archidekt%.com"

local GOLDFISH_URL_MATCH = "mtggoldfish%.com"

local MOXFIELD_BASE_URL = "https://api2.moxfield.com/v2/decks/all/"
local MOXFIELD_URL_SUFFIX = "/"
local MOXFIELD_URL_MATCH = "moxfield%.com"

local DECKSTATS_URL_SUFFIX = "?export_mtgarena=1"
local DECKSTATS_URL_MATCH = "deckstats%.net"

local SCRYFALL_ID_BASE_URL = "https://api.scryfall.com/cards/"
local SCRYFALL_MULTIVERSE_BASE_URL = "https://api.scryfall.com/cards/multiverse/"
local SCRYFALL_SET_NUM_BASE_URL = "https://api.scryfall.com/cards/"
local SCRYFALL_SEARCH_BASE_URL = "https://api.scryfall.com/cards/search/?q="
local SCRYFALL_NAME_BASE_URL = "https://api.scryfall.com/cards/named/?exact="

local MAINDECK_POSITION_OFFSET = {0.0, 0.1, 0.145}
local COMMANDER_POSITION_OFFSET = {1.25, 0.1, 0.145}
local TOKEN_POSITION_OFFSET = {-1.25, 0.1, 0.145}
local MAYBEBOARD_POSITION_OFFSET = {0.625, 0.1, -1.01}
local SIDEBOARD_POSITION_OFFSET = {-0.625, 0.1, -1.01}

local ERROR_MESSAGE_DECKLOADER = "Deck Loader DX Error: "

-- ============================================================================
-- ERROR / LOGGING HELPERS
-- ============================================================================
local function printError(string, pc) --if no color is given, prints to all
    if pc then
        printToColor(string, pc, {r=1, g=0, b=0})
    else
        printToAll(string, {r=1, g=0, b=0})
    end
    lockSelf(false)
end

local function printInfo(string, pc)
    if pc then
        printToColor(string, pc)
    else
        printToAll(string)
    end
end

--pi -- ============================================================================
-- -- GITHUB AUTO-UPDATE
-- -- ============================================================================
-- --(originally written by ThatRobHuman, heavily modified by DXHHH101)
-- local function isNewerVersion(r,l)
--     local a,b,c = r:match("(%d+)%.(%d+)%.(%d+)")
--     local x,y,z = l:match("(%d+)%.(%d+)%.(%d+)")
--     a,b,c,x,y,z = tonumber(a),tonumber(b),tonumber(c),tonumber(x),tonumber(y),tonumber(z)
--     return a>x or (a==x and (b>y or (b==y and c>z)))
-- end

-- local function installUpdate(newVersion)
-- 	print('[33ff33]Installing Upgrade to MTG Deck Loader DX ['..tostring(newVersion)..']')
-- 	WebRequest.get('https://raw.githubusercontent.com/DXHHH101/TabletopSimulatorScripts/refs/heads/main/MTGImporter/DeckloaderMat.lua' .. "?t=" .. tostring(os.time()), function(res)
--         if (not(res.is_error)) then
--             local state = {}

--             if self.script_state ~= "" then
--                 state = JSON.decode(self.script_state)
--             end

--             state.updatedTo = newVersion

--             self.script_state = JSON.encode(state)

--             self.script_code = res.text
--             self.reload()
--             print('[33ff33]Installation Successful[-]')
--         else
--             error(res)
--         end
--     end)
-- end

-- local function checkForUpdates()
--     if Global.getVar("DXMTGScriptVersions_fetchFailed") then
--         error("Remote version check previously failed.")
--         self.setVar("updateFinished", "kill") --used for the infinite bag object
--         return
--     end


--     if Global.getVar("DXMTGScriptVersions_isFetching") then
--         if checkUpdateTimeout <= 5 then
--             Wait.time(checkForUpdates, 1)
--             checkUpdateTimeout = checkUpdateTimeout + 1
--             return
--         else 
--             error("Failed to check for DX MTG Script updates.")
--         end
--     else
--         local allRemoteVersions = Global.getTable("DXMTGScriptVersions")
--         if not allRemoteVersions then
--             Global.setVar("DXMTGScriptVersions_isFetching", true)
--             WebRequest.get('https://raw.githubusercontent.com/DXHHH101/TabletopSimulatorScripts/refs/heads/main/ScriptVersions.json' .. "?t=" .. tostring(os.time()), function(res)
--                 if (not(res.is_error)) then
--                     local response = JSON.decode(res.text)
--                     Global.setTable("DXMTGScriptVersions", response)
--                     Global.setVar("DXMTGScriptVersions_isFetching", false)

--                     local remoteVersion = response[ScriptClass]
--                     if not remoteVersion then
--                         error("Remote version not found for " .. ScriptClass)
--                     elseif isNewerVersion(remoteVersion, ScriptVersion) then
--                         installUpdate(remoteVersion)
--                     end
--                 else
--                     Global.setVar("DXMTGScriptVersions_fetchFailed", true)
--                     Global.setVar("DXMTGScriptVersions_isFetching", false)
--                     error(res)
--                     self.setVar("updateFinished", "kill") --used for the infinite bag object
--                 end
--             end)
--             return
--         else
--             local remoteVersion = allRemoteVersions[ScriptClass]
--             if not remoteVersion then
--                 error("Remote version not found for " .. ScriptClass)
--             elseif isNewerVersion(remoteVersion, ScriptVersion) then
--                 installUpdate(remoteVersion)
--                 return
--             end
--         end
--     end
--     self.setVar("updateFinished", "kill") --used for the infinite bag object
-- end

-- local function checkCurrentVersion(script_state)
--     local state = {}
--     if script_state ~= "" then
--         state = JSON.decode(script_state) or {}
--     end
--     --Will skip an update check once when the object is reloaded after updating
--     if state.updatedTo ~= ScriptVersion then
--         checkForUpdates()
--     else
--         state.updatedTo = nil
--         self.script_state = JSON.encode(state)
--         self.setVar("updateFinished", true) --used for the infinite bag object
--     end
-- end

-- function getScriptVersion()
--     return ScriptVersion
-- end
-- Global.getVar('Encoder')

-- ============================================================================
-- CONFIG / MODULE DEPENDENCIES
-- ============================================================================
local MTGImporterDX = nil

local function getMTGImporterDX() --Try to find and return the importer module
    MTGImporterDX = Global.getVar("MTGImporterDX")
    if MTGImporterDX then
        return true
    else
        printError(ERROR_MESSAGE_DECKLOADER .. 'Missing "MTG Importer DX"', playerColor)
        return false
    end
end

-- ============================================================================
-- LOCKING / UNLOCKING
-- ============================================================================
function lockSelf(state)
    self.setLock(state)
end

local function lockImporter(state)
    if not getMTGImporterDX() then
        -- Importer module wasn't found, stop working
        return
    end
    MTGImporterDX.call("lockImporter", state)
end

-- ============================================================================
-- BASIC UTILITIES
-- ============================================================================
local function trim(s)
    if not s then return "" end

    local n = s:find"%S"
    return n and s:match(".*%S", n) or ""
end

local function valInTable(table, v)
    for _, value in ipairs(table) do
        if value == v then
            return true
        end
    end

    return false
end

local function stringToBool(s)
    -- It is truly ridiculous that this needs to exist.
    return (string.lower(s) == "true")
end

local function iterateLines(s)
    if not s or string.len(s) == 0 then
        return ipairs({})
    end

    if s:sub(-1) ~= '\n' then
        s = s .. '\n'
    end

    local pos = 1
    return function ()
        if not pos then return nil end

        local p1, p2 = s:find("\r?\n", pos)

        local line
        if p1 then
            line = s:sub(pos, p1 - 1)
            pos = p2 + 1
        else
            line = s:sub(pos)
            pos = nil
        end

        return line
    end
end

-- ============================================================================
-- SPAWNING (DECK/TOKEN OBJECT CREATION)
-- ============================================================================
local function spawnDeckIfAny(decklist, options)
    -- decklist is this: { {card=..., qty=...}, ... }
    if not decklist or #decklist == 0 then return nil end

    local bundledData = {
        decklistArray = decklist,
        cacheBuster = blowCache,
        isPNGImage = pngGraphics,
        playerColor = playerColor
    }
    local cardBack = getCardBack()
    if cardBack ~= nil then
        bundledData.cardBack = cardBack
    end

    if not getMTGImporterDX() then
        -- Importer module wasn't found, stop working
        return
    end

    local deckData = MTGImporterDX.call("createDeckObject", bundledData)
    if not deckData then
        printError(ERROR_MESSAGE_DECKLOADER .. "createDeckObject returned nil", playerColor)
        return nil
    end

    local rotation = self.getRotation()
    rotation.z = options.isFlipped and 180 or 0

    --set name if it exists (only if there's more than 1, otherwise it would set the card name)
    if deckData.ContainedObjects and #deckData.ContainedObjects > 1 then
        deckData.Nickname = options.deckName or ""

    end

    local function calcNewPosition(deckObj, oldPosition)

        local cardCount = 1

        if deckObj.tag == "Deck" and deckObj.getObjects then
            local objs = deckObj.getObjects()
            if objs then
                cardCount = #objs
                if cardCount > 213 then
                    cardCount = 213 --physical deck height seems to cap out here
                end
            end
        end

        local CARD_THICKNESS = 0.01
        local estimatedThickness = cardCount * CARD_THICKNESS

        local newPosition = {
            x = oldPosition.x,
            y = oldPosition.y + (estimatedThickness / 2),
            z = oldPosition.z
        }
        return newPosition
    end


    local function completedDeckSpawn()
        pendingDeckSpawns = pendingDeckSpawns - 1
        if pendingDeckSpawns <= 0 then
            printInfo("Deck successfully imported!", playerColor)
            lockSelf(false)
        end
    end

    local tempPosition = {
        x = options.position.x,
        y = options.position.y + 1000,
        z = options.position.z
    }

    return spawnObjectData({
        data = deckData,
        position = tempPosition,
        rotation = rotation,
        callback_function = function(obj)
            obj.setPosition(calcNewPosition(obj, options.position))


            if (options.onSpawn) then
                options.onSpawn(obj)
            end

            completedDeckSpawn()
        end
    })
end

-- ============================================================================
-- IMPORTER BRIDGE (CALLS MTGImporterDX, ALL SCRYFALL CALLS MADE HERE ONLY)
-- ============================================================================
local function loadDeckFromMainModule(cardMap, postLoadFunction, dataType, options)

    --[[
    dataType (What's built for scryfall):
        "id"
        "name"

    options (all optional):
        deckName (string, defaults to "")
    ]]

    --if no options were passed just make an empty one to avoid an error
    if not options then
        options = {}
    end

    --Build data to send with callback functions
    local bundledData = {
        cardMap = cardMap,
        dataType = dataType,
        deckName = options.deckName or "",
        needToFetchTokens = true,
        playerColor = playerColor,
        callerGUID = self.getGUID(),
        onSuccess = postLoadFunction
    }

    if not getMTGImporterDX() then
        -- Importer module wasn't found, stop working
        return
    end
    MTGImporterDX.call("loadDeckFromScryfall", bundledData)

end

function postDeckLoad(bundledData)
    local importedDeck = bundledData.importedDeck or {}
    local cardMap = bundledData.cardMap or {}
    local deckName = bundledData.deckName or ""
    local importedTokens = bundledData.importedTokens

    

    -- decks
    local commanderDeck, sideboardDeck, maybeboardDeck, mainboardDeck = {}, {}, {}, {}

    local getDeckByQtyField = {
        commanderQty = commanderDeck,
        sideboardQty = sideboardDeck,
        maybeboardQty = maybeboardDeck,
        mainboardQty = mainboardDeck,
    }

    local function pushCardIntoDecks(cardMapData, card)
        for qtyField, deck in pairs(getDeckByQtyField) do
            local qty = cardMapData[qtyField]
            if qty and qty ~= 0 then
                deck[#deck + 1] = { card = card, qty = qty }
            end
        end
    end

    --Make a "finder function based on bundledData.dataType
    local findCard

    if bundledData.dataType == "id" then
        local byID = {}
        for _, card in ipairs(importedDeck) do
            byID[card.id] = card
        end

        findCard = function(cardMapData)
            return byID[cardMapData.id], ("id: " .. tostring(cardMapData.id))
        end

    elseif bundledData.dataType == "name" then
        local byName = {}
        for _, card in ipairs(importedDeck) do
            byName[card.name] = card
        end

        -- emergency fallback: front face name for split/MDFC "Front // Back"
        local function fallbackFrontName(targetName)
            for _, candidate in ipairs(importedDeck) do
                local cname = candidate.name
                if cname and cname:find(" // ", 1, true) then
                    local front = cname:match("^(.-) // ")
                    if front == targetName then
                        return candidate
                    end
                end
            end
            return nil
        end

        findCard = function(cardMapData)
            local card = byName[cardMapData.name] or fallbackFrontName(cardMapData.name)
            return card, ("name: " .. tostring(cardMapData.name))
        end

    elseif bundledData.dataType == "collector_number,set" then
        local byKey = {}
        for _, card in ipairs(importedDeck) do
            byKey[tostring(card.collector_number) .. "|" .. tostring(card.set)] = card
        end

        findCard = function(cardMapData)
            local key = tostring(cardMapData.collector_number) .. "|" .. tostring(cardMapData.set)
            return byKey[key], ("key: " .. tostring(key))
        end
    end

    -- If unknown dataType, error out and hopefully get bug reports
    if not findCard then
        printError(ERROR_MESSAGE_DECKLOADER .. "Unknown dataType: " .. tostring(bundledData.dataType), playerColor)
        return
    end

    for _, cardMapData in pairs(cardMap) do
        local card, label = findCard(cardMapData)
        if not card then
            printError(ERROR_MESSAGE_DECKLOADER .. "Missing card for " .. label, playerColor)
        else
            pushCardIntoDecks(cardMapData, card)
        end
    end

    local tokenDeck = {}
    if not skipTokens then --don't make a token deck if it's not needed (Tokens still needed to be imported from Scryfall to attach the data to the cards that make them)

        -- Sort tokens into a deck (deduped)
        if importedTokens then
            local seen = {}

            local function markSeen(id)
                if not id then return false end
                if seen[id] then return false end
                seen[id] = true
                return true
            end

            for _, token in ipairs(importedTokens) do
                if token.id then
                    if markSeen(token.oracle_id) then
                        tokenDeck[#tokenDeck + 1] = { card = token, qty = 1 }
                    end
                elseif token.card_faces then
                    -- reversible tokens: oracle_id may live on faces
                    local id1 = token.card_faces[1] and token.card_faces[1].oracle_id
                    local id2 = token.card_faces[2] and token.card_faces[2].oracle_id

                    -- add once if both faces are unseen
                    if id1 and id2 and not seen[id1] and not seen[id2] then
                        seen[id1] = true
                        seen[id2] = true
                        tokenDeck[#tokenDeck + 1] = { card = token, qty = 1 }
                    end
                end
            end

            
        end
    end

    pendingDeckSpawns = 0
    for _, deck in pairs(getDeckByQtyField) do
        if #deck > 0 then
            pendingDeckSpawns = pendingDeckSpawns + 1
        end
    end
    if #tokenDeck > 0 then
        pendingDeckSpawns = pendingDeckSpawns + 1
    end

    -- Spawn main piles
    spawnDeckIfAny(mainboardDeck, {
        position = self.positionToWorld(MAINDECK_POSITION_OFFSET),
        isFlipped = true, -- always face down
        deckName = deckName,
        onSpawn = function(obj)
            obj.shuffle()
        end
    })

    spawnDeckIfAny(commanderDeck, {
        position = self.positionToWorld(COMMANDER_POSITION_OFFSET),
        isFlipped = spawnEverythingFaceDown,
        deckName = "Commander"
    })

    spawnDeckIfAny(maybeboardDeck, {
        position = self.positionToWorld(MAYBEBOARD_POSITION_OFFSET),
        isFlipped = spawnEverythingFaceDown,
        deckName = "Maybeboard"
    })

    spawnDeckIfAny(sideboardDeck, {
        position = self.positionToWorld(SIDEBOARD_POSITION_OFFSET),
        isFlipped = spawnEverythingFaceDown,
        deckName = "Sideboard"
    })

    spawnDeckIfAny(tokenDeck, {
        position = self.positionToWorld(TOKEN_POSITION_OFFSET),
        isFlipped = spawnEverythingFaceDown,
        deckName = "Tokens"
    })
end

-- ============================================================================
-- PARSERS (URL / DECK IDS / DECK LINES)
-- ============================================================================
local function parseDeckIDArchidekt(s)
    return s:match("archidekt%.com/decks/(%d*)")
end

local function parseDeckIDMoxfield(s)
    local urlSuffix = s:match("moxfield%.com/decks/(.*)")
    if urlSuffix then
        return urlSuffix:match("([^%s%?/$]*)")
    else
        return nil
    end
end

local function parseDeckIDTappedout(s)
    -- NOTE: need to do this in multiple parts because TTS uses an old version
    -- of lua with hilariously sad pattern matching
    local urlSuffix = s:match("tappedout%.net/mtg%-decks/(.*)")
    if urlSuffix then
        return urlSuffix:match("([^%s%?/$]*)")
    else
        return nil
    end
end

local function parseDeckIDDeckstats(s)
    -- Remove query string first
    s = s:match("^[^?]+") or s

    -- Extract deck path
    local deckURL = s:match("(deckstats%.net/decks/%d+/[^/]*)")
    return deckURL
end

local function parseMTGALine(line)
    -- Parse out card count if exists
    local count, countIndex = string.match(line, "^%s*(%d+)[x%*]?%s+()")
    if count and countIndex then
        line = string.sub(line, countIndex)
    else
        count = 1
    end

    local name, setCode, collectorNum = string.match(line, "([^%(%)]+) %(([%d%l%u]+)%) ([%d%l%u]+)")

    if not name then
        name, setCode = string.match(line, "([^%(%)]+) %(([%d%l%u]+)%)")
    end

    if not name then
       name = string.match(line, "([^%(%)]+)")
    end

    -- MTGA format uses DAR for dominaria for some reason, which scryfall can't find.
    if setCode == "DAR" then
        setCode = "DOM"
    end

    return name, count, setCode, collectorNum
end

local function parseCardLine(line, format)
    -- Parses one deck line into:
    -- qty = number,
    -- name = string,
    -- set = string|nil,
    -- num = string|nil,
    -- format = "name_set_num" | "set_name" | "name_only"

    if not line then return nil, "nil line" end

    -- trim
    line = trim(line)

    local qty = 1
    local rest = line

    -- Quantity (2, 2x, 2*, etc.) at start SOMETIMES, assumes 1 otherwise
    local qtyStr, afterQtyIdx = line:match("^(%d+)%s*[x%*]?%s+()")
    if qtyStr then
        qty = tonumber(qtyStr) or 1
        rest = line:sub(afterQtyIdx)
        rest = rest:gsub("^%s+", "")
    end

    if rest == "" then
        return nil, "missing card data"
    end

    if not format or format == "name_set_num" then
        -- FORMAT 1: CARDNAME (SET) NUM
        -- Example: "Lightning Bolt (M11) 146"
        local name, set, num = rest:match("^(.-)%s*%((%w+)%)%s*(%S+)%s*$")
        if name and set and num then
            name = trim(name)
            return qty, name, set:lower(), num, "name_set_num" -- qty, name, set, num, format
        end
    end

    if not format or format == "set_name" then
        -- FORMAT 2: [SET] CARDNAME
        -- Example: "[mh2] Ragavan, Nimble Pilferer"
        local set, name = rest:match("^%[(%w+)%]%s*(.+)$")
        if set and name then
            name = trim(name)
            return qty, name, set:lower(), nil, "set_name" -- qty, name, set, num, format
        end
    end

    if not format or format == "name" then
        local name = trim(rest)
        if name ~= "" then
            return qty, name, nil, nil, "name" -- qty, name, set, num, format
        end
    end
    return nil, nil, nil, nil, nil -- qty, name, set, num, format
end


-- ============================================================================
-- NOTEBOOK IMPORT
-- ============================================================================
local function readNotebookForColor(playerColor)
    for _, tab in ipairs(Notes.getNotebookTabs()) do
        if tab.title == playerColor and tab.color == playerColor then
            return tab.body
        end
    end

    return nil
end

local notebookImportCategoryMap = {
    commander = { mode = "commander", qtyField = "commanderQty" },
    sideboard = { mode = "sideboard", qtyField = "sideboardQty" },
    deck      = { mode = "mainboard", qtyField = "mainboardQty" },
    maindeck  = { mode = "mainboard", qtyField = "mainboardQty" },
    mainboard = { mode = "mainboard", qtyField = "mainboardQty" },
    about     = { mode = "about", qtyField = "mainboardQty" } --set to mainboardQty here just in case?
}

local function queryDeckNotebook(_)
    local notebookContents = readNotebookForColor(playerColor)

    if notebookContents == nil then
        printError(ERROR_MESSAGE_DECKLOADER .. "Notebook not found: " .. playerColor, playerColor)
        lockImporter(false)
        return
    elseif string.len(notebookContents) == 0 then
        printError(ERROR_MESSAGE_DECKLOADER .. "Notebook is empty. Please paste your decklist into your notebook (" .. playerColor .. ").", playerColor)
        lockImporter(false)
        return
    end

    local cardMap = {}

    local mode = "mainboard"
    local format, scryfallFormat
    local qtyField = "mainboardQty"


    for line in iterateLines(notebookContents) do
        if string.len(line) > 0 and mode ~= "about" then
            local categoryCheck = line:lower()
            local entryCheck = notebookImportCategoryMap[categoryCheck]

            if entryCheck then
                mode = entryCheck.mode
                qtyField = entryCheck.qtyField
            else

                local qty, name, setCode, collectorNum, returnFormat = parseCardLine(line, format)

                if not format then
                    format = returnFormat
                    if not format then
                        printError(ERROR_MESSAGE_DECKLOADER .. "Notebook importer error: nil format", playerColor)
                        lockImporter(false)
                        break
                    end
                end


                local key

                if format == "card_set_num" then
                    scryfallFormat = "collector_number,set"
                    key = collectorNum .. "|" .. setCode
                    local entry = cardMap[key]
                    
                    if not entry then
                        entry = {
                            collector_number = collectorNum,
                            set = setCode,
                            commanderQty=0,
                            sideboardQty=0,
                            maybeboardQty=0,
                            mainboardQty=0
                        }
                        cardMap[key] = entry
                    end
                elseif format == "set_card" then
                    scryfallFormat = "name,set"
                    key = name .. "|" .. setCode
                    local entry = cardMap[key]
                    
                    if not entry then
                        entry = {
                            name = name,
                            set = setCode,
                            commanderQty=0,
                            sideboardQty=0,
                            maybeboardQty=0,
                            mainboardQty=0
                        }
                        cardMap[key] = entry
                    end
                elseif format == "name" then
                    scryfallFormat = "name"
                    key = name
                    local entry = cardMap[key]
                    
                    if not entry then
                        entry = {
                            name = name,
                            commanderQty=0,
                            sideboardQty=0,
                            maybeboardQty=0,
                            mainboardQty=0
                        }
                        cardMap[key] = entry
                    end
                else
                    printError(ERROR_MESSAGE_DECKLOADER .. "Notebook importer error: format not found", playerColor)
                    lockImporter(false)
                    break
                end

                cardMap[key][qtyField] = cardMap[key][qtyField] + qty
            end
        end
    end

    loadDeckFromMainModule(cardMap, "postDeckLoad", scryfallFormat)
end

-- ============================================================================
-- REMOTE DECK QUERIES (SITE INTEGRATIONS)
-- ============================================================================
local function queryDeckArchidekt(deckID)
    if not deckID or string.len(deckID) == 0 then
        printError(ERROR_MESSAGE_DECKLOADER .. "Invalid Archidekt deck: " .. deckID, playerColor)
        lockImporter(false)
        return
    end

    local url = ARCHIDEKT_BASE_URL .. deckID .. ARCHIDEKT_URL_SUFFIX

    printInfo("Fetching decklist from Archidekt...", playerColor)

    WebRequest.get(url, function(webReturn)
        if webReturn.error then
            if string.match(webReturn.error, "(404)") then
                printError(ERROR_MESSAGE_DECKLOADER .. "Deck not found. Is it public?", playerColor)
                lockImporter(false)
            else
                printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: " .. tostring(webReturn.error), playerColor)
                lockImporter(false)
            end
            return
        elseif webReturn.is_error then
            printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: unknown", playerColor)
            lockImporter(false)
            return
        elseif string.len(webReturn.text) == 0 then
            printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: empty response", playerColor)
            lockImporter(false)
            return
        end

        local success, data = pcall(function() return json.decode(webReturn.text) end)

        if not success then
            printError(ERROR_MESSAGE_DECKLOADER .. "Failed to parse JSON response from Archidekt.", playerColor)
            lockImporter(false)
            return
        elseif not data then
            printError(ERROR_MESSAGE_DECKLOADER .. "Empty response from Archidekt.", playerColor)
            lockImporter(false)
            return
        elseif not data.cards then
            printError(ERROR_MESSAGE_DECKLOADER .. "Empty response from Archidekt. Did you enter a valid deck URL?", playerColor)
            lockImporter(false)
            return
        end

        local function isMaybeboard(card)
            if card.categories and card.categories[1] then
                local firstCategoryName = card.categories[1]

                for _, category in ipairs(data.categories) do
                    if category.name == firstCategoryName then
                        if not category.includedInDeck then
                            return true
                        end
                    end
                end

                return false
            end
        end

        local function hasCategoryNamed(card, name)
            if card.categories then
                return valInTable(card.categories, name)
            else
                return false
            end
        end

        local cardMap = {}

        for _, card in ipairs(data.cards) do
            if card and card.card then
                local key = card.card.uid
                local entry = cardMap[key]

                if not entry then
                    entry = {
                        id = key,
                        commanderQty=0,
                        sideboardQty=0,
                        maybeboardQty=0,
                        mainboardQty=0
                    }

                    cardMap[key] = entry
                end

                if hasCategoryNamed(card, "Commander") then
                    entry.commanderQty = entry.commanderQty + card.quantity
                elseif hasCategoryNamed(card, "Sideboard") then
                    if not skipSideboard then
                        entry.sideboardQty = entry.sideboardQty + card.quantity
                    end
                elseif isMaybeboard(card) then
                    if not skipMaybeboard then
                        entry.maybeboardQty = entry.maybeboardQty + card.quantity
                    end
                else
                    entry.mainboardQty = entry.mainboardQty + card.quantity
                end
            end
        end

        options = {
            deckName = data.name or ""
        }

        loadDeckFromMainModule(cardMap, "postDeckLoad", "id", options)

    end)
end

local function queryDeckMoxfield(deckID)
    if not deckID or string.len(deckID) == 0 then
        printError(ERROR_MESSAGE_DECKLOADER .. "Invalid Moxfield deck: " .. deckID, playerColor)
        lockImporter(false)
        return
    end

    local url = MOXFIELD_BASE_URL .. deckID .. MOXFIELD_URL_SUFFIX

    printInfo("Fetching decklist from Moxfield...", playerColor)

    local headers = {
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["User-Agent"] = "TTS-MTG-Card-Importer/1.0"
    }

    WebRequest.custom(url, "GET", true, "", headers, function(webReturn)
        if webReturn.error then
            if string.match(webReturn.error, "(404)") then
                printError(ERROR_MESSAGE_DECKLOADER .. "Deck not found. Is it public?", playerColor)
                lockImporter(false)
            else
                printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: " .. webReturn.error, playerColor)
                lockImporter(false)
            end
            return
        elseif webReturn.is_error then
            printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: unknown", playerColor)
            lockImporter(false)
            return
        elseif string.len(webReturn.text) == 0 then
            printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: empty response", playerColor)
            lockImporter(false)
            return
        end


        local raw = webReturn.text
        local unicodeMap = {
            ["\\u2014"] = "-",   -- em dash
            ["\\u2013"] = "-",   -- en dash
            ["\\u2018"] = "'",   -- left single quote
            ["\\u2019"] = "'",   -- right single quote
            ["\\u201c"] = '"',   -- left double quote
            ["\\u201d"] = '"',   -- right double quote
            ["\\u0026"] = "&",   -- ampersand
            ["\\u002b"] = "+",   -- plus sign
            ["\\u0027"] = "'"   -- apostrophe
        }

        -- pass 1: replace known escapes
        raw = raw:gsub("(\\u%x%x%x%x)", unicodeMap)

        -- pass 2: anything still left is unknown
        raw = raw:gsub("\\u%x%x%x%x", "ERROR")


        local success, data = pcall(function() return json.decode(raw) end)

        if not success then
            printError(ERROR_MESSAGE_DECKLOADER .. "Failed to parse JSON response from Moxfield.", playerColor)
            lockImporter(false)
            return
        elseif not data then
            printError(ERROR_MESSAGE_DECKLOADER .. "Empty response from Moxfield.", playerColor)
            lockImporter(false)
            return
        elseif not data.name or not data.mainboard then
            printError(ERROR_MESSAGE_DECKLOADER .. "Empty response from Moxfield. Did you enter a valid deck URL?", playerColor)
            lockImporter(false)
            return
        end

        local cardMap = {}
        
        local function accumulateList(list, qtyField)
            for _, card in pairs(list or {}) do
                if card and card.card then
                    local key = card.card.scryfall_id
                    local entry = cardMap[key]

                    if not entry then
                        entry = {
                            id = key,
                            commanderQty=0,
                            sideboardQty=0,
                            maybeboardQty=0,
                            mainboardQty=0
                        }

                        cardMap[key] = entry
                    end

                    entry[qtyField] = entry[qtyField] + card.quantity
                end
            end
        end

        accumulateList(data.commanders, "commanderQty")
        accumulateList(data.mainboard,  "mainboardQty")
        if not skipSideboard then
            accumulateList(data.sideboard,  "sideboardQty")
        end
        if not skipMaybeboard then
            accumulateList(data.maybeboard, "maybeboardQty")
        end

        local options = {
            deckName = data.name or ""
        }

        loadDeckFromMainModule(cardMap, "postDeckLoad", "id", options)
    end)
end

local function queryDeckTappedout(deckID)
    if not deckID or string.len(deckID) == 0 then
        printError(ERROR_MESSAGE_DECKLOADER .. "Invalid TappedOut deck URL: " .. tostring(deckID), playerColor)
        lockImporter(false)
        return
    end

    local url = TAPPEDOUT_BASE_URL .. deckID .. TAPPEDOUT_URL_SUFFIX

    printInfo("Fetching decklist from TappedOut (very limited API)...", playerColor)

    WebRequest.get(url .. "?fmt=txt", function(webReturn)

        if webReturn.error then
            if string.match(webReturn.error, "(404)") then
                printError(ERROR_MESSAGE_DECKLOADER .. "Deck not found. Is it public?", playerColor)
                lockImporter(false)
            else
                printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: " .. webReturn.error, playerColor)
                lockImporter(false)
            end
            return
        elseif webReturn.is_error then
            printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: unknown", playerColor)
            lockImporter(false)
            return
        elseif not webReturn.text or string.len(webReturn.text) == 0 then
            printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: empty response", playerColor)
            lockImporter(false)
            return
        end

        local cardMap = {}
        local isSideboard = false

        for line in iterateLines(webReturn.text) do
            if line and string.len(line) > 0 then

                -- Detect sideboard
                if line == "Sideboard:" then
                    isSideboard = true
                else
                    -- Expected format: "<qty> <card name>"
                    local qtyStr, name = string.match(line, "^(%d+)%s+(.+)$")

                    if qtyStr and name then
                        local qty = tonumber(qtyStr) or 0
                        name = name:gsub("^%s+", ""):gsub("%s+$", "")

                        -- Use card name as key
                        local entry = cardMap[name]

                        if not entry then
                            entry = {
                                name = name,
                                mainboardQty = 0,
                                sideboardQty = 0
                            }
                            cardMap[name] = entry
                        end

                        if isSideboard then
                            if not skipSideboard then
                                entry.sideboardQty = entry.sideboardQty + qty
                            end
                        else
                            entry.mainboardQty = entry.mainboardQty + qty
                        end
                    end
                end
            end
        end

        loadDeckFromMainModule(cardMap, "postDeckLoad", "name")
    end)
end

local function queryDeckDeckstats(deckURL)
    if not deckURL or string.len(deckURL) == 0 then
        printError(ERROR_MESSAGE_DECKLOADER .. "Invalid deckstats URL: " .. deckURL, playerColor)
        lockImporter(false)
        return
    end

    local url = deckURL .. DECKSTATS_URL_SUFFIX


    printInfo("Fetching decklist from deckstats...", playerColor)

    local headers = {
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["User-Agent"] = "TTS-MTG-Card-Importer/1.0"
    }

    WebRequest.custom(url, "GET", true, "", headers, function(webReturn)
        if webReturn.error then
            if string.match(webReturn.error, "(404)") then
                printError(ERROR_MESSAGE_DECKLOADER .. "Deck not found. Is it public?", playerColor)
                lockImporter(false)
            else
                printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: " .. webReturn.error, playerColor)
                lockImporter(false)
            end
            return
        elseif webReturn.is_error then
            printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: unknown", playerColor)
            lockImporter(false)
            return
        elseif string.len(webReturn.text) == 0 then
            printError(ERROR_MESSAGE_DECKLOADER .. "Web request error: empty response", playerColor)
            lockImporter(false)
            return
        end

        local cardMap = {}
        local isSideboard = false


        
        for line in iterateLines(webReturn.text) do
            if line then
                if string.len(line) == 0 then
                    isSideboard = true
                else

                    local name, qty, setCode, collectorNum = parseMTGALine(line)

                    local key = name
                    local entry = cardMap[key]

                    if not entry then
                        entry = {
                            name = name,
                            mainboardQty = 0,
                            sideboardQty = 0
                        }
                        cardMap[key] = entry
                    end

                    if isSideboard then
                        entry.sideboardQty = entry.sideboardQty + qty
                    else
                        entry.mainboardQty = entry.mainboardQty + qty
                    end
                end
            end
        end

        --[[ 
        -- DX Note: I don't like this method, I would rather just not sort out the commander...

        -- This sucks... but the arena export format is the only one that gives
        -- me full data on printings and this is the best way I've found to tell
        -- if its a commander deck.
        if #cards >= 90 then
            cards[1].commander = true
        end
        ]]

        local options = {
            deckName = deckURL:match("deckstats%.net/decks/%d*/%d*-([^/?]*)") or ""

        }

        loadDeckFromMainModule(cardMap, "postDeckLoad", "name", options)
    end)
end

-- ============================================================================
-- UI BUILD / UI HANDLERS
-- ============================================================================
local function drawUI()
    local _inputs = self.getInputs()
    local deckURL = ""

    if _inputs ~= nil then
        for _, input in pairs(self.getInputs()) do
            if input.label == "Enter deck URL, or load from Notebook." then
                deckURL = input.value
            end
        end
    end
    self.clearInputs()
    self.clearButtons()
    self.createInput({
        input_function = "onLoadDeckInput",
        function_owner = self,
        label          = "Enter deck URL, or load from Notebook.",
        alignment      = 2,
        position       = {x=0, y=0.1, z=0.925},
        width          = 1800,
        height         = 100,
        font_size      = 70,
        validation     = 1,
        value = deckURL,
    })

    self.createButton({
        click_function = "onLoadDeckURLButton",
        function_owner = self,
        label          = "Import (URL)",
        position       = {-0.85, 0.1, 1.3},
        rotation       = {0, 0, 0},
        width          = 750,
        height         = 160,
        font_size      = 80,
        color          = {0.5, 0.5, 0.5},
        font_color     = {r=1, b=1, g=1},
        tooltip        = "Click to import deck from URL",
    })

    self.createButton({
        click_function = "onLoadDeckNotebookButton",
        function_owner = self,
        label          = "Import (Notebook)",
        position       = {0.85, 0.1, 1.3},
        rotation       = {0, 0, 0},
        width          = 750,
        height         = 160,
        font_size      = 80,
        color          = {0.5, 0.5, 0.5},
        font_color     = {r=1, b=1, g=1},
        tooltip        = "Click to import deck from notebook",
    }) 

    self.createButton({
        click_function = "onToggleAdvancedButton",
        function_owner = self,
        label          = "☰",
        position       = {1.85, 0.1, 1.3},
        rotation       = {0, 0, 0},
        width          = 160,
        height         = 160,
        font_size      = 100,
        color          = {0.5, 0.5, 0.5},
        font_color     = {r=1, b=1, g=1},
        tooltip        = "Click to open advanced menu",
    })

    if advanced then
        self.UI.show(UI_ADVANCED_PANEL)
    else
        self.UI.hide(UI_ADVANCED_PANEL)
    end
    
end


function getDeckInputValue()
    for _, input in pairs(self.getInputs()) do
        --NOTE Fix this vvvv weird way to find that input
        if input.label == "Enter deck URL, or load from Notebook." then
            return trim(input.value)
        end
    end

    return ""
end

function importDeck(decklistType, pc) --pc is playerColor

    if not getMTGImporterDX() then
        -- Importer module wasn't found, stop working
        return
    end
    local importerLock = MTGImporterDX.call("isImporterLocked")
    if importerLock then
        printError(ERROR_MESSAGE_DECKLOADER .. importerLock, pc)
        return
    end

    if (self.getLock()) then
        printToColor("This importer is already working, please wait until it's complete!", pc) --do this print manually here to not set playerColor until we know we're actually going to run
        return
    end

    --lock both after we've checked neither are in use
    lockImporter(true) --lock the importer and deckloader for future work until this is done
    lockSelf(true)


    playerColor = pc --Wait to set the playerColor until we know nothing is currently running

    local deckURL = getDeckInputValue()

    local deckID
    if decklistType == "url" then
        if string.len(deckURL) == 0 then
            printInfo("Please enter a deck URL.", playerColor)
            lockSelf(false)
            lockImporter(false)
            return
        end

        if string.match(deckURL, TAPPEDOUT_URL_MATCH) then
            printInfo("Starting deck import...")
            deckID = parseDeckIDTappedout(deckURL)
            queryDeckTappedout(deckID)
            return
        elseif string.match(deckURL, ARCHIDEKT_URL_MATCH) then
            printInfo("Starting deck import...")
            deckID = parseDeckIDArchidekt(deckURL)
            queryDeckArchidekt(deckID)
            return
        elseif string.match(deckURL, GOLDFISH_URL_MATCH) then
            printInfo("MTGGoldfish support isn't in yet, sorry! In the meantime, please export to MTG Arena, and use notebook import.")
        elseif string.match(deckURL, MOXFIELD_URL_MATCH) then
            printInfo("Starting deck import...")
            deckID = parseDeckIDMoxfield(deckURL)
            queryDeckMoxfield(deckID)
            return
        elseif string.match(deckURL, DECKSTATS_URL_MATCH) then
            printInfo("Starting deck import...")
            deckID = parseDeckIDDeckstats(deckURL)
            queryDeckDeckstats(deckID)
            return
        else
            printInfo("Unknown deck site! Please export to MTG Arena and use notebook import.")
        end
    elseif decklistType == "notebook" then
        printInfo("Starting deck import...")
        deckID = nil
        queryDeckNotebook()
        return
    else
        printError(ERROR_MESSAGE_DECKLOADER .. "Unknown deck source: " .. tostring(decklistType), playerColor)
    end

    --if by the end of this function nothing returned from it, something errored out. Just unlock both things
    lockImporter(false)
    lockSelf(false)
end

function onLoadDeckInput(_, _, _, _) end

function onLoadDeckURLButton(_, pc, _, _)
    importDeck("url", pc)
end

function onLoadDeckNotebookButton(_, pc, _, _)
    importDeck("notebook", pc)
end

function onToggleAdvancedButton(_, _, _, _)
    advanced = not advanced
    drawUI()
end

function UI_onCardBackInput(_, value, _)
    cardBackInput = value
end

function getCardBack()
    if not cardBackInput or string.len(cardBackInput) == 0 then
        return nil
    else
        return cardBackInput
    end
end

function UI_onBlowCacheToggle(_, value, _)
    blowCache = stringToBool(value)
end

function UI_onPNGGraphicsToggle(_, value, _)
    pngGraphics = stringToBool(value)
end

function UI_onFaceDownToggle(_, value, _)
    spawnEverythingFaceDown = stringToBool(value)
end

function UI_onSkipMaybeboardToggle(_, value, _)
    skipMaybeboard = stringToBool(value)
end

function UI_onSkipSideboardToggle(_, value, _)
    skipSideboard = stringToBool(value)
end

function UI_onSkipTokensToggle(_, value, _)
    skipTokens = stringToBool(value)
end

-- ============================================================================
-- LIFECYCLE
-- ============================================================================
local function setVersionInDescription(optionalExtraText)
    local desc = self.getDescription() or ""
    local versionLine = "[i]Version " .. tostring(ScriptVersion) .. (optionalExtraText and ("\n" .. optionalExtraText) or "") .. "[/i]"

    local pattern = "%[i%]Version%s+%d+%.%d+%.%d+.-%[/i%]"

    if desc:match(pattern) then
        -- Replace existing version line
        desc = desc:gsub(pattern, versionLine, 1)
    else
        -- No version present, add it to the top
        if desc == "" then
            desc = versionLine
        else
            desc = versionLine .. "\n" .. desc
        end
    end

    self.setDescription(desc)
end

function onLoad(script_state)
    self.setName("[00B4FF]MTG Deck Loader[-] [EF8B06]DX[-]")
    setVersionInDescription("Type !reloadimporter and/or reload this object if the importer is stuck.\n")

    --pi checkCurrentVersion(script_state)
    self.setVar("updateFinished", true) --pi

    drawUI()
end

-- ============================================================================
-- json.lua
-- ============================================================================

json = (function()
--
-- json.lua
--
-- Copyright (c) 2020 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


local json = { _version = "0.1.2" }

-------------------------------------------------------------------------------
-- Encode
-------------------------------------------------------------------------------

local encode

local escape_char_map = {
  [ "\\" ] = "\\",
  [ "\"" ] = "\"",
  [ "\b" ] = "b",
  [ "\f" ] = "f",
  [ "\n" ] = "n",
  [ "\r" ] = "r",
  [ "\t" ] = "t",
}

local escape_char_map_inv = { [ "/" ] = "/" }
for k, v in pairs(escape_char_map) do
  escape_char_map_inv[v] = k
end


local function escape_char(c)
  return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
end


local function encode_nil(val)
  return "null"
end


local function encode_table(val, stack)
  local res = {}
  stack = stack or {}

  -- Circular reference?
  if stack[val] then error("circular reference") end

  stack[val] = true

  if rawget(val, 1) ~= nil or next(val) == nil then
    -- Treat as array -- check keys are valid and it is not sparse
    local n = 0
    for k in pairs(val) do
      if type(k) ~= "number" then
        error("invalid table: mixed or invalid key types")
      end
      n = n + 1
    end
    if n ~= #val then
      error("invalid table: sparse array")
    end
    -- Encode
    for i, v in ipairs(val) do
      table.insert(res, encode(v, stack))
    end
    stack[val] = nil
    return "[" .. table.concat(res, ",") .. "]"

  else
    -- Treat as an object
    for k, v in pairs(val) do
      if type(k) ~= "string" then
        error("invalid table: mixed or invalid key types")
      end
      table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
    end
    stack[val] = nil
    return "{" .. table.concat(res, ",") .. "}"
  end
end


local function encode_string(val)
  return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
end


local function encode_number(val)
  -- Check for NaN, -inf and inf
  if val ~= val or val <= -math.huge or val >= math.huge then
    error("unexpected number value '" .. tostring(val) .. "'")
  end
  return string.format("%.14g", val)
end


local type_func_map = {
  [ "nil"     ] = encode_nil,
  [ "table"   ] = encode_table,
  [ "string"  ] = encode_string,
  [ "number"  ] = encode_number,
  [ "boolean" ] = tostring,
}


encode = function(val, stack)
  local t = type(val)
  local f = type_func_map[t]
  if f then
    return f(val, stack)
  end
  error("unexpected type '" .. t .. "'")
end


function json.encode(val)
  return ( encode(val) )
end


-------------------------------------------------------------------------------
-- Decode
-------------------------------------------------------------------------------

local parse

local function create_set(...)
  local res = {}
  for i = 1, select("#", ...) do
    res[ select(i, ...) ] = true
  end
  return res
end

local space_chars   = create_set(" ", "\t", "\r", "\n")
local delim_chars   = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
local escape_chars  = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
local literals      = create_set("true", "false", "null")

local literal_map = {
  [ "true"  ] = true,
  [ "false" ] = false,
  [ "null"  ] = nil,
}


local function next_char(str, idx, set, negate)
  for i = idx, #str do
    if set[str:sub(i, i)] ~= negate then
      return i
    end
  end
  return #str + 1
end


local function decode_error(str, idx, msg)
  local line_count = 1
  local col_count = 1
  for i = 1, idx - 1 do
    col_count = col_count + 1
    if str:sub(i, i) == "\n" then
      line_count = line_count + 1
      col_count = 1
    end
  end
  error( string.format("%s at line %d col %d", msg, line_count, col_count) )
end


local function codepoint_to_utf8(n)
  -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
  local f = math.floor
  if n <= 0x7f then
    return string.char(n)
  elseif n <= 0x7ff then
    return string.char(f(n / 64) + 192, n % 64 + 128)
  elseif n <= 0xffff then
    return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
  elseif n <= 0x10ffff then
    return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                       f(n % 4096 / 64) + 128, n % 64 + 128)
  end
  error( string.format("invalid unicode codepoint '%x'", n) )
end


local function parse_unicode_escape(s)
  local n1 = tonumber( s:sub(1, 4),  16 )
  local n2 = tonumber( s:sub(7, 10), 16 )
   -- Surrogate pair?
  if n2 then
    return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
  else
    return codepoint_to_utf8(n1)
  end
end


local function parse_string(str, i)
  local res = ""
  local j = i + 1
  local k = j

  while j <= #str do
    local x = str:byte(j)

    if x < 32 then
      decode_error(str, j, "control character in string")

    elseif x == 92 then -- `\`: Escape
      res = res .. str:sub(k, j - 1)
      j = j + 1
      local c = str:sub(j, j)
      if c == "u" then
        local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                 or str:match("^%x%x%x%x", j + 1)
                 or decode_error(str, j - 1, "invalid unicode escape in string")
        res = res .. parse_unicode_escape(hex)
        j = j + #hex
      else
        if not escape_chars[c] then
          decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
        end
        res = res .. escape_char_map_inv[c]
      end
      k = j + 1

    elseif x == 34 then -- `"`: End of string
      res = res .. str:sub(k, j - 1)
      return res, j + 1
    end

    j = j + 1
  end

  decode_error(str, i, "expected closing quote for string")
end


local function parse_number(str, i)
  local x = next_char(str, i, delim_chars)
  local s = str:sub(i, x - 1)
  local n = tonumber(s)
  if not n then
    decode_error(str, i, "invalid number '" .. s .. "'")
  end
  return n, x
end


local function parse_literal(str, i)
  local x = next_char(str, i, delim_chars)
  local word = str:sub(i, x - 1)
  if not literals[word] then
    decode_error(str, i, "invalid literal '" .. word .. "'")
  end
  return literal_map[word], x
end


local function parse_array(str, i)
  local res = {}
  local n = 1
  i = i + 1
  while 1 do
    local x
    i = next_char(str, i, space_chars, true)
    -- Empty / end of array?
    if str:sub(i, i) == "]" then
      i = i + 1
      break
    end
    -- Read token
    x, i = parse(str, i)
    res[n] = x
    n = n + 1
    -- Next token
    i = next_char(str, i, space_chars, true)
    local chr = str:sub(i, i)
    i = i + 1
    if chr == "]" then break end
    if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
  end
  return res, i
end


local function parse_object(str, i)
  local res = {}
  i = i + 1
  while 1 do
    local key, val
    i = next_char(str, i, space_chars, true)
    -- Empty / end of object?
    if str:sub(i, i) == "}" then
      i = i + 1
      break
    end
    -- Read key
    if str:sub(i, i) ~= '"' then
      decode_error(str, i, "expected string for key")
    end
    key, i = parse(str, i)
    -- Read ':' delimiter
    i = next_char(str, i, space_chars, true)
    if str:sub(i, i) ~= ":" then
      decode_error(str, i, "expected ':' after key")
    end
    i = next_char(str, i + 1, space_chars, true)
    -- Read value
    val, i = parse(str, i)
    -- Set
    res[key] = val
    -- Next token
    i = next_char(str, i, space_chars, true)
    local chr = str:sub(i, i)
    i = i + 1
    if chr == "}" then break end
    if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
  end
  return res, i
end


local char_func_map = {
  [ '"' ] = parse_string,
  [ "0" ] = parse_number,
  [ "1" ] = parse_number,
  [ "2" ] = parse_number,
  [ "3" ] = parse_number,
  [ "4" ] = parse_number,
  [ "5" ] = parse_number,
  [ "6" ] = parse_number,
  [ "7" ] = parse_number,
  [ "8" ] = parse_number,
  [ "9" ] = parse_number,
  [ "-" ] = parse_number,
  [ "t" ] = parse_literal,
  [ "f" ] = parse_literal,
  [ "n" ] = parse_literal,
  [ "[" ] = parse_array,
  [ "{" ] = parse_object,
}


parse = function(str, idx)
  local chr = str:sub(idx, idx)
  local f = char_func_map[chr]
  if f then
    return f(str, idx)
  end
  decode_error(str, idx, "unexpected character '" .. chr .. "'")
end


function json.decode(str)
  if type(str) ~= "string" then
    error("expected argument of type string, got " .. type(str))
  end
  local res, idx = parse(str, next_char(str, 1, space_chars, true))
  idx = next_char(str, idx, space_chars, true)
  if idx <= #str then
    decode_error(str, idx, "trailing garbage")
  end
  return res
end

    return {
        decode = json.decode,
        encode = json.encode
    }
end)()
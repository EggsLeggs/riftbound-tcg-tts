function onLoad()

    math.randomseed(os.time())
    thumbOFFline = "Krark's Thumb? [i][b]No[/b][/i]"
    thumbONline = "Krark's Thumb? [i][b]Yes[/b][/i]"

    thumbToggle = thumbOFFline

    coinStr = {[2]='[008000]✓[-]',
               [1]='[ff0000]✗[-]'}
    coinLine = ''

    X = nil

    self.createButton({
      label="Flip a Coin",
      click_function="oneCoin",
      function_owner=self,
      position={-0.2,0.2,-0.7},
      scale={0.75,0.75,0.75},
      color={0.1,0.1,0.1},
      font_color={1,1,1},
      height=225,
      width=900,
      alignment = 3,
    })
    self.createButton({
      label="Flip X Coins",
      click_function="xCoin",
      function_owner=self,
      position={-0.2,0.2,-0.35},
      scale={0.75,0.75,0.75},
      color={0.1,0.1,0.1},
      font_color={1,1,1},
      height=225,
      width=900,
      alignment = 3,
    })
    self.createInput({
      value = self.getDescription(),
      input_function = "null",
      label = "X=?",
      function_owner = self,
      position={0.9,0.2,-0.35},
      scale={0.75,0.75,0.75},
      color={0.1,0.1,0.1},
      font_color={1,1,1},
      height=174,
      width=300,
      font_size=150,
      alignment = 3,
      validation= 2
    })
    self.createButton({
      label="Flip 'til Fail",
      click_function="manyCoin",
      function_owner=self,
      position={-0.2,0.2,0},
      scale={0.75,0.75,0.75},
      color={0.1,0.1,0.1},
      font_color={1,1,1},
      height=225,
      width=900,
      alignment = 3,
    })
    self.createButton({
      label="Flip 'til Success",
      click_function="manyCoin2",
      function_owner=self,
      position={-0.2,0.2,0.35},
      scale={0.75,0.75,0.75},
      color={0.1,0.1,0.1},
      font_color={1,1,1},
      height=225,
      width=900,
      alignment = 3,
    })
    self.createButton({
      label=thumbToggle,
      click_function="toggle",
      function_owner=self,
      position={-0.2,0.2,0.7},
      scale={0.75,0.75,0.75},
      color={0.1,0.1,0.1},
      font_color={1,1,1},
      tooltip='[b]Yes[/b]: flips 2 coins and auto-picks "success"',
      height=225,
      width=900,
      alignment = 3,
    })

end

function toggle()
    if thumbToggle == thumbOFFline then
        thumbToggle = thumbONline
    else
        thumbToggle = thumbOFFline
    end
    self.editButton({
        index = 4,
        label=thumbToggle
    })
end

function flip()
    coin = math.random(1,2)
    coinLine = coinLine..coinStr[coin]
end

function thumb()
    coin1 = math.random(1,2)
    coin2 = math.random(1,2)
    coinLine = coinLine..'['..coinStr[coin1]..coinStr[coin2]..']'
    if coin1 == 2 or coin2 == 2 then
        coin = 2
    else
        coin = 1
    end
end

function printCoin()
    msg = "Successes: "..succ.." | Fails: "..fail
    rgb = {r=1, g=1, b=1}
    broadcastToAll(coinLine..'\n'..msg, rgb)
    coinLine = ''
end

function xCoin()
    succ = 0
    fail = 0
    X=tonumber(self.getInputs()[1].value)
    if X==nil then
        msg = "X must be a number"
        rgb = {r=1, g=1, b=1}
        broadcastToAll(msg, rgb)
        return
    else
        for i=1, X, 1 do
            if thumbToggle == thumbOFFline then
                flip()
            else
                thumb()
            end
            if coin == 2 then
                succ = succ+1
            else
                fail = fail+1
            end
            i = i + 1
        end
        printCoin()
    end
end

function oneCoin()
    succ = 0
    fail = 0
    if thumbToggle == thumbOFFline then
        flip()
    else
        thumb()
    end
    if coin == 2 then
        succ = 1
    else
        fail = 1
    end
    printCoin()
end

function manyCoin()
    succ = 0
    fail = 0
    y = 0
    repeat
        if thumbToggle == thumbOFFline then
            flip()
        else
            thumb()
        end
        if coin == 2 then
            succ = succ+1
        else
            fail = fail+1
        end
    until(coin == 1)
    printCoin()
end

function manyCoin2()
    succ = 0
    fail = 0
    y = 0
    repeat
        if thumbToggle == thumbOFFline then
            flip()
        else
            thumb()
        end
        if coin == 2 then
            succ = succ+1
        else
            fail = fail+1
        end
    until(coin == 2)
    printCoin()
end

function null() end

function onLoad()
  data=Global.getTable('data')
end

function onDrop()
  if Turns.enable then
    ply=Turns.turn_color
    onPlayerTurn(Player[ply])
  end
end

function onPlayerTurn(ply)

  if ply then

    local t={u=0,U='[b]Upkeep Triggers: [/b]',
      d=0,D='[b]Upkeep Damage: %d [/b]',
      c=1,C='[b]Draw Step: %d [/b]',
      l=1,L='[b]Land Drop: %d [/b]'}

    local nodraw=false

    for _,p in pairs(Player.getAvailableColors()) do
      for _,o in pairs(data[p].playmat.getObjects()) do
        if o.tag=='Card'and not o.is_face_down then

          local m=o.getName():gsub('\n.*','')
          local d=o.getDescription()
          local n=m:lower():gsub('%A','')

          local flash=false

          if d~='' then

            -- land drops
            if d:find('Each player may play %w+ additional land%w? on each of') or d:find('Each player may play %w+ additional land%w? during each of') then
              t.l=t.l+1
              flash=true
            end

            if (d:find('You may play %w+ additional land%w? on each of your turns.') or d:find('You may play %w+ additional land%w? during each of your turns.')) and p==ply.color then
              if d:find(' two ') then
                t.l=t.l+2
                flash=true
              else
                t.l=t.l+1
                flash=true
              end
            end

            -- draw
            if d:find('Players can\'t draw cards') then
              nodraw=true
            end

            if d:find('At the beginning of each[^u\n]+draw step, ([^\n]+)') then
              local check=d:match('At the beginning of each[^u\n]+draw step, ([^\n]+)')
              if n=='wellofideas' and p==ply.color then
                t.c=t.c+2
                flash=true
              elseif check:find('an additional card') then
                t.c=t.c+1
                flash=true
              elseif check:find('two additional cards') then
                t.c=t.c+2
                flash=true
              else t.C=t.C..m
                flash=true
              end
            end

            -- upkeep
            if d:find('At the beginning of your[^u\n]+upkeep,') and p==ply.color then
              t.U=t.U..' ['..Color[p]:toHex()..']['..m..'][-] '
              t.u=t.u+1
              flash=true
            end

            if d:find('At the beginning of each[^u\n]+upkeep,') then

              -- local check=d:match('At the beginning of each[^u\n]+upkeep, ([^\n]+)')
              --
              -- if check:find('%d+ damage to that player') and not(n:match('mogisgodof')) then
              --   if d:find("opponent's upkeep") and p~=ply.color then
              --     t.d=t.d+tonumber(check:match('(%d+) damage to that player'))
              --   elseif d:find("player's upkeep") then
              --     t.d=t.d+tonumber(check:match('(%d+) damage to that player'))
              --   end
              -- else
                if d:find("opponent's upkeep") and p~=ply.color then
                  if p~=ply.color then
                    t.U=t.U..' ['..Color[p]:toHex()..']['..m..'][-] '
                    t.u=t.u+1
                    flash=true
                  end
                elseif d:find("player's upkeep") then
                  t.U=t.U..' ['..Color[p]:toHex()..']['..m..'][-] '
                  t.u=t.u+1
                  flash=true
                end
              -- end

            end
          end

          if flash then
            pcall(function()
              Wait.time(function() o.highlightOn(p,0.1) end, 0.2, 5)
              Wait.time(function() o.highlightOn(p,10) end, 1.2)
            end)
          end

        end
      end
    end

    t.D=t.D:format(t.d)
    t.C=t.C:format(t.c)
    t.L=t.L:format(t.l)
    local c=stringColorToRGB(ply.color)

    if nodraw then
      t.c=5
      t.C="[b]Players can't draw cards![/b]"
    end

    if t.d>0 then
      ply.broadcast(t.D)
    end
    if t.c>1 then
      ply.broadcast(t.C)
    end
    if t.l>1 then
      ply.broadcast(t.L)
    end
    if t.u>0 then
      ply.broadcast(t.U)
    end

  end
end

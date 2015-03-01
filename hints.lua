local hints = require "mjolnir.th.hints.internal"
-- If you don't have a C or Objective-C submodule, the above line gets simpler:
-- local foobar = {}
-- Always return your top-level module; never set globals.
local screen = require "mjolnir.screen"
local window = require "mjolnir.window"
local modal_hotkey = require "mjolnir._asm.modal_hotkey"

hints.HINTCHARS = {"s","a","d","f","j","k","l","r","u","g","h","b","m","p","S","A","D","F","J","K","L","R","U","G","H","B","M","P","ws","wa","wd","wf","wj","wk","wl","wr","wu","wg","wh","wb","wm","wp","es","ea","ed","ef","ej","ek","el","er","eu","eg","eh","eb","em","ep","os","oa","od","of","oj","ok","ol","or","ou","og","oh","ob","om","op","vs","va","vd","vf","vj","vk","vl","vr","vu","vg","vh","vb","vm","vp","qs","qa","qd","qf","qj","qk","ql","qr","qu","qg","qh","qb","qm","tp","ts","ta","td","tf","tj","tk","tl","tr","tu","tg","th","tb","tm","tp","yp","ys","ya","yd","yf","yj","yk","yl","yr","yu","yg","yh","yb","ym","yp","zp","zs","za","zd","zf","zj","zk","zl","zr","zu","zg","zh","zb","zm","zp","xp","xs","xa","xd","xf","xj","xk","xl","xr","xu","xg","xh","xb","xm","xp","cp","cs","ca","cd","cf","cj","ck","cl","cr","cu","cg","ch","cb","cm","cp","np","ns","na","nd","nf","nj","nk","nl","nr","nu","ng","nh","nb","nm","np","ip","is","ia","id","if","ij","ik","il","ir","iu","ig","ih","ib","im","ip"}

local usedChars = 0

local openHints = {}
local takenPositions = {}
local hintDict = {}
local modalKey = nil

local bumpThresh = 40^2
local bumpMove = 80
function hints._bumpPos(x,y)
  for i, pos in ipairs(takenPositions) do
    if pos and ((pos.x-x)^2 + (pos.y-y)^2) < bumpThresh then
      return hints._bumpPos(x,y+bumpMove)
    end
  end

  return {x = x,y = y}
end

-- Creates a raw hint
-- x,y are the position of the hint
-- txt is the label, app is a mjolnir app to use for the icon
-- screen is a Mjolnir screen on which to put the hint.
function hints.new(x,y,txt,app,screen)
  local hint = hints.__new(x,y,txt,app,screen)
  table.insert(takenPositions, {x = x, y = y})
  table.insert(openHints, hint)
  return hint
end

-- creates a hint that spreads down if it is overlapping another hint.
function hints.newSpread(x,y,txt,app,screen)
  local c = hints._bumpPos(x,y)
  return hints.new(c.x,c.y,txt,app,screen)
end

-- Creates a hint centered on a window with a key that switches to that
-- window when pressed.
function hints.newWinChar(win,extraTxt)
  local app = win:application()
  if app == nil then return nil end

  -- Allocate a key and enter the mode if we aren't in it
  if usedChars == 0 then
    modalKey:enter()
  end
  usedChars = usedChars + 1
  local char = hints.HINTCHARS[usedChars]

  if char == nil then return nil end

  hintDict[char] = win
  -- char = char .. "1"

  local fr = win:frame()
  local c = {x = fr.x + (fr.w/2), y = fr.y + (fr.h/2)}
  local hint = hints.newSpread(c.x,c.y,char .. extraTxt,app:bundleid(),screen.allscreens()[1])
  return hint
end

-- Close a hint
function hints.close(hint)
  for i,v in ipairs(openHints) do
    if v == hint then
      openHints[i] = nil
      takenPositions[i] = nil
    end
  end
  hint:__close()
end

local pressed = ""

function hints._createHandler(char)
  return function()
    -- check sequence of keys and try to find the window
    pressed = pressed .. char

    local win = hintDict[pressed]
    if win then 
      win:focus() 
      hints.closeAll()
      modalKey:exit()
      pressed = ""
    end
    
  end
end

function hints._setupModal()
  k = modal_hotkey.new({"cmd", "shift"}, "V")
  k:bind({}, 'escape', function() hints.closeAll(); k:exit(); pressed = ""; end)

  -- retrieve all keys needed to be registered
  local characters = {}
  for i, char in ipairs(hints.HINTCHARS) do
    for c in char:gmatch"." do
      
      if characters[c] ~= 1 then
        
        if c == c:lower() then
          modifiers = {}
        else
          modifiers = {'shift'}
        end
        
        k:bind(modifiers, c, hints._createHandler(c))
        characters[c] = 1

      end

    end
  end

  -- print(characters)
  -- register each handler
  for c, i in ipairs(characters) do
    
    print(c, i)

    

  end
  return k
end
modalKey = hints._setupModal()

function hints.activeWindowHints()
  hints.closeAll()

  for i,win in ipairs(window.visiblewindows()) do
    if win:title() ~= "" then
      hints.newWinChar(win,"")
    end
  end
end

-- Create window hints for all open windows for fast switching
function hints.windowHints()
  hints.closeAll()
  for i,win in ipairs(window.allwindows()) do
    if win:isstandard() then
      if win:title() ~= "" then
        hints.newWinChar(win,"")
      end
    end
  end
end

-- Create window hints for a specific app
function hints.appHints(app)
  if app == nil then return end
  hints.closeAll()
  for i,win in ipairs(app:allwindows()) do
    if win:title() ~= "" then
      hints.newWinChar(win,"  " .. win:title())
    end
  end
end

-- Close all hints
function hints.closeAll()
  for i, hint in ipairs(openHints) do
    if hint then hint:__close() end
  end
  openHints = {}
  hintDict = {}
  takenPositions = {}
  usedChars = 0
end

return hints

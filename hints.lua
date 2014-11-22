local hints = require "mjolnir.th.hints.internal"
-- If you don't have a C or Objective-C submodule, the above line gets simpler:
-- local foobar = {}
-- Always return your top-level module; never set globals.
local screen = require "mjolnir.screen"
local window = require "mjolnir.window"
local modal_hotkey = require "mjolnir._asm.modal_hotkey"

local hintChars = {"A","O","E","U","I","D","H","T","N","S","P","G",
                   "M","W","V","J","K","X","B","Y","F"}
local usedChars = 0

local openHints = {}
local takenPositions = {}
local hintDict = {}
local modalKey = nil

local bumpThresh = 40^2
local bumpMove = 80
function hints.bumpPos(x,y)
  for i, pos in ipairs(takenPositions) do
    if pos and ((pos.x-x)^2 + (pos.y-y)^2) < bumpThresh then
      return hints.bumpPos(x,y+bumpMove)
    end
  end

  return {x = x,y = y}
end

function hints.new(x,y,txt,app,screen)
  local hint = hints.__new(x,y,txt,app,screen)
  table.insert(takenPositions, {x = x, y = y})
  table.insert(openHints, hint)
  return hint
end

-- creates a hint that spreads down if it is overlapping another hint.
function hints.newSpread(x,y,txt,app,screen)
  local c = hints.bumpPos(x,y)
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
  local char = hintChars[usedChars+1]
  hintDict[char] = win
  usedChars = usedChars + 1

  local fr = win:frame()
  local c = {x = fr.x + (fr.w/2), y = fr.y + (fr.h/2)}
  local hint = hints.newSpread(c.x,c.y,char .. extraTxt,app:bundleid(),win:screen())
  return hint
end

function hints.close(hint)
  for i,v in ipairs(openHints) do
    if v == hint then
      openHints[i] = nil
      takenPositions[i] = nil
    end
  end
  hint:__close()
end

function hints.createHandler(char)
  return function()
    local win = hintDict[char]
    if win then win:focus() end
    hints.closeAll()
    modalKey:exit()
  end
end

function hints.setupModal()
  k = modal_hotkey.new({"cmd", "shift"}, "V")
  k:bind({}, 'escape', function() hints.closeAll(); k:exit() end)

  for i,c in ipairs(hintChars) do
    k:bind({}, c, hints.createHandler(c))
  end
  return k
end
modalKey = hints.setupModal()

function hints.windowHints()
  hints.closeAll()
  for i,win in ipairs(window.allwindows()) do
    if win:title() ~= "" then
      hints.newWinChar(win,"")
    end
  end
end

function hints.appHints(app)
  if app == nil then return end
  hints.closeAll()
  for i,win in ipairs(app:allwindows()) do
    if win:title() ~= "" then
      hints.newWinChar(win,"  " .. win:title())
    end
  end
end

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

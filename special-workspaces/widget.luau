local STATE_KEY = "special_workspaces"
local MAX_CALLBACKS = 64
local PILL_HEIGHT = 16
local PILL_GAP = 4
local PILL_PADDING = PILL_HEIGHT * 0.3
local ACTIVE_PILL_MIN_WIDTH = PILL_HEIGHT * 2.2
local state = noctalia.state.get(STATE_KEY) or {}
local callbackTargets = {}
local maxLabelChars = tonumber(noctalia.getConfig("max_label_chars")) or 0

local function shellQuote(value)
  return "'" .. string.gsub(value, "'", "'\"'\"'") .. "'"
end

local function callbackName(index)
  return string.format("toggleSpecialWorkspace%02d", index)
end

local function toggleCallback(index)
  local name = callbackTargets[index]
  if name then
    local dispatcher = "hl.dsp.workspace.toggle_special(" .. string.format("%q", name) .. ")"
    local legacy = "hyprctl dispatch togglespecialworkspace " .. shellQuote(name)
    noctalia.runAsync("hyprctl dispatch " .. shellQuote(dispatcher) .. " || " .. legacy)
  end
end

local function displayName(name)
  if maxLabelChars <= 0 then
    return name
  end

  local nextOffset = utf8.offset(name, maxLabelChars + 1)
  if nextOffset then
    return string.sub(name, 1, nextOffset - 1)
  end
  return name
end

-- Declarative UI callbacks must name globals that exist when the script is
-- loaded. Noctalia seals _G afterward, so dynamic callback registration is not
-- available. Each function dispatches through the current target for its slot.
function toggleSpecialWorkspace01() toggleCallback(1) end
function toggleSpecialWorkspace02() toggleCallback(2) end
function toggleSpecialWorkspace03() toggleCallback(3) end
function toggleSpecialWorkspace04() toggleCallback(4) end
function toggleSpecialWorkspace05() toggleCallback(5) end
function toggleSpecialWorkspace06() toggleCallback(6) end
function toggleSpecialWorkspace07() toggleCallback(7) end
function toggleSpecialWorkspace08() toggleCallback(8) end
function toggleSpecialWorkspace09() toggleCallback(9) end
function toggleSpecialWorkspace10() toggleCallback(10) end
function toggleSpecialWorkspace11() toggleCallback(11) end
function toggleSpecialWorkspace12() toggleCallback(12) end
function toggleSpecialWorkspace13() toggleCallback(13) end
function toggleSpecialWorkspace14() toggleCallback(14) end
function toggleSpecialWorkspace15() toggleCallback(15) end
function toggleSpecialWorkspace16() toggleCallback(16) end
function toggleSpecialWorkspace17() toggleCallback(17) end
function toggleSpecialWorkspace18() toggleCallback(18) end
function toggleSpecialWorkspace19() toggleCallback(19) end
function toggleSpecialWorkspace20() toggleCallback(20) end
function toggleSpecialWorkspace21() toggleCallback(21) end
function toggleSpecialWorkspace22() toggleCallback(22) end
function toggleSpecialWorkspace23() toggleCallback(23) end
function toggleSpecialWorkspace24() toggleCallback(24) end
function toggleSpecialWorkspace25() toggleCallback(25) end
function toggleSpecialWorkspace26() toggleCallback(26) end
function toggleSpecialWorkspace27() toggleCallback(27) end
function toggleSpecialWorkspace28() toggleCallback(28) end
function toggleSpecialWorkspace29() toggleCallback(29) end
function toggleSpecialWorkspace30() toggleCallback(30) end
function toggleSpecialWorkspace31() toggleCallback(31) end
function toggleSpecialWorkspace32() toggleCallback(32) end
function toggleSpecialWorkspace33() toggleCallback(33) end
function toggleSpecialWorkspace34() toggleCallback(34) end
function toggleSpecialWorkspace35() toggleCallback(35) end
function toggleSpecialWorkspace36() toggleCallback(36) end
function toggleSpecialWorkspace37() toggleCallback(37) end
function toggleSpecialWorkspace38() toggleCallback(38) end
function toggleSpecialWorkspace39() toggleCallback(39) end
function toggleSpecialWorkspace40() toggleCallback(40) end
function toggleSpecialWorkspace41() toggleCallback(41) end
function toggleSpecialWorkspace42() toggleCallback(42) end
function toggleSpecialWorkspace43() toggleCallback(43) end
function toggleSpecialWorkspace44() toggleCallback(44) end
function toggleSpecialWorkspace45() toggleCallback(45) end
function toggleSpecialWorkspace46() toggleCallback(46) end
function toggleSpecialWorkspace47() toggleCallback(47) end
function toggleSpecialWorkspace48() toggleCallback(48) end
function toggleSpecialWorkspace49() toggleCallback(49) end
function toggleSpecialWorkspace50() toggleCallback(50) end
function toggleSpecialWorkspace51() toggleCallback(51) end
function toggleSpecialWorkspace52() toggleCallback(52) end
function toggleSpecialWorkspace53() toggleCallback(53) end
function toggleSpecialWorkspace54() toggleCallback(54) end
function toggleSpecialWorkspace55() toggleCallback(55) end
function toggleSpecialWorkspace56() toggleCallback(56) end
function toggleSpecialWorkspace57() toggleCallback(57) end
function toggleSpecialWorkspace58() toggleCallback(58) end
function toggleSpecialWorkspace59() toggleCallback(59) end
function toggleSpecialWorkspace60() toggleCallback(60) end
function toggleSpecialWorkspace61() toggleCallback(61) end
function toggleSpecialWorkspace62() toggleCallback(62) end
function toggleSpecialWorkspace63() toggleCallback(63) end
function toggleSpecialWorkspace64() toggleCallback(64) end

local function render()
  local container = barWidget.isVertical() and ui.column or ui.row
  local chips = {}
  callbackTargets = {}

  for index, workspace in ipairs(state) do
    local name = workspace.name
    local hasCallback = index <= MAX_CALLBACKS
    local callback = hasCallback and callbackName(index) or nil
    if hasCallback then
      callbackTargets[index] = name
    end
    table.insert(chips, ui.row({
      key = name,
      height = PILL_HEIGHT,
      minWidth = workspace.active and ACTIVE_PILL_MIN_WIDTH or PILL_HEIGHT,
      paddingH = PILL_PADDING,
      align = "center",
      justify = "center",
      fill = workspace.active and "primary" or "secondary",
      radius = PILL_HEIGHT / 2,
      onClick = callback,
    }, {
      ui.label({
        text = displayName(name),
        fontSize = 11,
        color = workspace.active and "on_primary" or "on_secondary",
      }),
    }))
  end

  barWidget.render(container({ gap = PILL_GAP, align = "center" }, chips))
end

noctalia.state.watch(STATE_KEY, function(value)
  state = type(value) == "table" and value or {}
  render()
end)

render()

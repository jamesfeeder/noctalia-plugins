local STATE_KEY = "special_workspaces"
local PILL_HEIGHT = 16
local PILL_GAP = 4
local PILL_PADDING = PILL_HEIGHT * 0.3
local ACTIVE_PILL_MIN_WIDTH = PILL_HEIGHT * 2.2
local state = noctalia.state.get(STATE_KEY) or {}
local maxLabelChars = tonumber(noctalia.getConfig("max_label_chars")) or 0
local hideInactive = noctalia.getConfig("hide_inactive") == true
local pillRadius = tonumber(noctalia.getConfig("pill_radius")) or 8
local activeStyle = noctalia.getConfig("active_style") or "fill"
local inactiveStyle = noctalia.getConfig("inactive_style") or "fill"

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

local function render()
  local container = barWidget.isVertical() and ui.column or ui.row
  local chips = {}

  for _, workspace in ipairs(state) do
    if workspace.active or not hideInactive then
      local name = workspace.name
      local style = workspace.active and activeStyle or inactiveStyle
      local filled = style == "fill"
      local fill = filled
          and (workspace.active and "primary" or "secondary")
        or "#00000000"
      local textColor = filled
          and (workspace.active and "on_primary" or "on_secondary")
        or (workspace.active and "primary" or "on_surface")
      table.insert(chips, ui.row({
        key = name,
        height = PILL_HEIGHT,
        minWidth = workspace.active and ACTIVE_PILL_MIN_WIDTH or PILL_HEIGHT,
        paddingH = PILL_PADDING,
        align = "center",
        justify = "center",
        fill = fill,
        radius = pillRadius,
      }, {
        ui.label({
          text = displayName(name),
          fontSize = 11,
          color = textColor,
        }),
      }))
    end
  end

  barWidget.render(container({ gap = PILL_GAP, align = "center" }, chips))
end

noctalia.state.watch(STATE_KEY, function(value)
  state = type(value) == "table" and value or {}
  render()
end)

function onConfigChanged()
  maxLabelChars = tonumber(noctalia.getConfig("max_label_chars")) or 0
  hideInactive = noctalia.getConfig("hide_inactive") == true
  pillRadius = tonumber(noctalia.getConfig("pill_radius")) or 8
  activeStyle = noctalia.getConfig("active_style") or "fill"
  inactiveStyle = noctalia.getConfig("inactive_style") or "fill"
  render()
end

render()

local STATE_KEY = "special_workspaces"
local PILL_HEIGHT = 16
local PILL_GAP = 4
local state = noctalia.state.get(STATE_KEY) or {}
local maxLabelChars = tonumber(noctalia.getConfig("max_label_chars")) or 0
local hideInactive = noctalia.getConfig("hide_inactive") == true
local capsuleRadius = math.max(0, tonumber(noctalia.getConfig("capsule_radius")) or 8)
local capsulePadding = math.max(0, tonumber(noctalia.getConfig("capsule_padding")) or 5)
local capsuleMinWidth = math.max(0, tonumber(noctalia.getConfig("capsule_min_width")) or 35)
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
        minWidth = capsuleMinWidth,
        paddingH = capsulePadding,
        align = "center",
        justify = "center",
        fill = fill,
        radius = capsuleRadius,
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
  capsuleRadius = math.max(0, tonumber(noctalia.getConfig("capsule_radius")) or 8)
  capsulePadding = math.max(0, tonumber(noctalia.getConfig("capsule_padding")) or 5)
  capsuleMinWidth = math.max(0, tonumber(noctalia.getConfig("capsule_min_width")) or 35)
  activeStyle = noctalia.getConfig("active_style") or "fill"
  inactiveStyle = noctalia.getConfig("inactive_style") or "fill"
  render()
end

render()

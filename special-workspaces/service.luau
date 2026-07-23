-- Publishes populated or active Hyprland special workspaces to the plugin state
-- channel.
-- Hyprland's event socket gives immediate refreshes; polling is kept as a
-- recovery path when socat/the socket cannot provide events.

local STATE_KEY = "special_workspaces"
local POLL_INTERVAL_MS = 5000
local SEPARATOR = "__NOCTALIA_SPECIAL_WORKSPACES_MONITORS__"
local STREAM_RETRY_MARKER = "__NOCTALIA_SPECIAL_WORKSPACES_STREAM_RETRY__"

local polling = true
local loggedPolling = false
local loggedSnapshotError = false
local refreshInFlight = false

local function logPolling(reason)
  if not loggedPolling then
    noctalia.log("Special workspaces: polling every 5 seconds (" .. reason .. ")")
    loggedPolling = true
  end
end

local function logSnapshotError(message)
  if not loggedSnapshotError then
    noctalia.log("Special workspaces: " .. message .. "; retaining last state")
    loggedSnapshotError = true
  end
end

local function shellQuote(value)
  return "'" .. string.gsub(value, "'", "'\"'\"'") .. "'"
end

local function specialName(value)
  if type(value) ~= "string" then
    return nil
  end

  local name = string.match(value, "^special:(.+)$")
  if name and name ~= "" then
    return name
  end
  return nil
end

local function snapshotFromJson(clientsJson, monitorsJson)
  local clients, clientErr = noctalia.json.decode(clientsJson)
  local monitors, monitorErr = noctalia.json.decode(monitorsJson)
  if type(clients) ~= "table" or type(monitors) ~= "table" then
    return nil, "invalid Hyprland JSON" .. (clientErr and (": " .. clientErr) or (monitorErr and (": " .. monitorErr) or ""))
  end

  local workspaces = {}
  for _, client in ipairs(clients) do
    local workspace = client.workspace
    local name = workspace and specialName(workspace.name)
    if name then
      local item = workspaces[name]
      if not item then
        item = { name = name, windowCount = 0, active = false }
        workspaces[name] = item
      end
      item.windowCount = item.windowCount + 1
    end
  end

  for _, monitor in ipairs(monitors) do
    local special = monitor.specialWorkspace
    local name = special and specialName(special.name)
    if name then
      local item = workspaces[name]
      if not item then
        item = { name = name, windowCount = 0, active = false }
        workspaces[name] = item
      end
      item.active = true
    end
  end

  local result = {}
  for _, item in pairs(workspaces) do
    table.insert(result, item)
  end
  table.sort(result, function(a, b) return a.name < b.name end)
  return result
end

local function publishSnapshot(clientsJson, monitorsJson)
  local state, err = snapshotFromJson(clientsJson, monitorsJson)
  if not state then
    -- Keep the last valid state during temporary compositor command failures.
    logSnapshotError("snapshot failed (" .. err .. ")")
    return false
  end
  loggedSnapshotError = false
  noctalia.state.set(STATE_KEY, state)
  return true
end

local function refresh()
  if refreshInFlight then
    return
  end
  refreshInFlight = true
  local started = noctalia.runAsync("hyprctl -j clients; printf '\\n" .. SEPARATOR .. "\\n'; hyprctl -j monitors", function(result)
    refreshInFlight = false
    if result.exitCode ~= 0 then
      logSnapshotError("hyprctl failed")
      return
    end

    local markerStart, markerEnd = string.find(result.stdout, "\n" .. SEPARATOR .. "\n", 1, true)
    if not markerStart then
      logSnapshotError("incomplete hyprctl snapshot")
      return
    end
    publishSnapshot(string.sub(result.stdout, 1, markerStart - 1), string.sub(result.stdout, markerEnd + 1))
  end)
  if not started then
    refreshInFlight = false
    logSnapshotError("could not start hyprctl snapshot")
  end
end

local refreshEvents = {
  activespecial = true,
  activespecialv2 = true,
  openwindow = true,
  closewindow = true,
  movewindow = true,
  movewindowv2 = true,
  workspace = true,
  workspacev2 = true,
  focusedmon = true,
  focusedmonv2 = true,
  createworkspace = true,
  createworkspacev2 = true,
  destroyworkspace = true,
  destroyworkspacev2 = true,
  moveworkspace = true,
  moveworkspacev2 = true,
  renameworkspace = true,
  monitoradded = true,
  monitoraddedv2 = true,
  monitorremoved = true,
}

local function enablePolling(reason)
  polling = true
  logPolling(reason)
  refresh()
end

local function startEventStream()
  if not noctalia.commandExists("socat") then
    enablePolling("socat is unavailable")
    return
  end

  local runtimeDir = noctalia.getenv("XDG_RUNTIME_DIR")
  local signature = noctalia.getenv("HYPRLAND_INSTANCE_SIGNATURE")
  if not runtimeDir or not signature then
    enablePolling("Hyprland environment is unavailable")
    return
  end

  local socket = runtimeDir .. "/hypr/" .. signature .. "/.socket2.sock"
  -- Keep a single helper alive across temporary socket failures. Noctalia stops
  -- the complete stream command automatically when this service exits.
  local command = "while true; do socat -u UNIX-CONNECT:" .. shellQuote(socket)
    .. " - 2>&1; printf '" .. STREAM_RETRY_MARKER .. "\\n'; sleep 5; done"
  local started = noctalia.runStream(command, function(line)
    if line == STREAM_RETRY_MARKER then
      enablePolling("event stream reconnecting")
      return
    end

    local event = string.match(line, "^([%a%d_]+)>>")
    if event then
      polling = false
      loggedPolling = false
      if refreshEvents[event] then
        refresh()
      end
    elseif string.find(line, "socat", 1, true) or string.find(line, "error", 1, true) then
      enablePolling("event socket error")
    end
  end)

  if not started then
    enablePolling("could not start socat")
  else
    -- Until an event proves the stream healthy, polling provides the fallback.
    logPolling("waiting for the Hyprland event stream")
  end
end

noctalia.setUpdateInterval(POLL_INTERVAL_MS)
refresh()
startEventStream()

function update()
  if polling then
    refresh()
  end
end

function onOutputsChanged()
  refresh()
end

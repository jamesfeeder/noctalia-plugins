local scriptPath = arg[0] or ""
local pluginDir = string.match(scriptPath, "^(.*)/tests/[^/]+$")
assert(pluginDir, "run this test from its tests directory path")

local function shellQuote(value)
  return "'" .. string.gsub(value, "'", "'\"'\"'") .. "'"
end

local function writeFile(path, content)
  local file = assert(io.open(path, "w"))
  file:write(content)
  file:close()
end

local function readFile(path)
  local file = assert(io.open(path, "r"))
  local content = file:read("*a")
  file:close()
  return content
end

local function commandSucceeded(result)
  if type(result) == "number" then
    return result == 0
  end
  return result == true
end

local function loadService(failureLimit)
  local fixtureDir = os.tmpname()
  os.remove(fixtureDir)
  assert(commandSucceeded(os.execute("mkdir " .. shellQuote(fixtureDir))))

  local binDir = fixtureDir .. "/bin"
  assert(commandSucceeded(os.execute("mkdir " .. shellQuote(binDir))))

  local counterPath = fixtureDir .. "/counter"
  local failureLimitPath = fixtureDir .. "/failure-limit"
  local outputPath = fixtureDir .. "/stdout"
  local hyprctlPath = binDir .. "/hyprctl"
  local sleepPath = binDir .. "/sleep"

  writeFile(counterPath, "0")
  writeFile(failureLimitPath, tostring(failureLimit))
  writeFile(hyprctlPath, "#!/bin/sh\n"
    .. "count=$(cat " .. shellQuote(counterPath) .. ")\n"
    .. "count=$((count + 1))\n"
    .. "printf '%s' \"$count\" > " .. shellQuote(counterPath) .. "\n"
    .. "failure_limit=$(cat " .. shellQuote(failureLimitPath) .. ")\n"
    .. "[ \"$count\" -le \"$failure_limit\" ] && exit 1\n"
    .. "printf '[]\\n'\n")
  writeFile(sleepPath, "#!/bin/sh\nexit 0\n")
  assert(commandSucceeded(os.execute(
    "chmod +x " .. shellQuote(hyprctlPath) .. " " .. shellQuote(sleepPath)
  )))

  local fixture = { published = 0 }
  function fixture.snapshotCalls()
    return tonumber(readFile(counterPath))
  end
  function fixture.setFailureLimit(value)
    writeFile(failureLimitPath, tostring(value))
  end
  function fixture.cleanup()
    os.remove(counterPath)
    os.remove(failureLimitPath)
    os.remove(outputPath)
    os.remove(hyprctlPath)
    os.remove(sleepPath)
    assert(commandSucceeded(os.execute("rmdir " .. shellQuote(binDir))))
    assert(commandSucceeded(os.execute("rmdir " .. shellQuote(fixtureDir))))
  end

  noctalia = {
    json = {
      decode = function(value)
        if string.match(value, "^%s*%[%]%s*$") then
          return {}
        end
        return nil, "invalid fixture"
      end,
    },
    state = {
      set = function()
        fixture.published = fixture.published + 1
      end,
    },
    log = function() end,
    commandExists = function()
      return true
    end,
    getenv = function(name)
      if name == "XDG_RUNTIME_DIR" then
        return "/tmp"
      end
      return "fixture"
    end,
    runAsync = function(command, callback)
      local invocation = "export PATH=" .. shellQuote(binDir) .. ":$PATH; "
        .. "{ " .. command .. "; } > " .. shellQuote(outputPath) .. " 2>/dev/null"
      local result, _, exitCode = os.execute(invocation)
      callback({
        exitCode = commandSucceeded(result) and 0 or (exitCode or 1),
        stdout = readFile(outputPath),
      })
      return true
    end,
    runStream = function()
      return true
    end,
  }

  dofile(pluginDir .. "/service.luau")
  return fixture
end

local oneFailure = loadService(1)
assert(oneFailure.snapshotCalls() == 3, "one failure should retry the complete snapshot")
assert(oneFailure.published == 1, "successful first retry should publish")
oneFailure.cleanup()

local twoFailures = loadService(2)
assert(twoFailures.snapshotCalls() == 4, "two failures should retry the complete snapshot twice")
assert(twoFailures.published == 1, "successful second retry should publish")
twoFailures.cleanup()

local exhausted = loadService(99)
assert(exhausted.snapshotCalls() == 3, "snapshot should stop after three attempts")
assert(exhausted.published == 0, "failed snapshots must not replace state")

exhausted.setFailureLimit(exhausted.snapshotCalls())
onOutputsChanged()
assert(exhausted.snapshotCalls() == 5, "a new event should start a fresh snapshot")
assert(exhausted.published == 1, "a later successful event should publish")
exhausted.cleanup()

print("service retry tests passed")

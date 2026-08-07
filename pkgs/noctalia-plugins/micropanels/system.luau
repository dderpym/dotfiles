--!nonstrict
-- Live system graphs: CPU, RAM and CPU temperature sparklines, opened from the
-- bar's sysmon group (cpu / ram / temp widgets).
--
-- Fed by the shell's own system monitor (noctalia.systemStats()) — the same
-- sample the bar widgets and the control center System tab use, so no extra
-- polling is added. First call opts this entry into the CPU temp probe; the
-- bar already keeps the monitor running.

local HISTORY = 30
local cpuHist, ramHist, tempHist = {}, {}, {}
local cpuNow, ramNow, tempNow = 0, 0, nil

local function push(t, v)
  table.insert(t, v)
  if #t > HISTORY then table.remove(t, 1) end
end

local function graphRow(glyphName, color, label, hist)
  return ui.row({ gap = 10, align = "center" }, {
    ui.glyph({ name = glyphName, size = 16, color = color }),
    ui.label({ text = label, fontSize = 12, fontWeight = "bold", color = "on_surface", flexGrow = 1 }),
    ui.graph({ values = hist, width = 130, height = 30, color = color, lineWidth = 2, fillOpacity = 0.25 }),
  })
end

local function render()
  panel.render(ui.column({ gap = 12 }, {
    graphRow("cpu", "primary", string.format("CPU %d%%", cpuNow), cpuHist),
    graphRow("database", "secondary", string.format("RAM %d%%", ramNow), ramHist),
    graphRow(
      "temperature",
      "tertiary",
      tempNow ~= nil and string.format("CPU %d°C", tempNow) or "CPU --°C",
      tempHist
    ),
  }))
end

local function sample()
  local s = noctalia.systemStats()
  if s == nil then return end
  cpuNow = math.floor(s.cpu.usagePercent + 0.5)
  ramNow = math.floor(s.ram.usagePercent + 0.5)
  push(cpuHist, s.cpu.usagePercent / 100)
  push(ramHist, s.ram.usagePercent / 100)
  if s.cpu.tempC ~= nil then
    tempNow = math.floor(s.cpu.tempC + 0.5)
    push(tempHist, s.cpu.tempC / 100)
  end
  render()
end

function onOpen()
  sample()
end

-- Ticks only run while the panel is open; 2s matches [system.monitor] cpu_poll_seconds.
function update()
  noctalia.setUpdateInterval(2000)
  sample()
end

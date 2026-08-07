--!nonstrict
-- Compact brightness popup: a slider for the display backlight, opened from
-- the bar's brightness widget.
--
-- Reads the first writable sysfs backlight device (percent of max_brightness);
-- writes go through `noctalia msg brightness-set` so the shell's OSD stays in
-- sync with the bar widget.

local pct = 0
local device = nil

local function refreshDevice()
  if device ~= nil then return end
  local names = noctalia.listDir("/sys/class/backlight")
  if names == nil then return end
  for _, name in ipairs(names) do
    local max = tonumber(noctalia.readFile("/sys/class/backlight/" .. name .. "/max_brightness"))
    if max ~= nil and max > 0 then
      device = name
      return
    end
  end
end

local function render()
  panel.render(ui.column({ gap = 12 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.label({ text = "Brightness", fontSize = 14, fontWeight = "bold", color = "on_surface" }),
      ui.label({ text = string.format("%d%%", pct), fontSize = 13, fontWeight = "bold", color = "secondary" }),
    }),
    ui.slider({ min = 0, max = 100, step = 1, value = pct, onChange = "onBrightness" }),
  }))
end

local function read()
  refreshDevice()
  if device == nil then return end
  local b = tonumber(noctalia.readFile("/sys/class/backlight/" .. device .. "/brightness"))
  local m = tonumber(noctalia.readFile("/sys/class/backlight/" .. device .. "/max_brightness"))
  if b ~= nil and m ~= nil and m > 0 then
    pct = math.floor(b / m * 100 + 0.5)
    render()
  end
end

function onOpen()
  read()
end

function update()
  noctalia.setUpdateInterval(2000)
  read()
end

function onBrightness(value)
  local v = tonumber(value) or pct
  if v == pct then return end
  pct = v
  render()
  noctalia.runAsync("noctalia msg brightness-set " .. tostring(v))
end

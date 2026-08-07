--!nonstrict
-- Compact volume popup: slider + mute + percentage, opened from the bar's
-- volume widget (panel entry: open_near_click = true).
--
-- Reads come from wpctl (wireplumber's ground truth for the default sink);
-- writes go through `noctalia msg volume-set / volume-mute` so the shell's
-- OSD and sound effects stay in sync with the bar widget's own scroll/click
-- handling.

local SINK = "@DEFAULT_AUDIO_SINK@"

local vol = 0
local muted = false

local function render()
  panel.render(ui.column({ gap = 12 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.label({ text = "Volume", fontSize = 14, fontWeight = "bold", color = "on_surface" }),
      ui.label({ text = string.format("%d%%", vol), fontSize = 13, fontWeight = "bold", color = "tertiary" }),
    }),
    ui.slider({ min = 0, max = 100, step = 1, value = vol, onChange = "onVolume" }),
    ui.row({ gap = 8, align = "center" }, {
      ui.button({
        text = muted and "Unmute" or "Mute",
        controlSize = "sm",
        variant = muted and "primary" or "ghost",
        onClick = "onMute",
      }),
      ui.spacer(),
      ui.button({
        glyph = "settings",
        glyphSize = 14,
        controlSize = "sm",
        variant = "ghost",
        tooltip = "Open pavucontrol",
        onClick = "onMore",
      }),
    }),
  }))
end

local function read()
  noctalia.runAsync("wpctl get-volume " .. SINK, function(res)
    local out = res.stdout or ""
    local v = tonumber(string.match(out, "Volume: (%d+%.?%d*)"))
    if v == nil then return end
    vol = math.floor(v * 100 + 0.5)
    muted = string.find(out, "%[MUTED%]") ~= nil
    render()
  end)
end

function onOpen()
  read()
end

-- Ticks only run while the panel is open, so this just keeps the slider in
-- sync when the volume changes from elsewhere (media keys, another app).
function update()
  noctalia.setUpdateInterval(2000)
  read()
end

function onVolume(value)
  local v = tonumber(value) or vol
  if v == vol then return end
  vol = v
  render()
  -- Refresh from wpctl after the write so the slider tracks the sink truth.
  noctalia.runAsync("noctalia msg volume-set " .. tostring(v), function() read() end)
end

function onMute()
  muted = not muted
  render()
  noctalia.runAsync("noctalia msg volume-mute", function() read() end)
end

function onMore()
  noctalia.runAsync("pwvucontrol || pavucontrol")
end

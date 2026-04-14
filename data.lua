local function icon(path)
  return {
    icon = path,
    icon_size = 64,
    icon_mipmaps = 4
  }
end

data:extend({
  {
    type = "virtual-signal",
    name = "signal-st-provider",
    localised_name = {"virtual-signal-name.signal-st-provider"},
    subgroup = "virtual-signal-special",
    order = "z[st]-a[provider]",
    icons = { icon("__base__/graphics/icons/signal/signal_1.png") }
  },
  {
    type = "virtual-signal",
    name = "signal-st-requester",
    localised_name = {"virtual-signal-name.signal-st-requester"},
    subgroup = "virtual-signal-special",
    order = "z[st]-b[requester]",
    icons = { icon("__base__/graphics/icons/signal/signal_2.png") }
  },
  {
    type = "virtual-signal",
    name = "signal-st-threshold",
    localised_name = {"virtual-signal-name.signal-st-threshold"},
    subgroup = "virtual-signal-special",
    order = "z[st]-c[threshold]",
    icons = { icon("__base__/graphics/icons/signal/signal_3.png") }
  },
  {
    type = "virtual-signal",
    name = "signal-st-hub",
    localised_name = {"virtual-signal-name.signal-st-hub"},
    subgroup = "virtual-signal-special",
    order = "z[st]-d[hub]",
    icons = { icon("__base__/graphics/icons/signal/signal_4.png") }
  },
  {
    type = "virtual-signal",
    name = "signal-st-fuel",
    localised_name = {"virtual-signal-name.signal-st-fuel"},
    subgroup = "virtual-signal-special",
    order = "z[st]-e[fuel]",
    icons = { icon("__base__/graphics/icons/signal/signal_5.png") }
  }
})

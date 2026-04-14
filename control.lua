local PROVIDER = "signal-st-provider"
local REQUESTER = "signal-st-requester"
local THRESHOLD = "signal-st-threshold"
local HUB = "signal-st-hub"
local FUEL = "signal-st-fuel"

local function init_storage()
  storage.stations = storage.stations or {}
end

local function signal_value(signals, signal_name)
  if not signals then
    return 0
  end

  for _, signal in pairs(signals) do
    if signal.signal and signal.signal.type == "virtual" and signal.signal.name == signal_name then
      return signal.count
    end
  end

  return 0
end

local function item_signals(signals)
  local items = {}
  if not signals then
    return items
  end

  for _, signal in pairs(signals) do
    if signal.signal and signal.signal.type == "item" and signal.count > 0 then
      items[signal.signal.name] = signal.count
    end
  end

  return items
end

local function get_stop_network(stop)
  if defines.wire_connector_id then
    return stop.get_circuit_network(defines.wire_connector_id.circuit_red)
      or stop.get_circuit_network(defines.wire_connector_id.circuit_green)
  end

  return stop.get_circuit_network(defines.wire_type.red)
    or stop.get_circuit_network(defines.wire_type.green)
end

local function station_snapshot(stop)
  local network = get_stop_network(stop)
  local signals = network and network.signals or nil

  return {
    unit_number = stop.unit_number,
    stop = stop,
    force_index = stop.force_index,
    surface_index = stop.surface_index,
    name = stop.backer_name,
    is_provider = signal_value(signals, PROVIDER) > 0,
    is_requester = signal_value(signals, REQUESTER) > 0,
    is_hub = signal_value(signals, HUB) > 0,
    is_fuel = signal_value(signals, FUEL) > 0,
    threshold = math.max(1, signal_value(signals, THRESHOLD)),
    items = item_signals(signals)
  }
end

local function refresh_stations()
  storage.stations = {}

  for _, surface in pairs(game.surfaces) do
    local stops = surface.find_entities_filtered({ type = "train-stop" })
    for _, stop in pairs(stops) do
      storage.stations[stop.unit_number] = station_snapshot(stop)
    end
  end
end

local function train_looks_dispatchable(train)
  return train.valid
    and train.state == defines.train_state.wait_station
    and train.schedule
    and train.schedule.records
    and #train.schedule.records <= 2
end

local function find_idle_train(hub_station)
  local trains = hub_station.stop.get_train_stop_trains()
  for _, train in pairs(trains) do
    if train_looks_dispatchable(train) then
      return train
    end
  end
  return nil
end

local function make_wait_record(station_name, inactivity_ticks)
  return {
    station = station_name,
    wait_conditions = { { type = "inactivity", ticks = inactivity_ticks } }
  }
end

local function create_schedule(hub, provider, requester, fuel)
  local records = {
    make_wait_record(provider.name, 180),
    make_wait_record(requester.name, 300)
  }

  if fuel then
    table.insert(records, make_wait_record(fuel.name, 180))
  end

  table.insert(records, make_wait_record(hub.name, 60 * 60 * 3))

  return { current = 1, records = records }
end

local function pick_matching_fuel_station(fuel_stations, requester)
  for _, fuel in pairs(fuel_stations) do
    if fuel.force_index == requester.force_index and fuel.surface_index == requester.surface_index then
      return fuel
    end
  end

  return nil
end

local function dispatch_once()
  local providers = {}
  local requesters = {}
  local hubs = {}
  local fuel_stations = {}

  for _, station in pairs(storage.stations) do
    if station.stop and station.stop.valid then
      if station.is_provider then
        table.insert(providers, station)
      elseif station.is_requester then
        table.insert(requesters, station)
      elseif station.is_hub then
        table.insert(hubs, station)
      elseif station.is_fuel then
        table.insert(fuel_stations, station)
      end
    end
  end

  if #hubs == 0 then
    return
  end

  for _, requester in pairs(requesters) do
    for item_name, requested in pairs(requester.items) do
      if requested >= requester.threshold then
        for _, provider in pairs(providers) do
          local available = provider.items[item_name] or 0
          local same_network = provider.force_index == requester.force_index and provider.surface_index == requester.surface_index

          if available >= provider.threshold and same_network then
            for _, hub in pairs(hubs) do
              if hub.force_index == requester.force_index and hub.surface_index == requester.surface_index then
                local train = find_idle_train(hub)
                if train then
                  local fuel = pick_matching_fuel_station(fuel_stations, requester)
                  train.schedule = create_schedule(hub, provider, requester, fuel)
                  return
                end
              end
            end
          end
        end
      end
    end
  end
end

script.on_init(function()
  init_storage()
  refresh_stations()
end)

script.on_configuration_changed(function()
  init_storage()
  refresh_stations()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == "simplify-train-refresh-ticks" then
    storage.next_refresh = nil
  end
end)

script.on_nth_tick(60, function(event)
  init_storage()

  local refresh_rate = settings.global["simplify-train-refresh-ticks"].value
  storage.next_refresh = storage.next_refresh or event.tick

  if event.tick >= storage.next_refresh then
    refresh_stations()
    dispatch_once()
    storage.next_refresh = event.tick + refresh_rate
  end
end)

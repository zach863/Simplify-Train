# Simplify Train (Factorio mod)

A tiny train dispatcher inspired by Logistic Train Network (LTN), but intentionally simpler.

## What it does

- Uses **train stop circuit signals** to tag stations as:
  - `ST Provider` (`signal-st-provider` > 0)
  - `ST Requester` (`signal-st-requester` > 0)
  - `ST Hub` (`signal-st-hub` > 0) — where idle trains wait
  - `ST Fuel` (`signal-st-fuel` > 0) — optional fueling stop after deliveries
- Reads positive **item signals** on station circuit network.
- If a requester has an item signal above threshold and a provider has supply for the same item, it assigns an idle train from a matching hub to run:
  1. Provider
  2. Requester
  3. Fuel (optional)
  4. Hub (return + wait)

## Signals

- `ST Provider` virtual signal toggles provider mode.
- `ST Requester` virtual signal toggles requester mode.
- `ST Hub` virtual signal marks waiting depots.
- `ST Fuel` virtual signal marks fuel service stations.
- `ST Threshold` sets minimum count for requests/supply matching (default 1).

## Runtime setting

- `simplify-train-refresh-ticks` controls how often dispatcher scans and matches stations.

## Current limitations (by design)

- No priority queues or multi-request batching.
- First-match dispatch strategy.
- Assumes station names are unique enough for schedules.
- Fuel stop selection is first matching station on same surface/force.

## Setup quickstart

1. Build one or more `ST Hub` stops and park trains there with a simple idle schedule.
2. Mark loading stations with `ST Provider` and output item counts via circuit.
3. Mark unloading stations with `ST Requester` and request item counts via circuit.
4. Optionally mark refuel stations with `ST Fuel`.
5. Set `ST Threshold` where you want request/supply gating.

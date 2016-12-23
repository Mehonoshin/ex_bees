# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ex_bees,
  honeycombs_number: 3,
  bees_per_honeycomb: 3,
  map_width: 1000,
  map_height: 1000,
  tick_period: 100,
  bee_step: 5

config :logger,
  backends: [:console]

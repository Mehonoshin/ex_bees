# ExBees

Electronic bees lifecyle emulator written on Elixir.
The main purpose of project is to provide better understanding and experience with complicated OTP applications.

Highly inspired by [Black Mirror](https://en.wikipedia.org/wiki/Hated_in_the_Nation_(Black_Mirror)) series.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `ex_bees` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_bees, "~> 0.1.0"}]
    end
    ```

  2. Ensure `ex_bees` is started before your application:

    ```elixir
    def application do
      [applications: [:ex_bees]]
    end
    ```

## Domain area

* World - a map, for simplicity square, that contains all kinds of objects.
* Bee - Autonomous Drone Insect
* Honeycomb - spawnpoint for bees, warehouse for honey
* Flower - temporary point, that can hold single bee for specified amount of time
* Trap - danger point, that destroys a bee

## Implentation
TBD

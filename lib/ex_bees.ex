defmodule ExBees do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Web.Router, [], [
        dispatch: dispatch,
        port: Application.get_env(:ex_bees, :http_port)
      ]),
      supervisor(ExBees.WorldSupervisor, [ExBees.WorldSupervisor])
    ]

    opts = [strategy: :one_for_one, name: ExBees.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_, [
        {"/ws", ExBees.SocketHandler, []},
        {:_, Plug.Adapters.Cowboy.Handler, {Web.Router, []}}
      ]}
    ]
  end
end

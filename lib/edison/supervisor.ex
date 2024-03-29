defmodule Edison.Supervisor do
  use Supervisor

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      Edison.Consumer,
      Edison.Mechmarket,
      {Plug.Cowboy, scheme: :http, plug: Edison.Healthcheck, options: [port: 4000]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

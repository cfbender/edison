defmodule Edison do
  use Application

  def start(_type, _args) do
    IO.puts("Starting Edison")
    Edison.Supervisor.start_link()
  end
end

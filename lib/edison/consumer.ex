defmodule Edison.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  @spec start_link :: Supervisor.on_start()
  def start_link do
    Consumer.start_link(__MODULE__, max_restarts: 0)
  end

  @impl true
  @spec handle_event(Nostrum.Consumer.event()) :: any()
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!ping" ->
        Api.create_message(msg.channel_id, "pong")

      _ ->
        :ignore
    end
  end

  # default handler
  def handle_event(_event) do
    :noop
  end
end

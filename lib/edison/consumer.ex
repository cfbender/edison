defmodule Edison.Consumer do
  use Nostrum.Consumer

  alias Edison.Commands

  @impl true
  @spec handle_event(Nostrum.Consumer.event()) :: any()
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Commands.handle_command(msg)
  end

  # default handler
  def handle_event(_event) do
    :noop
  end
end

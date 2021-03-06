defmodule Edison.Commands do
  alias Nostrum.Api
  alias Edison.Roles

  @prefix "!edison"

  @spec handle_command(Nostrum.Struct.Message.t()) :: any()
  def handle_command(msg) do
    cond do
      String.starts_with?(msg.content, @prefix) ->
        command = String.replace_leading(msg.content, "#{@prefix} ", "")

        case command do
          "ping" ->
            Api.create_message(msg.channel_id, "pong")

          "give_role " <> role ->
            case role do
              "mechmarket" ->
                Roles.add_role("mechmarket_role_id", msg)
                Api.delete_message(msg.channel_id, msg.id)

              "vaccine" ->
                Roles.add_role("vaccine_role_id", msg)
                Api.delete_message(msg.channel_id, msg.id)

              _ ->
                :ignore
            end

          "remove_role " <> role ->
            case role do
              "mechmarket" ->
                Roles.remove_role("mechmarket_role_id", msg)
                Api.delete_message(msg.channel_id, msg.id)

              "vaccine" ->
                Roles.remove_role("vaccine_role_id", msg)
                Api.delete_message(msg.channel_id, msg.id)

              _ ->
                :ignore
            end

          _ ->
            :ignore
        end

      true ->
        :ignore
    end
  end
end

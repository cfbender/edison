defmodule Edison.Commands do
  alias Nostrum.Api

  @prefix "!edison"

  @spec handle_command(Nostrum.Struct.Message.t()) :: any()
  def handle_command(msg) do
    cond do
      String.starts_with?(msg.content, @prefix) ->
        command = String.replace_leading(msg.content, "#{@prefix} ", "")

        case command do
          "ping" ->
            Api.create_message(msg.channel_id, "pong")

          "give_role mechmarket" ->
            mechmarket_role_id = Application.fetch_env!(:edison, :mechmarket_role_id)

            mechmarket_role_name =
              Api.get_guild_roles!(msg.guild_id)
              |> Enum.find(fn role -> role.id == mechmarket_role_id end)
              |> Map.get(:name)

            Api.add_guild_member_role(msg.guild_id, msg.author.id, mechmarket_role_id)

            Api.create_message(
              msg.channel_id,
              "Added role @#{mechmarket_role_name} to <@#{msg.author.id}>"
            )

          _ ->
            :ignore
        end

      true ->
        :ignore
    end
  end
end

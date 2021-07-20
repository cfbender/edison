defmodule Edison.Roles do
  alias Nostrum.Api

  @spec add_role(String.t(), Nostrum.Struct.Message.t()) :: any()
  def add_role(config_name, msg) do
    role_id = Application.fetch_env!(:edison, String.to_atom(config_name))

    role_name =
      Api.get_guild_roles!(msg.guild_id)
      |> Enum.find(fn role -> role.id == role_id end)
      |> Map.get(:name)

    Api.add_guild_member_role(msg.guild_id, msg.author.id, role_id)
  end

  @spec remove_role(String.t(), Nostrum.Struct.Message.t()) :: any()
  def remove_role(config_name, msg) do
    role_id = Application.fetch_env!(:edison, String.to_atom(config_name))

    role_name =
      Api.get_guild_roles!(msg.guild_id)
      |> Enum.find(fn role -> role.id == role_id end)
      |> Map.get(:name)

    Api.remove_guild_member_role(msg.guild_id, msg.author.id, role_id)
  end
end

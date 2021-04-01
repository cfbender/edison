import Config

config :nostrum,
  token: System.get_env("EDISON_BOT_TOKEN"),
  num_shards: :auto

config :edison,
  mechmarket_role_id: System.get_env("EDISON_MECHMARKET_ROLE_ID") |> String.to_integer(),
  mechmarket_channel: System.get_env("EDISON_MECHMARKET_CHANNEL") |> String.to_integer(),
  mechmarket_query: System.get_env("EDISON_MECHMARKET_QUERY"),
  covid_channel: System.get_env("EDISON_COVID_CHANNEL") |> String.to_integer(),
  vaccine_role_id: System.get_env("EDISON_VACCINE_ROLE_ID") |> String.to_integer()

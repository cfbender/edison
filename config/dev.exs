import Config

import_config "dev.secret.exs"

config :edison,
  mechmarket_role_id: System.get_env("EDISON_MECHMARKET_ROLE_ID") |> String.to_integer(),
  mechmarket_channel: System.get_env("EDISON_MECHMARKET_CHANNEL") |> String.to_integer(),
  mechmarket_query: System.get_env("EDISON_MECHMARKET_QUERY"),
  covid_channel: System.get_env("EDISON_COVID_CHANNEL") |> String.to_integer()

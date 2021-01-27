import Config

config :nostrum,
  token: System.get_env("EDISON_BOT_TOKEN"),
  num_shards: :auto

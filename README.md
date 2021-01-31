# Edison
A discord bot for the UTMK server
### Features
- Mechmarket poller

## Development

To run locally, set the `token` property in `dev.secret.exs` using the example file as a template, as well as the mechmarket channel and role IDs for the `:edison` config.

In order to override the default query, you can set `EDISON_MECHMARKET_QUERY` to whatever search term you'd like for searching /r/mechmarket.

To start the bot, run `mix run --no-halt`, or start it in `iex` with `iex -S mix`.

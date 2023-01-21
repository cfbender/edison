defmodule Edison.MixProject do
  use Mix.Project

  def project do
    [
      app: :edison,
      description: "A discord bot for the UTMK server",
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Edison, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.4"},
      {:httpoison, "~> 1.8"},
      {:poison, "~> 3.1"},
      {:plug, "~> 1.13"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end

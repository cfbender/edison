defmodule Edison.Mechmarket do
  @moduledoc """
  A polling GenServer that checks a mechmarket URL for new posts in a search and sends a message with new info
  """
  use GenServer

  alias Nostrum.Api

  require Logger

  @refresh_interval :timer.seconds(60)

  @mechmarket_query System.get_env("EDISON_MECHMARKET_QUERY", "US-UT")

  @url "https://www.reddit.com/r/mechmarket/search.json?q=#{@mechmarket_query}&restrict_sr=true&limit=5&sort=new"

  @mechmarket_channel System.get_env("EDISON_MECHMARKET_CHANNEL", "0")
                      |> String.to_integer()

  @spec start_link(GenServer.options()) :: GenServer.on_start()
  def start_link(options) do
    GenServer.start_link(__MODULE__, :ok, options)
  end

  @impl true
  def init(:ok) do
    {url, time} = fetch_posts()

    Api.create_message!(
      @mechmarket_channel,
      "New post matching #{@mechmarket_query}: #{url}"
    )

    schedule_refresh()
    {:ok, {url, time}}
  end

  @impl true
  def handle_info(:refresh, {_last_post, last_time}) do
    {url, time} = fetch_posts()

    if DateTime.compare(time, last_time) == :gt do
      Logger.debug("New mechmarket post found")

      Api.create_message!(
        @mechmarket_channel,
        "New post matching #{@mechmarket_query}: #{url}"
      )
    end

    schedule_refresh()
    {:noreply, {url, time}}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  defp fetch_posts() do
    Logger.debug("Fetching latest mechmarket posts...")

    try do
      %{"data" => %{"children" => children}} =
        HTTPoison.get!(@url) |> Map.get(:body) |> Poison.decode!()

      %{"data" => %{"created_utc" => created_utc, "url" => url}} = children |> List.first()

      {:ok, latest_time} = created_utc |> trunc() |> DateTime.from_unix()

      {url, latest_time}
    rescue
      e in RuntimeError -> Logger.debug(e)
    end
  end
end

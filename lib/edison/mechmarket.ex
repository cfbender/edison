defmodule Edison.Mechmarket do
  @moduledoc """
  A polling GenServer that checks a mechmarket URL for new posts in a search and sends a message with new info
  """
  use GenServer

  alias Nostrum.Api

  require Logger

  @refresh_interval :timer.seconds(120)

  @mechmarket_query Application.fetch_env!(:edison, :mechmarket_query)

  @url "https://www.reddit.com/r/mechmarket/search.json?q=#{@mechmarket_query}&restrict_sr=true&limit=5&sort=new"

  @mechmarket_channel Application.fetch_env!(:edison, :mechmarket_channel)

  @spec start_link(GenServer.options()) :: GenServer.on_start()
  def start_link(options) do
    GenServer.start_link(__MODULE__, :ok, options)
  end

  @impl true
  def init(:ok) do
    post_data = fetch_posts()
    Logger.debug("Starting mechmarket poller..")
    schedule_refresh()
    {:ok, post_data}
  end

  @impl true
  def handle_info(:refresh, %{latest_time: last_time} = data) do
    post_data = %{url: url, latest_time: time, author: author} = fetch_posts(data)

    if DateTime.compare(time, last_time) == :gt do
      Logger.debug("New mechmarket post found")

      Api.create_message!(
        @mechmarket_channel,
        "New post by /u/#{author} for #{@mechmarket_query}: #{url}"
      )
    end

    schedule_refresh()
    {:noreply, post_data}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  defp fetch_posts(), do: fetch_posts(%{latest_time: DateTime.from_unix!(0)})

  defp fetch_posts(%{latest_time: last_time} = data) do
    Logger.debug("Fetching latest mechmarket posts...")

    with %{"data" => %{"children" => children}} <-
           HTTPoison.get!(@url) |> Map.get(:body) |> Poison.decode!(),
         %{"data" => %{"created_utc" => created_utc, "url" => url, "author" => author}} <-
           children |> List.first(),
         {:ok, latest_time} <- created_utc |> trunc() |> DateTime.from_unix() do
      # if latest post is older than last, skip it
      if DateTime.compare(last_time, latest_time) == :gt do
        Logger.debug(
          "Skipping post since latest post has time #{latest_time} which is before #{last_time}"
        )

        data
      else
        %{url: url, latest_time: latest_time, author: author}
      end
    end
  end
end

defmodule Edison.Vaccine do
  @moduledoc """
  A polling GenServer that checks endpoints for vaccine appt availability

  DEPRECATED: to reinstate, add secrets back to config and add this module back to the supervisor
  """
  use GenServer

  alias Nostrum.Api

  require Logger
  require Record

  @type location ::
          record(:location,
            id: integer(),
            name: String.t(),
            address: String.t(),
            appt: boolean(),
            new_appt: boolean()
          )
  Record.defrecordp(:location,
    id: 0,
    name: "Hospital Name",
    address: "No Address Found",
    appt: false,
    new_appt: false
  )

  @refresh_interval :timer.seconds(60)

  @appointment_link "https://ihmacx.sjc1.qualtrics.com/jfe/form/SV_dguOj8muvwrlAns"

  @urls [
    tosh:
      "https://fvwzwdt8ld.execute-api.us-west-2.amazonaws.com/prod/covid19testing/sites/5065018/availabilities?region=IHMACX&days=10&private=true",
    ogden:
      "https://fvwzwdt8ld.execute-api.us-west-2.amazonaws.com/prod/covid19testing/sites/5064933/availabilities?region=IHMACX&days=10&private=true",
    park_city:
      "https://fvwzwdt8ld.execute-api.us-west-2.amazonaws.com/prod/covid19testing/sites/5064955/availabilities?region=IHMACX&days=10&private=true",
    riverton:
      "https://fvwzwdt8ld.execute-api.us-west-2.amazonaws.com/prod/covid19testing/sites/5064959/availabilities?region=IHMACX&days=10&private=true",
    utah_valley:
      "https://fvwzwdt8ld.execute-api.us-west-2.amazonaws.com/prod/covid19testing/sites/5065025/availabilities?region=IHMACX&days=10&private=true"
  ]

  @covid_channel Application.get_env(:edison, :covid_channel)

  @vaccine_role_id Application.get_env(:edison, :vaccine_role_id)

  @spec start_link(GenServer.options()) :: GenServer.on_start()
  def start_link(options) do
    GenServer.start_link(__MODULE__, :ok, options)
  end

  @impl true
  def init(:ok) do
    data = fetch_appointments()
    Logger.debug("Starting vaccine poller..")
    schedule_refresh()
    {:ok, data}
  end

  @impl true
  def handle_info(:refresh, data) do
    new_data = fetch_appointments(data)

    new_data
    |> Enum.each(fn record ->
      spawn(fn ->
        location(new_appt: new_appt, appt: appt, name: name, address: address) = record

        if new_appt && appt do
          Logger.debug("New vaccine appointment found")

          Api.create_message!(
            @covid_channel,
            """
            <@&#{@vaccine_role_id}> New vaccine appointment found at #{name}
            (#{address})
            #{@appointment_link}
            """
          )
        end
      end)
    end)

    schedule_refresh()
    {:noreply, new_data}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  defp fetch_appointments(prev_data \\ []) do
    Logger.debug("Fetching vaccine appointments...")

    try do
      @urls
      |> Enum.map(fn {_name, url} ->
        Task.async(fn ->
          {type, response} = HTTPoison.get(url, [], timeout: 20_000, recv_timeout: 20_000)

          cond do
            type == :ok ->
              %{"calendars" => calendars} =
                response
                |> Map.get(:body)
                |> Poison.decode!()

              cal = calendars |> List.first()

              id = cal["calendarId"]
              appts_avail = !(cal["availabilities"] |> Enum.empty?())

              new_appt =
                cond do
                  not Enum.empty?(prev_data) ->
                    prev_data |> List.first()

                    prev_record =
                      prev_data
                      |> Enum.find(fn record ->
                        location(record, :id) == id
                      end)

                    appts_avail && !location(prev_record, :appt)

                  true ->
                    false
                end

              location(
                id: cal["calendarId"],
                name: cal["name"],
                address: cal["location"],
                appt: appts_avail,
                new_appt: new_appt
              )

            true ->
              nil
          end
        end)
      end)
      |> Enum.map(&Task.await(&1, 20_000))
      |> Enum.filter(fn record -> record != nil end)
    rescue
      e in RuntimeError -> Logger.debug(e)
    end
  end
end

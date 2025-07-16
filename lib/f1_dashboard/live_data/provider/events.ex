defmodule F1Dashboard.LiveData.Provider.Events do
  alias F1Dashboard.LiveData
  alias F1Dashboard.LiveData.Provider

  alias Provider.Caller
  alias LiveData.Session

  @timeout :timer.seconds(10)
  @required_keys ~w(intervals position stints race_control pit weather)a

  @fetchers %{
    intervals: &Caller.intervals/1,
    position: &Caller.position/1,
    stints: &Caller.stints/1,
    race_control: &Caller.race_control/1,
    pit: &Caller.pit/1,
    weather: &Caller.weather/1
  }

  @spec for_session(Session.t()) :: {:ok, map()} | {:error, any()}
  def for_session(%Session{} = session) do
    @required_keys
    |> Task.async_stream(&fetch_by_key(&1, session), timeout: @timeout)
    |> Enum.into(%{}, fn
      {:ok, {key, {:ok, value}}} -> {key, {:ok, value}}
      {:ok, {key, {:error, reason}}} -> {key, {:error, reason}}
      {:exit, reason} -> {:unknown, {:error, reason}}
    end)
    |> validate_and_build()
  end

  defp validate_and_build(results) do
    with {:ok, values} <- extract_data(results) do
      {:ok, build_session_events(values)}
    end
  end

  defp fetch_by_key(key, session) do
    fetch_fn = Map.fetch!(@fetchers, key)
    result = fetch_fn.(session)
    {key, {:ok, result}}
  end

  defp extract_data(results) do
    Enum.reduce_while(@required_keys, %{}, fn key, acc ->
      case Map.get(results, key) do
        {:ok, {:ok, value}} ->
          {:cont, Map.put(acc, key, value)}

        error ->
          {:halt, error}
      end
    end)
    |> case do
      {:error, _} = error -> error
      acc when is_map(acc) -> {:ok, acc}
    end
  end

  defp build_session_events(%{
         intervals: intervals,
         position: position,
         stints: stints,
         race_control: race_control,
         pit: pit,
         weather: weather
       }) do
    events = %{
      interval: intervals,
      position: position,
      stints: stints,
      race_control: race_control,
      pit: pit
    }

    %{
      driver_events: get_drivers_and_group(events),
      race_control: race_control,
      weather: weather
    }
  end

  defp get_drivers_and_group(%{position: position} = events) do
    get_all_driver_numbers(position)
    |> Enum.map(&group_events_by_driver(&1, events))
  end

  defp group_events_by_driver(driver_number, events) do
    %{
      driver_number: driver_number,
      interval: find_latest(events.interval, driver_number),
      pit: find_latest(events.pit, driver_number),
      position: find_latest(events.position, driver_number),
      stint: find_latest(events.stints, driver_number)
    }
  end

  defp get_all_driver_numbers(events) do
    events |> Enum.map(& &1["driver_number"])
  end

  defp find_latest(events, driver_number) do
    events
    |> Enum.filter(&(&1["driver_number"] == driver_number))
    |> List.last()
  end
end

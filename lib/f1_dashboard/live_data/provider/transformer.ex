defmodule F1Dashboard.LiveData.Provider.Transformer do
  @oldest_event_acceptable_diff_seconds 300

  def filter_for_last_driver({:ok, data}), do: {:ok, do_filter_for_last_driver(data)}
  def filter_for_last_driver(error), do: error

  def filter_outdated_events({:ok, data}), do: {:ok, do_filter_outdated_events(data)}
  def filter_outdated_events(error), do: error

  def sort({:ok, data}), do: {:ok, Enum.sort(data)}
  def sort(error), do: error

  def sort_by_date({:ok, data}), do: {:ok, do_sort_by_date(data)}
  def sort_by_date(error), do: error

  def sort_by_position({:ok, data}), do: {:ok, do_sort_by_position(data)}
  def sort_by_position(error), do: error

  def get_one({:ok, list}) when length(list) >= 1, do: {:ok, Enum.at(list, 0)}
  def get_one({:error, reason}), do: {:error, reason}
  def get_one(_list), do: {:error, "Got an empty list, maybe no data yet?"}

  def map_ok({:ok, value}, fun), do: {:ok, fun.(value)}
  def map_ok(error, _fun), do: error

  defp do_filter_for_last_driver(data) do
    data
    |> Enum.reverse()
    |> Enum.uniq_by(& &1["driver_number"])
  end

  defp do_filter_outdated_events(events) do
    newest = Enum.max_by(events, &must_parse_date(&1), NaiveDateTime)

    events
    |> Enum.filter(&older_than_max(newest, &1))
  end

  defp older_than_max(newest, event) do
    newest_date = must_parse_date(newest)
    event_date = must_parse_date(event)

    NaiveDateTime.diff(newest_date, event_date, :second) <
      @oldest_event_acceptable_diff_seconds
  end

  defp do_sort_by_date(data) do
    data
    |> Enum.sort_by(&must_parse_date(&1), :desc)
  end

  defp do_sort_by_position(data) do
    data
    |> Enum.sort_by(& &1["position"], :asc)
  end

  defp must_parse_date(val) do
    case NaiveDateTime.from_iso8601(val["date"]) do
      {:ok, date} -> date
      {:error, _} -> NaiveDateTime
    end
  end
end

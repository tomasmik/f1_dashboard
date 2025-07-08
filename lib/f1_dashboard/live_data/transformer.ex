defmodule F1Dashboard.LiveData.Transformer do
  def filter_for_last_driver({:ok, data}), do: {:ok, do_filter_for_last_driver(data)}
  def filter_for_last_driver(error), do: error

  def sort({:ok, data}), do: {:ok, Enum.sort(data)}
  def sort(error), do: error

  def get_one(list) when length(list) >= 1, do: {:ok, Enum.at(list, 0)}
  def get_one(_list), do: {:error, "Got an empty list, maybe no data yet?"}

  def map_ok({:ok, value}, fun), do: {:ok, fun.(value)}
  def map_ok(error, _fun), do: error

  defp do_filter_for_last_driver(data) do
    data
    |> Enum.reverse()
    |> Enum.uniq_by(& &1["driver_number"])
  end
end

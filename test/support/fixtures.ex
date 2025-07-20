defmodule F1Dashboard.Fixtures do
  def drivers() do
    read_ficture("./json/drivers.json")
  end

  def intervals() do
    read_ficture("./json/intervals.json")
  end

  def pit() do
    read_ficture("./json/pit.json")
  end

  def positions() do
    read_ficture("./json/positions.json")
  end

  def race_control() do
    read_ficture("./json/race_control.json")
  end

  def stints() do
    read_ficture("./json/stints.json")
  end

  defp read_fixture(file_name) do
    Path.expand(file_name, __DIR__)
    |> File.read!()
    |> Jason.decode!()
  end
end

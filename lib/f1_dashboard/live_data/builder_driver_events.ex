defmodule F1Dashboard.LiveData.BuilderDriverEvents do
  alias F1Dashboard.LiveData.{Driver, SessionEvents}

  @spec build([Driver.t(), ...], SessionEvents.t()) :: list(map())
  def build(drivers, %SessionEvents{} = events) when is_list(drivers) do
    drivers
    |> Enum.map(&collect_for_driver(&1, events))
    |> Enum.sort_by(fn driver_data ->
      case driver_data.position do
        nil -> 9999
        position -> position.position
      end
    end)
  end

  defp collect_for_driver(%Driver{} = driver, %SessionEvents{} = events) do
    driver_number = driver.driver_number

    %{
      driver_number: driver_number,
      interval: filter_by_driver(events.interval, driver_number),
      pit: filter_by_driver(events.pit, driver_number),
      position: filter_by_driver(events.position, driver_number),
      stint: filter_by_driver(events.stints, driver_number)
    }
  end

  defp filter_by_driver(events, driver_number) do
    Enum.filter(events, &(&1.driver_number == driver_number))
    |> List.last()
  end
end

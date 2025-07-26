defmodule F1DashboardWeb.LiveData.State do
  use F1DashboardWeb, :live_view

  alias F1Dashboard.{LiveData}
  alias LiveData.{SessionEvents, SessionData}

  defstruct loading: true,
            is_race: false,
            collapsed_sections: %{},
            session: nil,
            weather: nil,
            race_control: [],
            driver_events: [],
            drivers: []

  def new do
    %__MODULE__{}
  end

  def toggle_section(%__MODULE__{} = state, section) do
    new_collapsed_sections = Map.update(state.collapsed_sections, section, true, &(!&1))
    %{state | collapsed_sections: new_collapsed_sections}
  end

  def update_events(%__MODULE__{} = state, %SessionEvents{} = events) do
    %{
      state
      | weather: events.weather,
        race_control: events.race_control,
        driver_events: events.driver_events
    }
  end

  def update_session(%__MODULE__{} = state, %SessionData{} = session_data) do
    %{
      state
      | loading: false,
        is_race: String.upcase(session_data.session.session_type) == "RACE",
        session: session_data.session,
        drivers: SessionData.drivers_by_number(session_data)
    }
  end

  def apply_to_socket(%__MODULE__{} = state, socket) do
    base = Map.from_struct(state)

    computed = %{
      weather_collapsed: section_collapsed?(state.collapsed_sections, "weather"),
      race_control_collapsed: section_collapsed?(state.collapsed_sections, "race_control")
    }

    Map.merge(base, computed)
    |> Enum.reduce(socket, fn {key, value}, acc ->
      assign(acc, key, value)
    end)
  end

  defp section_collapsed?(collapsed_sections, section_name) do
    Map.get(collapsed_sections, section_name, false)
  end
end

defmodule F1DashboardWeb.LiveData.Dashboard do
  use F1DashboardWeb, :live_view

  alias F1Dashboard.{LiveData}

  alias LiveData.{SessionEvents, SessionData}

  alias F1DashboardWeb.Components.{
    LoadingDashboard,
    RaceControl,
    RaceHeader,
    RaceTiming,
    OtherTiming,
    Weather
  }

  def mount(_conn, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :load_data, 0)
      LiveData.subscribe()
    end

    socket = assign(socket, :collapsed_sections, %{})
    {:ok, assign(socket, :loading, true)}
  end

  def handle_info(:load_data, socket) do
    {:noreply, socket_assign(socket, LiveData.get_session_data(), LiveData.get_events())}
  end

  def handle_info({:events_updated, events}, socket) do
    {:noreply, socket_assign_events(socket, events)}
  end

  def handle_info({:session_updated, session}, socket) do
    {:noreply, socket_assign_session(socket, session)}
  end

  def handle_event("toggle_section", %{"section" => section}, socket) do
    collapsed_sections = socket.assigns.collapsed_sections
    new_collapsed_sections = Map.update(collapsed_sections, section, true, &(!&1))

    {:noreply, assign(socket, :collapsed_sections, new_collapsed_sections)}
  end

  def render(assigns) do
    ~H"""
    <%= if @loading do %>
      <LoadingDashboard.render />
    <% else %>
      <div class="min-h-screen bg-gray-900 text-white">
        <RaceHeader.render session={@session} />

        <div class="px-4 py-6 space-y-6">
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <Weather.render
              weather={@weather}
              collapsed={section_collapsed?(@collapsed_sections, "weather")}
              section_name="weather"
            />
            <div class="lg:col-span-2">
              <RaceControl.render
                race_control={@race_control}
                collapsed={section_collapsed?(@collapsed_sections, "race_control")}
                section_name="race_control"
              />
            </div>
          </div>

          <%= if @is_race do %>
            <RaceTiming.render driver_events={@driver_events} drivers={@drivers} />
          <% else %>
            <OtherTiming.render driver_events={@driver_events} drivers={@drivers} />
          <% end %>
        </div>
      </div>
    <% end %>
    """
  end

  defp socket_assign(socket, nil, _) do
    socket
    |> assign(loading: true)
    |> assign(session: nil)
    |> assign(weather: nil)
    |> assign(race_control: [])
    |> assign(driver_events: [])
    |> assign(drivers: [])
  end

  defp socket_assign(socket, %SessionData{} = session_data, %SessionEvents{} = events) do
    socket
    |> socket_assign_session(session_data)
    |> socket_assign_events(events)
  end

  defp socket_assign_events(socket, events) do
    socket
    |> assign(weather: events.weather)
    |> assign(race_control: events.race_control)
    |> assign(driver_events: events.driver_events)
  end

  defp socket_assign_session(socket, session_data) do
    socket
    |> assign(loading: false)
    |> assign(is_race: String.upcase(session_data.session.session_type) == "RACE")
    |> assign(session: session_data.session)
    |> assign(drivers: SessionData.drivers_by_number(session_data))
  end

  defp section_collapsed?(collapsed_sections, section_name) do
    Map.get(collapsed_sections, section_name, false)
  end
end

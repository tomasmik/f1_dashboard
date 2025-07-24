defmodule F1DashboardWeb.LiveData.Dashboard do
  use F1DashboardWeb, :live_view

  alias F1Dashboard.{LiveData}

  alias LiveData.{SessionEvents, SessionData}

  alias F1DashboardWeb.Components.{
    LoadingDashboard,
    RaceControl,
    RaceHeader,
    Timing,
    Weather
  }

  def mount(_conn, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :load_data, 0)
      LiveData.subscribe()
    end

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

  def render(assigns) do
    ~H"""
    <%= if @loading do %>
      <LoadingDashboard.render />
    <% else %>
      <div class="min-h-screen bg-gray-900 text-white">
        <RaceHeader.render session={@session} />

        <div class="px-4 py-6 space-y-6">
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <Weather.render weather={@weather} />
            <div class="lg:col-span-2">
              <RaceControl.render race_control={@race_control} />
            </div>
          </div>

          <Timing.render driver_events={@driver_events} drivers={@drivers} />
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
    |> assign(session: session_data.session)
    |> assign(drivers: SessionData.drivers_by_number(session_data))
  end
end

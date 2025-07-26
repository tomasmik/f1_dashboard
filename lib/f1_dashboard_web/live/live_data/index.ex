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

  alias F1DashboardWeb.LiveData.{
    State
  }

  def mount(_conn, _session, socket) do
    state = State.new()

    if connected?(socket) do
      Process.send_after(self(), :load_data, 0)
      LiveData.subscribe()
    end

    {:ok, State.apply_to_socket(state, socket)}
  end

  def handle_info(:load_data, socket) do
    case {LiveData.get_session_data(), LiveData.get_events()} do
      {nil, _} ->
        {:noreply, socket}

      {session, events} ->
        state =
          socket_to_state(socket)
          |> State.update_session(session)
          |> State.update_events(events)

        {:noreply, State.apply_to_socket(state, socket)}
    end
  end

  def handle_info({:events_updated, events}, socket) do
    new = socket_to_state(socket) |> State.update_events(events)
    {:noreply, State.apply_to_socket(new, socket)}
  end

  def handle_info({:session_updated, session}, socket) do
    new = socket_to_state(socket) |> State.update_session(session)

    {:noreply, State.apply_to_socket(new, socket)}
  end

  def handle_event("toggle_section", %{"section" => section}, socket) do
    new = socket_to_state(socket) |> State.toggle_section(section)

    {:noreply, State.apply_to_socket(new, socket)}
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
            <Weather.render weather={@weather} collapsed={@weather_collapsed} section_name="weather" />
            <div class="lg:col-span-2">
              <RaceControl.render
                race_control={@race_control}
                collapsed={@race_control_collapsed}
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

  defp socket_to_state(socket) do
    struct(State, socket.assigns)
  end
end

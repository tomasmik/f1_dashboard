defmodule F1DashboardWeb.LiveData.Index do
  use F1DashboardWeb, :live_view

  alias F1Dashboard.{LiveData}

  @oldest_event_acceptable_diff 300

  def mount(_conn, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :load_data, 0)
      LiveData.subscribe()
    end

    {:ok, assign(socket, :loading, true)}
  end

  def handle_info(:load_data, socket) do
    session = LiveData.get_session()
    drivers = LiveData.get_drivers()
    events = LiveData.get_events()
    grouped_events = group_events_by_drivers(drivers, events)
    grouped_drivers = group_drivers(drivers)

    socket =
      socket
      |> assign(session: session)
      |> assign(weather: seed_weather_data())
      |> assign(race_control: sorted_race_control(events))
      |> assign(driver_events: grouped_events)
      |> assign(drivers: grouped_drivers)
      |> assign(loading: session == nil)

    {:noreply, socket}
  end

  def handle_info({:events_updated, events}, socket) do
    drivers = LiveData.get_drivers()
    grouped_events = group_events_by_drivers(drivers, events)

    new_socket =
      socket
      |> assign(driver_events: grouped_events)
      |> assign(race_control: sorted_race_control(events))
      |> assign(weather: seed_weather_data())

    {:noreply, new_socket}
  end

  def handle_info({:session_updated, session}, socket) do
    new_socket =
      socket
      |> assign(session: session)
      |> assign(loading: session == nil)

    {:noreply, new_socket}
  end

  def handle_info({:drivers_updated, drivers}, socket) do
    grouped = group_drivers(drivers)
    {:noreply, assign(socket, :drivers, grouped)}
  end

  def render(assigns) do
    ~H"""
    <%= if @loading do %>
      <div class="flex justify-center items-center h-screen bg-gray-900">
        <div class="text-center">
          <div class="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-red-600 mx-auto mb-4">
          </div>
          <p class="text-xl font-semibold text-white">
            Loading Live Timing...
          </p>
        </div>
      </div>
    <% else %>
      <div class="min-h-screen bg-gray-900 text-white">
        <!-- Header Section -->
        <.race_header session={@session} />

        <div class="px-4 py-6 space-y-6">
          <!-- Top Row: Weather and Race Control -->
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <.weather_panel weather={@weather} />
            <div class="lg:col-span-2">
              <.race_control_panel race_control={@race_control} />
            </div>
          </div>

          <.timing_tower driver_events={@driver_events} drivers={@drivers} />
        </div>
      </div>
    <% end %>
    """
  end

  defp race_header(assigns) do
    ~H"""
    <div class="bg-gradient-to-r from-red-800 via-red-700 to-red-800 border-b-4 border-red-500">
      <div class="max-w-7xl mx-auto px-4 py-6">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-6">
            <div class="text-6xl font-black text-white tracking-tight">
              F1
            </div>
            <div>
              <h1 class="text-3xl font-bold text-white mb-1">
                {@session.circuit_short_name}
              </h1>
              <p class="text-red-100 text-lg uppercase tracking-wide">
                {@session.session_type} • {@session.country_name}
              </p>
            </div>
          </div>
          <div class="text-right">
            <.session_status session={@session} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp session_status(assigns) do
    status = get_session_status(assigns.session)
    assigns = assign(assigns, :status, status)

    ~H"""
    <div class="flex flex-col items-end space-y-2">
      <div class={[
        "px-6 py-3 rounded-lg text-lg font-bold uppercase tracking-wider border-2",
        case @status do
          "live" -> "bg-green-600 text-white border-green-400 animate-pulse"
          "upcoming" -> "bg-yellow-600 text-white border-yellow-400"
          "completed" -> "bg-gray-600 text-white border-gray-400"
        end
      ]}>
        {case @status do
          "live" -> "● LIVE"
          "upcoming" -> "UPCOMING"
          "completed" -> "FINISHED"
        end}
      </div>
      <p class="text-red-100 text-sm font-mono">
        {format_datetime(@session.date_start)}
      </p>
    </div>
    """
  end

  defp weather_panel(assigns) do
    ~H"""
    <div class="bg-gray-800 rounded-lg border border-gray-700 overflow-hidden">
      <div class="bg-gray-750 px-6 py-4 border-b border-gray-700">
        <h2 class="text-xl font-bold text-white flex items-center">
          <svg class="w-6 h-6 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path
              fill-rule="evenodd"
              d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z"
              clip-rule="evenodd"
            />
          </svg>
          TRACK CONDITIONS
        </h2>
      </div>
      <div class="p-6">
        <%= if @weather do %>
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-3">
              <div class="flex justify-between items-center">
                <span class="text-gray-400 text-sm uppercase">Air Temp</span>
                <span class="text-white font-bold text-lg">{@weather.air_temperature}°C</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-gray-400 text-sm uppercase">Track Temp</span>
                <span class="text-white font-bold text-lg">{@weather.track_temperature}°C</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-gray-400 text-sm uppercase">Humidity</span>
                <span class="text-white font-bold text-lg">{@weather.humidity}%</span>
              </div>
            </div>
            <div class="space-y-3">
              <div class="flex justify-between items-center">
                <span class="text-gray-400 text-sm uppercase">Wind Speed</span>
                <span class="text-white font-bold text-lg">{@weather.wind_speed} ms/s</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-gray-400 text-sm uppercase">Wind Dir</span>
                <span class="text-white font-bold text-lg">{@weather.wind_direction}°</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-gray-400 text-sm uppercase">Rainfall</span>
                <span class={[
                  "font-bold text-lg",
                  if(@weather.rainfall > 0, do: "text-blue-400", else: "text-white")
                ]}>
                  {if @weather.rainfall > 0, do: "RAINING", else: "DRY"}
                </span>
              </div>
            </div>
          </div>
        <% else %>
          <div class="text-center py-8">
            <p class="text-gray-400">No weather data available</p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp race_control_panel(assigns) do
    ~H"""
    <div class="bg-gray-800 rounded-lg border border-gray-700 overflow-hidden">
      <div class="bg-gray-750 px-4 py-2 border-b border-gray-700">
        <h2 class="text-lg font-bold text-white flex items-center">
          <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path
              fill-rule="evenodd"
              d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
              clip-rule="evenodd"
            />
          </svg>
          RACE CONTROL
        </h2>
      </div>
      <div class="p-3">
        <%= if @race_control && length(@race_control) > 0 do %>
          <div class="space-y-1 max-h-80 overflow-y-auto">
            <%= for control <- Enum.take(@race_control, 15) do %>
              <div class={[
                "p-2 rounded border-l-2 flex items-center justify-between",
                case control.flag do
                  "YELLOW" -> "bg-yellow-900/50 border-yellow-500"
                  "RED" -> "bg-red-900/50 border-red-500"
                  "GREEN" -> "bg-green-900/50 border-green-500"
                  "BLUE" -> "bg-blue-900/50 border-blue-500"
                  "CHEQUERED" -> "bg-gray-700/50 border-white"
                  _ -> "bg-gray-700/50 border-gray-500"
                end
              ]}>
                <div class="flex items-center space-x-2 flex-1 min-w-0">
                  <span class={[
                    "text-xs font-bold px-1.5 py-0.5 rounded flex-shrink-0",
                    case control.flag do
                      "YELLOW" -> "bg-yellow-600 text-white"
                      "RED" -> "bg-red-600 text-white"
                      "GREEN" -> "bg-green-600 text-white"
                      "BLUE" -> "bg-blue-600 text-white"
                      "CHEQUERED" -> "bg-gray-600 text-white"
                      _ -> "bg-gray-600 text-white"
                    end
                  ]}>
                    {control.flag || control.category}
                  </span>
                  <p class="text-sm text-white truncate flex-1">{control.message}</p>
                </div>
                <span class="text-xs text-gray-400 font-mono flex-shrink-0 ml-2">
                  L{control.lap_number || "?"}
                </span>
              </div>
            <% end %>
          </div>
        <% else %>
          <div class="text-center py-6">
            <p class="text-gray-400 text-sm">No race control messages</p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp timing_tower(assigns) do
    ~H"""
    <div class="bg-gray-800 rounded-lg border border-gray-700 overflow-hidden">
      <div class="bg-gray-750 px-6 py-4 border-b border-gray-700">
        <h2 class="text-xl font-bold text-white flex items-center">
          <svg class="w-6 h-6 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path
              fill-rule="evenodd"
              d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z"
              clip-rule="evenodd"
            />
          </svg>
          LIVE TIMING
        </h2>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-750">
            <tr class="border-b border-gray-700">
              <th class="px-4 py-3 text-left text-xs font-bold text-gray-300 uppercase tracking-wider w-16">
                POS
              </th>
              <th class="px-4 py-3 text-left text-xs font-bold text-gray-300 uppercase tracking-wider">
                DRIVER
              </th>
              <th class="px-4 py-3 text-left text-xs font-bold text-gray-300 uppercase tracking-wider">
                GAP
              </th>
              <th class="px-4 py-3 text-left text-xs font-bold text-gray-300 uppercase tracking-wider">
                INT
              </th>
              <th class="px-4 py-3 text-left text-xs font-bold text-gray-300 uppercase tracking-wider">
                TYRE
              </th>
              <th class="px-4 py-3 text-left text-xs font-bold text-gray-300 uppercase tracking-wider">
                PIT
              </th>
            </tr>
          </thead>
          <tbody class="bg-gray-800">
            <%= for {driver_event, index} <- Enum.with_index(@driver_events) do %>
              <.driver_timing_row
                driver_number={driver_event.driver_number}
                events={driver_event}
                drivers={@drivers}
                position={index + 1}
              />
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp driver_timing_row(assigns) do
    ~H"""
    <tr class="border-b border-gray-700 hover:bg-gray-750 transition-colors">
      <td class="px-4 py-4 whitespace-nowrap">
        <div class={[
          "w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold",
          case @position do
            1 -> "bg-yellow-500 text-black"
            2 -> "bg-gray-300 text-black"
            3 -> "bg-orange-600 text-white"
            _ -> "bg-gray-600 text-white"
          end
        ]}>
          {@position}
        </div>
      </td>
      <td class="px-4 py-4 whitespace-nowrap">
        <div class="flex items-center">
          <div class="w-1 h-8 bg-red-600 rounded-full mr-3"></div>
          <div>
            <div class="text-sm font-bold text-white">
              {Map.get(@drivers, @driver_number).broadcast_name}
            </div>
            <div class="text-xs text-gray-400 font-mono">
              #{@driver_number}
            </div>
          </div>
        </div>
      </td>
      <td class="px-4 py-4 whitespace-nowrap">
        <.gap_display events={@events} position={@position} />
      </td>
      <td class="px-4 py-4 whitespace-nowrap">
        <.interval_display events={@events} />
      </td>
      <td class="px-4 py-4 whitespace-nowrap">
        <.tyre_display events={@events} />
      </td>
      <td class="px-4 py-4 whitespace-nowrap">
        <.pit_display events={@events} />
      </td>
    </tr>
    """
  end

  defp gap_display(assigns) do
    ~H"""
    <div class="text-sm font-mono">
      <%= if @position == 1 do %>
        <span class="text-green-400 font-bold">LEADER</span>
      <% else %>
        <%= if @events.interval && @events.interval.gap_to_leader do %>
          <span class="text-white font-bold">+{@events.interval.gap_to_leader}</span>
        <% else %>
          <span class="text-blue-400 font-bold">+1 LAP</span>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp interval_display(assigns) do
    ~H"""
    <div class="text-sm font-mono">
      <%= if @events.interval && @events.interval.interval do %>
        <span class="text-gray-300">+{@events.interval.interval}</span>
      <% else %>
        <span class="text-gray-500">--</span>
      <% end %>
    </div>
    """
  end

  defp tyre_display(assigns) do
    ~H"""
    <%= if @events.stint do %>
      <div class="flex items-center space-x-2">
        <.tyre_compound compound={@events.stint.compound} />
        <div class="text-xs">
          <div class="text-white font-bold">
            {String.first(@events.stint.compound || "U")}
          </div>
          <div class="text-gray-400">
            {@events.stint.tire_age_at_start}
          </div>
        </div>
      </div>
    <% else %>
      <span class="text-gray-500">--</span>
    <% end %>
    """
  end

  defp tyre_compound(assigns) do
    ~H"""
    <div class={[
      "w-6 h-6 rounded-full border-2 flex items-center justify-center",
      case @compound do
        "SOFT" -> "bg-red-500 border-red-400"
        "MEDIUM" -> "bg-yellow-500 border-yellow-400"
        "HARD" -> "bg-white border-gray-300"
        "INTERMEDIATE" -> "bg-green-500 border-green-400"
        "WET" -> "bg-blue-500 border-blue-400"
        _ -> "bg-gray-500 border-gray-400"
      end
    ]}>
      <span class={[
        "text-xs font-bold",
        case @compound do
          "HARD" -> "text-black"
          _ -> "text-white"
        end
      ]}>
        {String.first(@compound || "U")}
      </span>
    </div>
    """
  end

  defp pit_display(assigns) do
    ~H"""
    <%= if @events.pit do %>
      <div class="flex items-center space-x-2">
        <div class="w-3 h-3 bg-red-500 rounded-full animate-pulse"></div>
        <div class="text-xs">
          <div class="text-white font-bold">PIT</div>
          <div class="text-gray-400">{@events.pit.pit_duration}s</div>
        </div>
      </div>
    <% else %>
      <span class="text-gray-500">--</span>
    <% end %>
    """
  end

  defp get_session_status(session) do
    now = NaiveDateTime.utc_now()

    cond do
      NaiveDateTime.compare(now, session.date_start) == :lt -> "upcoming"
      NaiveDateTime.compare(now, session.date_end) == :gt -> "completed"
      true -> "live"
    end
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y at %I:%M %p")
  end

  defp sorted_race_control(events) do
    events.race_control
  end

  defp group_drivers(drivers) do
    drivers
    |> Enum.reduce(%{}, fn driver, acc ->
      Map.put(acc, driver.driver_number, driver)
    end)
  end

  defp group_events_by_drivers(drivers, events) do
    drivers
    |> Enum.map(&group_events_by_driver(&1, events))
    |> Enum.sort_by(& &1.position.position, :asc)
  end

  defp group_events_by_driver(driver, events) do
    driver_number = driver.driver_number

    %{
      driver_number: driver_number,
      interval: find_latest(events.interval, driver_number),
      pit: find_latest(events.pit, driver_number),
      position: find_latest(events.position, driver_number),
      stint: find_latest(events.stints, driver_number)
    }
  end

  defp find_latest(events, driver_number) do
    events
    |> Enum.filter(&(&1.driver_number == driver_number))
    |> List.last()
  end

  defp seed_weather_data() do
    %{
      air_temperature: 10,
      track_temperature: 10,
      humidity: 99,
      wind_speed: 4,
      wind_direction: "57",
      rainfall: 0
    }
  end
end

defmodule F1DashboardWeb.Components.Timing do
  use Phoenix.Component

  def render(assigns) do
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
end

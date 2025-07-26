defmodule F1DashboardWeb.Components.RaceTiming do
  use Phoenix.Component

  alias F1DashboardWeb.Components.Tire

  attr :driver_events, :list, required: true
  attr :drivers, :map, required: true

  def render(assigns) do
    ~H"""
    <div class="bg-gradient-to-br from-gray-800 to-gray-850 rounded-lg border border-gray-700/50 overflow-hidden shadow-lg">
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
              <th class="px-2 sm:px-4 py-3 text-left text-xs font-bold text-gray-300 uppercase tracking-wider w-12 sm:w-16">
                POS
              </th>
              <th class="px-2 sm:px-4 py-3 text-left text-xs font-bold text-gray-300 uppercase tracking-wider">
                DRIVER
              </th>
              <th class="px-2 sm:px-4 py-3 text-left text-xs font-bold text-gray-300 uppercase tracking-wider">
                GAP
              </th>
              <th class="px-2 sm:px-4 py-3 text-left text-xs font-bold text-gray-300 uppercase tracking-wider">
                TIRE
              </th>
              <th class="px-2 py-2 text-left text-xs font-bold text-gray-300 uppercase tracking-wider">
                LAST PIT
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
      <td class="px-2 sm:px-4 py-3 sm:py-4 whitespace-nowrap">
        <div class={[
          "w-6 h-6 sm:w-8 sm:h-8 rounded-full flex items-center justify-center text-xs sm:text-sm font-bold",
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
      <td class="px-2 sm:px-4 py-3 sm:py-4 whitespace-nowrap">
        <div class="flex items-center">
          <div class="w-1 h-8 bg-red-600 rounded-full mr-3"></div>
          <div>
            <div class="text-sm font-bold text-white">
              <span class="sm:hidden">
                {Map.get(@drivers, @driver_number).name_acronym}
              </span>
              <span class="hidden sm:inline">
                {Map.get(@drivers, @driver_number).broadcast_name}
              </span>
            </div>
            <div class="text-xs text-gray-400 font-mono">
              #{@driver_number}
            </div>
          </div>
        </div>
      </td>
      <td class="px-2 sm:px-4 py-3 sm:py-4 whitespace-nowrap">
        <.timing_display events={@events} position={@position} />
      </td>
      <td class="px-2 sm:px-4 py-3 sm:py-4 whitespace-nowrap">
        <Tire.render events={@events} />
      </td>
      <td class="px-2 sm:px-4 py-3 sm:py-4 whitespace-nowrap">
        <.pit_display events={@events} />
      </td>
    </tr>
    """
  end

  defp timing_display(assigns) do
    ~H"""
    <div class="text-sm font-mono space-y-1">
      <div class="leading-tight">
        <%= if @events.interval && @events.interval.interval do %>
          <span class="text-white font-bold text-base">+{@events.interval.interval}</span>
        <% else %>
          <span class="text-gray-500 font-bold text-base">--</span>
        <% end %>
      </div>

      <div class="leading-tight">
        <%= if @position == 1 do %>
          <span class="text-green-400 text-xs font-medium">LEADER</span>
        <% else %>
          <%= if @events.interval && @events.interval.gap_to_leader do %>
            <span class="text-gray-400 text-xs">+{@events.interval.gap_to_leader}</span>
          <% else %>
            <span class="text-blue-400 text-xs">+1 LAP</span>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  defp pit_display(assigns) do
    ~H"""
    <%= if @events.pit do %>
      <div class="flex items-center space-x-2">
        <div class="text-s">
          <div class="text-gray-400">{@events.pit.pit_duration}s</div>
        </div>
      </div>
    <% else %>
      <span class="text-gray-500">--</span>
    <% end %>
    """
  end
end

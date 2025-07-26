defmodule F1DashboardWeb.Components.RaceControl do
  use Phoenix.Component

  attr :race_control, :map, required: true
  attr :collapsed, :boolean, required: true
  attr :section_name, :string, default: "race_control"

  def render(assigns) do
    ~H"""
    <div class="bg-gradient-to-br from-gray-800 to-gray-850 rounded-lg border border-gray-700/50 overflow-hidden shadow-lg">
      <.section_header collapsed={@collapsed} section_name={@section_name} />
      <div class={[
        "transition-all duration-300 ease-in-out overflow-hidden",
        if(@collapsed, do: "max-h-0 opacity-0", else: "max-h-[1000px] opacity-100")
      ]}>
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
    </div>
    """
  end

  defp section_header(assigns) do
    ~H"""
    <div class="bg-gray-750 px-4 py-2 border-b border-gray-700 flex items-center justify-between">
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
      <button
        phx-click="toggle_section"
        phx-value-section={@section_name}
        type="button"
        class="p-2 text-gray-400 hover:text-white transition-colors rounded-lg hover:bg-gray-700/50"
      >
        <svg
          class={[
            "w-5 h-5 transition-transform duration-200",
            if(@collapsed, do: "rotate-0", else: "rotate-180")
          ]}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        </svg>
      </button>
    </div>
    """
  end
end

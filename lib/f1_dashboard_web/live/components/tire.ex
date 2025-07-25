defmodule F1DashboardWeb.Components.Tire do
  use Phoenix.Component

  attr :events, :list, required: true

  def render(assigns) do
    ~H"""
    <%= if @events.stint do %>
      <div class="flex items-center space-x-2">
        <.tire_compound compound={@events.stint.compound} />
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

  defp tire_compound(assigns) do
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
end

defmodule F1DashboardWeb.Components.Weather do
  use Phoenix.Component

  attr :weather, :map, required: true

  def render(assigns) do
    ~H"""
    <div class="bg-gradient-to-br from-gray-800 to-gray-850 rounded-xl border border-gray-700/50 overflow-hidden shadow-lg">
      <.section_header />

      <div class="p-6">
        <%= if @weather do %>
          <.weather_grid weather={@weather} />
        <% else %>
          <.no_data_state />
        <% end %>
      </div>
    </div>
    """
  end

  defp section_header(assigns) do
    ~H"""
    <div class="bg-gray-750 px-6 py-4 border-b border-gray-700">
      <h2 class="text-xl font-bold text-white flex items-center">
        <.track_icon /> TRACK CONDITIONS
      </h2>
    </div>
    """
  end

  defp track_icon(assigns) do
    ~H"""
    <svg class="w-6 h-6 mr-2" fill="currentColor" viewBox="0 0 20 20">
      <path
        fill-rule="evenodd"
        d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end

  defp weather_grid(assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-6">
      <div class="space-y-4">
        <.weather_item label="Air Temp" value={"#{@weather.air_temperature}°C"} />
        <.weather_item label="Track Temp" value={"#{@weather.track_temperature}°C"} />
        <.weather_item label="Humidity" value={"#{@weather.humidity}%"} />
      </div>

      <div class="space-y-4">
        <.weather_item label="Wind Speed" value={"#{@weather.wind_speed} m/s"} />
        <.weather_item label="Wind Dir" value={"#{@weather.wind_direction}°"} />
        <.rainfall_item rainfall={@weather.rainfall} />
      </div>
    </div>
    """
  end

  defp weather_item(assigns) do
    ~H"""
    <div class="flex justify-between items-center">
      <span class="text-gray-400 text-sm uppercase font-medium tracking-wide">
        {@label}
      </span>
      <span class="text-white font-bold text-lg">
        {@value}
      </span>
    </div>
    """
  end

  defp rainfall_item(assigns) do
    ~H"""
    <div class="flex justify-between items-center">
      <span class="text-gray-400 text-sm uppercase font-medium tracking-wide">
        Rainfall
      </span>
      <span class={[
        "font-bold text-lg",
        rainfall_color(@rainfall)
      ]}>
        {rainfall_text(@rainfall)}
      </span>
    </div>
    """
  end

  defp rainfall_color(rainfall) when rainfall > 0, do: "text-blue-400"
  defp rainfall_color(_), do: "text-white"

  defp rainfall_text(rainfall) when rainfall > 0, do: "RAINING"
  defp rainfall_text(_), do: "DRY"

  defp no_data_state(assigns) do
    ~H"""
    <div class="text-center py-8">
      <div class="w-12 h-12 mx-auto mb-3 text-gray-500">
        <svg fill="currentColor" viewBox="0 0 20 20" class="w-full h-full">
          <path fill-rule="evenodd" clip-rule="evenodd" />
        </svg>
      </div>
      <p class="text-gray-400 font-medium">No weather data available</p>
    </div>
    """
  end
end

defmodule F1DashboardWeb.Components.Weather do
  use Phoenix.Component

  def render(assigns) do
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
end

defmodule F1DashboardWeb.Components.RaceHeader do
  use Phoenix.Component

  attr :session, :map, required: true

  def render(assigns) do
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
end

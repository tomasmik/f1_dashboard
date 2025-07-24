defmodule F1DashboardWeb.Components.RaceHeader do
  use Phoenix.Component

  alias F1Dashboard.LiveData.Session

  attr :session, :map, required: true

  def render(assigns) do
    ~H"""
    <div class="bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 border-b border-gray-700/50">
      <div class="max-w-7xl mx-auto px-6 py-8">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-8">
            <div class="text-5xl font-black text-white tracking-tight">
              F1
            </div>
            <.session_info session={@session} />
          </div>

          <div class="text-right">
            <.session_status session={@session} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp session_info(assigns) do
    ~H"""
    <div class="space-y-1">
      <h1 class="text-3xl font-semibold text-white tracking-tight">
        {@session.circuit_short_name}
      </h1>
      <div class="flex items-center space-x-2 text-gray-300">
        <span class="text-base font-medium uppercase tracking-wider">
          {@session.session_type}
        </span>
        <span class="text-gray-500">•</span>
        <span class="text-base">
          {@session.country_name}
        </span>
      </div>
    </div>
    """
  end

  defp session_status(assigns) do
    assigns = assign(assigns, :status, Session.status_display(assigns.session))

    ~H"""
    <div class="flex flex-col items-end space-y-3">
      <.status_badge status={@status} />
      <.session_datetime session={@session} />
    </div>
    """
  end

  defp status_badge(assigns) do
    ~H"""
    <div class={[
      "px-5 py-2.5 rounded-full text-sm font-semibold uppercase tracking-wide",
      "backdrop-blur-sm border transition-all duration-200",
      case @status do
        "live" -> "bg-emerald-500/90 text-white border-emerald-400/50"
        "upcoming" -> "bg-amber-500/90 text-white border-amber-400/50"
        "completed" -> "bg-gray-500/90 text-white border-gray-400/50"
      end
    ]}>
      <span class="flex items-center gap-2">
        <%= if @status == "live" do %>
          <div class="w-1.5 h-1.5 bg-white rounded-full animate-pulse"></div>
        <% end %>
        {case @status do
          "live" -> "Live"
          "upcoming" -> "Upcoming"
          "completed" -> "Finished"
        end}
      </span>
    </div>
    """
  end

  defp session_datetime(assigns) do
    ~H"""
    <div class="px-3 py-1.5 bg-gray-800/60 rounded-lg border border-gray-700/30">
      <p class="text-gray-300 text-sm font-mono">
        {format_datetime(@session.date_start)}
      </p>
    </div>
    """
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y at %I:%M %p")
  end
end

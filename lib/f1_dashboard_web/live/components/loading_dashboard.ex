defmodule F1DashboardWeb.Components.LoadingDashboard do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center h-screen bg-gray-900">
      <div class="text-center">
        <div class="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-red-600 mx-auto mb-4">
        </div>
        <p class="text-xl font-semibold text-white">
          Loading Live Timing...
        </p>
      </div>
    </div>
    """
  end
end

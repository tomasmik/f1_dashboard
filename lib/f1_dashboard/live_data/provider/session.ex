defmodule F1Dashboard.LiveData.Provider.Session do
  alias F1Dashboard.LiveData.Provider
  alias Provider.Caller

  def latest() do
    with {:ok, session} <- Caller.session_latest(),
         {:ok, drivers} <- Caller.drivers(session) do
      data = %{
        drivers: drivers,
        session: session
      }

      {:ok, data}
    end
  end
end
